// SPRingboard
// Copyright (c) 2017 SPRI, LLC <info@spr.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import UIKit


/// Convenience subclass of `UITableViewController` that handles 
/// interoperating with `ObjectDataSource`.
///
/// Subclasses must implement `loadObjectDataSource(:)`, 
/// `renderCell(inTableView:withError:at:)`, and 
/// `renderCell(inTableView:withModel:at:)`. The `loadObjectDataSource(:)` 
/// method asynchronously loads the models used to populate the table 
/// view. The `renderCell(…)` methods dequeue and populate cells appropriately. 
/// 
/// Subclasses may opt to _also_ implement the other `open` methods to enhance 
/// the user's experience or handle business logic.
open class SPRTableViewController : UITableViewController, SPRViewControllerFSMDelegate {
    
    private let sprvc_fsm = SPRViewControllerFSM()
    
    private var sprvc_activitypresenter: SPRViewControllerActivityPresenter?
    private var sprvc_error: Error?
    private var sprvc_nextobjectdatasource: ObjectDataSource<Any>?
    private var sprvc_objectdatasource: ObjectDataSource<Any> = ArrayObjectDataSource<Any>(objects: [])
    
    /// The `ObjectDataSource` currently being used to populate the view. 
    /// 
    /// Must be called on the main thread.
    public var objectDataSource: ObjectDataSource<Any> {
        get {
            assert(Thread.current == Thread.main, "SPRTableViewController.objectDataSource can only be accessed on the main queue")
            return self.sprvc_objectdatasource
        }
    }
    
    // MARK: - Swift Object
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UIViewController
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        sprvc_sharedInitialization()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sprvc_sharedInitialization()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.sprvc_activitypresenter = nil
        self.sprvc_fsm.viewDidLoad()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sprvc_fsm.viewWillAppear()
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.sprvc_fsm.viewWillLayoutSubviews()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.sprvc_fsm.viewDidLayoutSubviews()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sprvc_fsm.viewWillDisappear()
    }
    
    // MARK: - UITableViewDataSource
    
    public final override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        do {
            let model: Any = try self.objectDataSource.objectAt(indexPath)
            try cell = renderCell(in: tableView, withModel: model, at: indexPath)
        } catch let e {
            cell = renderCell(in: tableView, withError: e, at: indexPath)
        }
        
        return cell
    }
    
    public final override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = self.objectDataSource.numberOfObjectsInSection(section)
        return count
    }
    
    public final override func numberOfSections(in tableView: UITableView) -> Int {
        let count = self.objectDataSource.numberOfSections()
        return count
    }

    public final override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.objectDataSource.titleOfSection(section)
    }
    
    // MARK: - SPRViewControllerFSMDelegate
    
    public final func hideLoading(forFSM fsm: SPRViewControllerFSM) {
        self.sprvc_activitypresenter?.hideActivityIndicator(forViewController: self)
        enableControls()
    }
    
    public final func layoutLoading(forFSM fsm: SPRViewControllerFSM) {
        self.sprvc_activitypresenter?.layoutActivityIndicator(forViewController: self)
    }
    
    public final func loadModel(forFSM fsm: SPRViewControllerFSM, requestID: Int) {
        let futureResult = self.loadObjectDataSource()
        futureResult.then { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            switch result {
            case .failure(let error):
                strongSelf.sprvc_error = error
                strongSelf.sprvc_nextobjectdatasource = ErrorObjectDataSource(error: error)
            case .success(let ods):
                strongSelf.sprvc_error = nil
                strongSelf.sprvc_nextobjectdatasource = ods
            }
            
            fsm.modelLoaded(forRequestID: requestID)
        }
    }
    
    public final func showLoading(forFSM fsm: SPRViewControllerFSM) {
        disableControls()
        
        if self.sprvc_activitypresenter == nil {
            self.sprvc_activitypresenter = loadingActivityPresenter()
        }
        self.sprvc_activitypresenter?.showActivityIndicator(forViewController: self)
        self.sprvc_activitypresenter?.layoutActivityIndicator(forViewController: self)
    }
    
    public final func updateView(forFSM: SPRViewControllerFSM) {
        if let nextODS = self.sprvc_nextobjectdatasource {
            self.sprvc_objectdatasource = nextODS
            self.sprvc_nextobjectdatasource = nil
            
            if let tableView = self.tableView {
                tableView.reloadData()
                didReloadTableView(tableView, withObjectDataSource: nextODS)
            }
        }

        if let error = self.sprvc_error {
            DispatchQueue.main.async { [weak self] in
                self?.handleError(error)
            }
        }
    }
    
    // MARK: - SPRTableViewController
    
    // MARK: Activity Presentation
    
    /// Disable the controls that should not be active while the model is
    /// loading or this view controller is executing a command.
    ///
    /// Controls are any interactive elements managed by this view controller,
    /// such as `UIButton`, `UITextField`, `UITextView`, and `UIBarButtonItem`
    /// objects.
    ///
    /// This method will automatically be called by `SPR*ViewController` when
    /// the model is being loaded. You may choose to also call this method
    /// directly when initiating a command or other asynchronous activity.
    open func disableControls() {
        // do nothing
    }
    
    /// Enable the controls that disabled by `disableControls()`.
    ///
    /// This method will automatically be called by `SPR*ViewController` when
    /// the model has been loaded. You may choose to also call this method
    /// directly when a command or other asynchronous activity has completed.
    open func enableControls() {
        // do nothing
    }
    
    /// Create the object that manages the presentation of an activity
    /// indicator while this view controller is loading its model.
    ///
    /// Some activity indicator implementations require fresh references to the
    /// view controller's views, so this method will be invoked whenever an
    /// activity indicator is needed after the view has been reloaded.
    open func loadingActivityPresenter() -> SPRViewControllerActivityPresenter? {
        return nil
    }
    
    // MARK: Business Logic Injection Points
    
    /// Called after the table view has been reloaded with an
    /// `ObjectDataSource`.
    ///
    /// An example use for this method is to have the table view start
    /// with a cell already selected when it appears to the user.
    open func didReloadTableView(_ tableView: UITableView, withObjectDataSource objectDataSource: ObjectDataSource<Any>) {
        // do nothing
    }
    
    /// Called when `loadObjectDataSource()` indicates an error occurred.
    ///
    /// An example use for this method is to show an alert or have this view
    /// controller dismiss itself.
    ///
    /// This method is invoked on the next run loop _after_ the table view
    /// has been reloaded with the error, therefore
    /// `renderCell(inTableView:withError:at:)` is called before this
    /// method.
    open func handleError(_ error: Error) {
        // do nothing
    }
    
    // MARK: Model & View Management
    
    /// Load the `ObjectDataSource` used to populate the table view.
    ///
    /// This class _must_ be overriden by subclasses.
    open func loadObjectDataSource() -> FutureResult<ObjectDataSource<Any>> {
        fatalError("FATAL: \(type(of: self)) does not override SPRTableViewController.loadObjectDataSource() or it calls super")
    }
    
    /// Dequeue and populate a cell appropriate to indicate an error at the 
    /// specified index path.
    ///
    /// This method _must_ be overriden by subclasses. Direct subclasses _must
    /// not_ call the `super` implementation.
    open func renderCell(in tableView: UITableView, withError error: Error, at indexPath: IndexPath) -> UITableViewCell {
        fatalError("FATAL: \(type(of: self)) does not override SPRTableViewController.renderCell(inTableView:withError:at:) or it calls super")
    }
    
    /// Dequeue a cell and populate it with the model provided.
    /// 
    /// Due to limitations with Interface Builder, view controllers cannot have 
    /// Swift generic types. Therefore, the `withModel` parameter is passed in 
    /// as an `Any`. Implementers must cast the model to the expected type. 
    /// 
    /// This method _must_ be overriden by subclasses. Direct subclasses _must
    /// not_ call the `super` implementation.
    open func renderCell(in tableView: UITableView, withModel model: Any, at indexPath: IndexPath) throws -> UITableViewCell {
        fatalError("FATAL: \(type(of: self)) does not override SPRTableViewController.renderCell(inTableView:withModel:at:) or it calls super")
    }
    
    /// Notify this view controller that its `ObjectDataSource` is out of date 
    /// and should be reloaded. 
    /// 
    /// Reloading is immediate if this view controller is visible, otherwise it 
    /// is deferred until the view controller will become visible.
    /// 
    /// This method is thread-safe.
    public final func setNeedsModelLoaded() {
        self.sprvc_fsm.setNeedsModelLoaded()
    }
    
    // MARK: - Private
    
    private func sprvc_sharedInitialization() {
        self.sprvc_fsm.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SPRTableViewController.sprvc_handleSetNeedsModelLoaded(notification:)),
            name: SPRViewControllerSetNeedsModelLoadedNotification,
            object: nil
        )
    }
    
    @objc
    private func sprvc_handleSetNeedsModelLoaded(notification: Notification) {
        setNeedsModelLoaded()
    }
    
}
