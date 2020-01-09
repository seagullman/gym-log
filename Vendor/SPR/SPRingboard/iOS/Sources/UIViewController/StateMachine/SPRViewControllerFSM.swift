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

import Foundation


public protocol SPRViewControllerFSMDelegate: class {
    func showLoading(forFSM fsm: SPRViewControllerFSM) -> Void
    func layoutLoading(forFSM fsm: SPRViewControllerFSM) -> Void
    func hideLoading(forFSM fsm: SPRViewControllerFSM) -> Void
    func loadModel(forFSM fsm: SPRViewControllerFSM, requestID: Int) -> Void
    func updateView(forFSM: SPRViewControllerFSM) -> Void
}


public final class SPRViewControllerFSM {
    private enum State {
        case visibleNeedsModelLoaded
        case visibleLoading
        case visibleNeedsViewUpdated
        case visibleShowingModel
        
        case hiddenNeedsModelLoaded
        case hiddenLoading
        case hiddenNeedsViewUpdated
        case hiddenShowingModel
    }

    
    private let queue: DispatchQueue = DispatchQueue(label: "SPRViewControllerFSM", qos: .default)
    private var state: State = .hiddenNeedsModelLoaded
    private var currentRequestNumber = 0
    
    public weak var delegate: SPRViewControllerFSMDelegate? = nil
    
    /// Public initializer. By default, the initializer would be `internal`.
    ///
    /// In _The Swift Programming Language (Swift 4)_ book, see Access Control
    /// > Initializers > Default Initializers for more information.
    public init() { }
    
    public func viewDidLoad() {
        self.queue.sync {
            switch self.state {
            case .hiddenLoading:
                tellDelegateToShowLoadingIndicator()
            case .hiddenShowingModel:
                changeState(to: .hiddenNeedsViewUpdated)
            default:
                break
            }
        }
    }
    
    public func viewWillLayoutSubviews() {
        self.queue.sync {
            switch self.state {
            case .hiddenLoading:
                tellDelegateToLayoutLoadingIndicator()
            case .visibleLoading:
                tellDelegateToLayoutLoadingIndicator()
            default:
                break
            }
        }
    }
    
    public func viewDidLayoutSubviews() {
        // do nothing
    }
    
    public func viewWillAppear() {
        self.queue.sync {
            switch self.state {
            case .hiddenNeedsModelLoaded:
                changeState(to: .visibleNeedsModelLoaded)
            case .hiddenLoading:
                changeState(to: .visibleLoading)
            case .hiddenNeedsViewUpdated:
                changeState(to: .visibleNeedsViewUpdated)
            case .hiddenShowingModel:
                changeState(to: .visibleShowingModel)
            default:
                break
            }
        }
    }
    
    public func viewWillDisappear() {
        self.queue.sync {
            switch self.state {
            case .visibleLoading:
                changeState(to: .hiddenLoading)
            case .visibleShowingModel:
                changeState(to: .hiddenShowingModel)
            default:
                break
            }
        }
    }
    
    public func setNeedsModelLoaded() {
        self.queue.sync {
            switch self.state {
            case .hiddenLoading:
                changeState(to: .hiddenNeedsModelLoaded)
            case .hiddenNeedsViewUpdated:
                changeState(to: .hiddenNeedsModelLoaded)
            case .hiddenShowingModel:
                changeState(to: .hiddenNeedsModelLoaded)
            case .visibleLoading:
                changeState(to: .visibleNeedsModelLoaded)
            case .visibleNeedsViewUpdated:
                changeState(to: .visibleNeedsModelLoaded)
            case .visibleShowingModel:
                changeState(to: .visibleNeedsModelLoaded)
            default:
                break
            }
        }
    }
    
    public func modelLoaded(forRequestID requestID: Int) {
        self.queue.sync {
            guard requestID == self.currentRequestNumber else {
                // ignoring async callback to earlier, "cancelled" loadModel()
                return
            }
            
            switch self.state {
            case .hiddenLoading:
                changeState(to: .hiddenNeedsViewUpdated)
            case .visibleLoading:
                changeState(to: .visibleNeedsViewUpdated)
            default:
                break
            }
        }
    }
    
    private func changeState(to state: State) {
        let previousState = self.state
        self.state = state
        
        // if transitioning out of one of the "Loading" states, tell the 
        // delegate to hide the loading indicator
        let loadingStates: [State] = [.hiddenLoading, .visibleLoading]
        if loadingStates.contains(previousState) && !loadingStates.contains(state) {
            tellDelegateToHideLoadingIndicator()
        }
        
        // if the VC is loading and is transitioning off screen, hide the 
        // loading indicator
        if previousState == .visibleLoading && state == .hiddenLoading {
            tellDelegateToHideLoadingIndicator()
        }
        
        // handle delegate calls
        switch state {
        case .visibleLoading:
            tellDelegateToShowLoadingIndicator()
        case .visibleNeedsModelLoaded:
            tellDelegateToLoadModel()
            changeState(to: .visibleLoading)
        case .visibleNeedsViewUpdated:
            tellDelegateToUpdateView()
            changeState(to: .visibleShowingModel)
        default:
            break
        }
    }
    
    private func tellDelegateToHideLoadingIndicator() {
        guard let delegate = self.delegate else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            delegate.hideLoading(forFSM: strongSelf)
        }
    }
    
    private func tellDelegateToLayoutLoadingIndicator() {
        guard let delegate = self.delegate else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            delegate.layoutLoading(forFSM: strongSelf)
        }
    }
    
    private func tellDelegateToLoadModel() {
        guard let delegate = self.delegate else { return }
        
        let idWillOverflow = (self.currentRequestNumber == Int.max)
        let requestID = (idWillOverflow) ? 0 : self.currentRequestNumber + 1
        self.currentRequestNumber = requestID
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            delegate.loadModel(forFSM: strongSelf, requestID: requestID)
        }
    }

    private func tellDelegateToShowLoadingIndicator() {
        guard let delegate = self.delegate else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            delegate.showLoading(forFSM: strongSelf)
            delegate.layoutLoading(forFSM: strongSelf)
        }
    }
    
    private func tellDelegateToUpdateView() -> Void {
        guard let delegate = self.delegate else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            delegate.updateView(forFSM: strongSelf)
        }
    }
}
