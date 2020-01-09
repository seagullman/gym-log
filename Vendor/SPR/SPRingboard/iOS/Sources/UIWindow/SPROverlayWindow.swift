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


/// A window that will present the provided view controller using a model
/// transition when it is made key and visible. This class exists to make it
/// easy to present content over an app's main window in a nice, animated
/// manner.
///
/// The state of the other windows in the app is not changed by presenting the
/// view controller in a new window. This is useful when the user must be
/// interrupted and returned to where she left off, when main window's view
/// controller hierarchy might be transitioning.
///
/// The view controller is presented using a modal transition style. Unless
/// overriden, the view controller will be presented using UIViewController's
/// default modal transition style (`coverVertical` as of iOS 11). Set the
/// `articleVC.modalTransitionStyle` property of the view controller being
/// presented to change how the view controller will appear.
///
/// Example:
///
///     // create and setup the view controller to be presented
///     let articleVC = storyboard.instantiateViewController(
///         withIdentifier: "ArticleDetail"
///     )
///     articleVC.articleID = 4512
///
///     // set how you want the view controller to animate in
///     articleVC.modalTransitionStyle = .crossDissolve
///
///     // present the view controller on top of the app's main window
///     let overlay = SPROverlayWindow(
///         presenting: articleVC,
///         overWindow: appDelegate.window
///     )
///     overlay.makeKeyAndVisible()
@objc public class SPROverlayWindow: UIWindow, RootViewControllerDelegate {

    @objc private class RootViewController: UIViewController {
        public weak var delegate: RootViewControllerDelegate?

        public override func viewDidLoad() {
            super.viewDidLoad()
            self.view.backgroundColor = UIColor.clear
            self.view.isOpaque = false
        }

        public override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            self.delegate?.rootViewControllerDidAppear(viewController: self)
        }
    }

    // MARK: Instance variables

    // The view controller to be presented.
    public let targetViewController: UIViewController

    // The delegate that will receive lifecycle event callbacks.
    public weak var delegate: SPROverlayWindowDelegate?

    private var animateTargetPresentation: Bool = true

    private var hasPresentedTargetViewController: Bool = false

    // This window is commonly used in a "fire and forget" manner and there is
    // usually no natural place to keep a reference to the window. Without a
    // strong refernce to the window from within the app, the window will be
    // removed from the screen and de-initialized _even if it was set to be
    // visible._ To make this class easy to use in these cases, it creates a
    // retain cycle on itself when it is displayed and breaks the retain cycle
    // when the target view controller is dismissed.
    private var strongReference: UIWindow?

    // MARK: Init / Deinit

    /// Create a window that will present the provided view controller using
    /// a model transition when it is made key and visible.
    ///
    /// - Parameter presentViewController: The view controller to be presented.
    /// - Parameter overWindow: The window over which the new window should
    ///   appear. The new window will have a `windowLevel` greater than the
    ///   provided window.
    public init(
        presentViewController viewController: UIViewController,
        overWindow window: UIWindow,
        animateTargetPresentation: Bool = true
    ) {
        self.targetViewController = viewController
        self.animateTargetPresentation = animateTargetPresentation

        super.init(frame: window.bounds)

        self.backgroundColor = UIColor.clear
        self.isOpaque = false
        self.windowLevel = window.windowLevel + 10

        let rootViewController = RootViewController()
        rootViewController.delegate = self
        self.rootViewController = rootViewController
    }

    /// Instantiate an object from a decoder.
    public required init?(coder aDecoder: NSCoder) {
        guard
            let decodedAny = aDecoder.decodeObject(of: [UIViewController.self], forKey: "targetViewController"),
            let targetVC = decodedAny as? UIViewController
        else {
            return nil
        }

        self.targetViewController = targetVC

        super.init(coder: aDecoder)
    }

    // MARK: UIWindow

    public override func becomeKey() {
        super.becomeKey()

        // prevent the window from de-initializing until the target view
        // controller dismisses
        self.strongReference = self
    }

    // MARK: RootViewControllerDelegate

    internal func rootViewControllerDidAppear(viewController: UIViewController) {
        if self.hasPresentedTargetViewController {
            // the root view controller is being displayed because the target
            // view controller was dismissed

            self.isHidden = true

            self.delegate?.overlayWindowDidHide(window: self)

            // allow the window to de-initialize if the app is no other strong
            // references to it
            self.strongReference = nil
        } else {
            // the root view controller is being displayed because the window
            // is being presented, so present the target view controller

            self.rootViewController?.present(
                self.targetViewController,
                animated: self.animateTargetPresentation,
                completion: nil
            )
            self.hasPresentedTargetViewController = true
        }
    }
}

/// A set of methods to receive callbacks during lifecycle events for the
/// overlay window.
public protocol SPROverlayWindowDelegate: class {

    /// Called by the overlay window when it has been removed from the screen.
    func overlayWindowDidHide(window: SPROverlayWindow)

}


/// Used by `SPROverlayWindow` to learn when the presented view controller
/// has been dismissed.
fileprivate protocol RootViewControllerDelegate: class  {

    func rootViewControllerDidAppear(viewController: UIViewController)

}

