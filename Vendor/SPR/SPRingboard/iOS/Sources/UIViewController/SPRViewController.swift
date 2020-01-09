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


/// Notification that causes view controllers in the `SPR*ViewController` 
/// family to reload their models (or `ObjectDataSource`s).
let SPRViewControllerSetNeedsModelLoadedNotification = Notification.Name("SPRViewControllerSetNeedsModelsLoadedNotification")


/// Errors common to the `SPR*ViewController` family.
public enum SPRViewControllerError: Error {
    /// The view controller was asked to perform an operation while in a state 
    /// that does not support the operation.
    case invalidObjectState
    
    /// The model could not be loaded because it or one of its parent objects
    /// no longer exists. For example, if the view controller is loading the
    /// list of files in a directory, this error would be appropriate if the
    /// directory no longer exists, but not if the directory exists and is
    /// merely empty.
    case modelNotFound
    
    /// A network error prevents the view controller from loading its model(s)
    /// or completing a user-initiated action.
    case networkError(Error)
    
    /// The local data storage component reported an error that prevents the
    /// view controller from loading its model(s) or completing a 
    /// user-initiated action.
    case storageError(Error)
    
    /// The model is not of the expected type.
    case unexpectedModelType
}


/// Convenience subclass of `UIViewController` that simplifies the common 
/// pattern of loading a model and updating the view which that model. 
/// 
/// This class monitors the view controller lifecycle methods and manages a 
/// significant amount of state for its subclasses, ensuring that best 
/// practices are followed for loading models and updating views. Additionally, 
/// the model is only loaded if needed, and that the view is only updated when 
/// needed.
///
/// Subclasses must implement `loadModel(:)` and `updateView(withModel:)`. The 
/// `loadModel(:)` method asynchronously loads the model used to populate this 
/// view controller's views. The `updateView(withModel:)` method updates the 
/// view based on the model. Note that `updateView(withModel:)` may be called 
/// 0, 1, or more times for every time `loadModel(:)` is called.
///
/// Subclasses may opt to _also_ implement the remaining `open` methods to 
/// enhance the user's experience or handle business logic.
open class SPRViewController : UIViewController, SPRViewControllerFSMDelegate {
    
    private let sprvc_fsm = SPRViewControllerFSM()
    
    private var sprvc_activitypresenter: SPRViewControllerActivityPresenter?
    private var sprvc_result: Result<Any>?
    
    /// The model currently being used to populate the view.
    ///
    /// Must be called on the main thread.
    public var model: Any? {
        get {
            assert(Thread.current == Thread.main, "SPRViewController.model can only be accessed on the main queue")
            
            let value: Any?
            if let result = self.sprvc_result {
                switch result {
                case .success(let v):
                    value = v
                case .failure:
                    value = nil
                }
            } else {
                value = nil
            }
            return value
        }
    }
    
    // MARK: - Swift Object
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UIViewController
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
    
    // MARK: - SPRViewControllerFSMDelegate
    
    public final func hideLoading(forFSM fsm: SPRViewControllerFSM) {
        self.sprvc_activitypresenter?.hideActivityIndicator(forViewController: self)
        enableControls()
    }
    
    public final func layoutLoading(forFSM fsm: SPRViewControllerFSM) {
        self.sprvc_activitypresenter?.layoutActivityIndicator(forViewController: self)
    }
    
    public final func loadModel(forFSM fsm: SPRViewControllerFSM, requestID: Int) {
        let futureResult = self.loadModel()
        futureResult.then { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.sprvc_result = result
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
        guard let result = self.sprvc_result else { return }
        
        switch result {
        case .failure(let error):
            handleError(error)
        case .success(let model):
            updateView(withModel: model)
        }
    }
    
    // MARK: - SPRViewController
    
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
    
    /// Called when `loadModel()` indicates an error occurred.
    /// 
    /// When `loadModel()` indicates an error, this method is invoked instead 
    /// of `updateView(withModel:)`.
    ///
    /// An example use for this method is to show an alert or have this view
    /// controller dismiss itself.
    open func handleError(_ error: Error) {
        // do nothing
    }
    
    // MARK: Model & View Management
    
    /// Asynchronously load the model that will be used to populate the view.
    ///
    /// This method _must_ be overriden by subclasses. Direct subclasses _must
    /// not_ call the `super` implementation.
    open func loadModel() -> FutureResult<Any> {
        fatalError("FATAL: \(type(of: self)) does not override SPRViewController.loadModel() or it calls super")
    }
    
    /// Notify this view controller that its model is out of date and should be
    /// reloaded.
    ///
    /// Reloading is immediate if this view controller is visible, otherwise it
    /// is deferred until the view controller will become visible.
    ///
    /// This method is thread-safe.
    public final func setNeedsModelLoaded() {
        self.sprvc_fsm.setNeedsModelLoaded()
    }
    
    /// Update this view controller's view based on the provided model.
    ///
    /// Due to limitations with Interface Builder, view controllers cannot have
    /// Swift generic types. Therefore, the `withModel` parameter is passed in
    /// as an `Any`. Implementers must cast the model to the expected type.
    /// 
    /// This method _must_ be overriden by subclasses.
    open func updateView(withModel model: Any) {
        // do nothing
    }
    
    // MARK: - Private
    
    private func sprvc_sharedInitialization() {
        self.sprvc_fsm.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(SPRViewController.sprvc_handleSetNeedsModelLoaded(notification:)),
            name: SPRViewControllerSetNeedsModelLoadedNotification,
            object: nil
        )
    }
    
    @objc
    private func sprvc_handleSetNeedsModelLoaded(notification: Notification) {
        self.setNeedsModelLoaded()
    }
    
}

