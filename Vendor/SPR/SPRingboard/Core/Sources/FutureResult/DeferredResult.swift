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

import Dispatch
import Foundation


/// Private queue for DeferredResult instances to use for ensuring serialized 
/// access to the instance variables.
/// 
/// Used as the target of each DeferredResult's own private queue, as 
/// recommended in WWDC 2017 Session 706 as a best practice. It could be 
/// reasonably argued that this is a premature performance optimization (Bad 
/// Idea[TM]) right now.
fileprivate let sharedPrivateQueue = DispatchQueue(label: "sprcore.deferredresult.shared", qos: .utility)


public final class DeferredResult<T>: FutureResult<T> {
    
    public enum Error: Swift.Error {
        case completionHandlerMissingValueAndError
    }
    
    private struct Subscriber {
        internal let queue: DispatchQueue
        internal let resultHandler: ResultHandler<T>
        
        internal func handleResult(_ result: Result<T>) {
            let block = self.resultHandler
            self.queue.async {
                block(result)
            }
        }
    }

    private let privateQueue = DispatchQueue(label: "sprcore.deferredresult", target: sharedPrivateQueue)
    
    private var subscribers: [Subscriber] = []
    private var state: State = .unfilled
    
    // MARK: FutureResult
    
    public override func then(upon queue: DispatchQueue = .main, handleResult handler: @escaping (Result<T>) -> Void) {
        let subscriber = Subscriber(queue: queue, resultHandler: handler)
        self.privateQueue.async {
            switch self.state {
            case .unfilled:
                self.subscribers.append(subscriber)
            case .filled(let result):
                subscriber.handleResult(result)
            }
        }
    }
    
    // MARK: Public API
    
    public func fill(
        result: Result<T>,
        otherwise: (() -> Void)? = { fatalError("DeferredResult default otherwise block triggered") }
    ) -> Void {
        self.privateQueue.async {
            guard case .unfilled = self.state else {
                if let otherwise = otherwise {
                    otherwise()
                }
                return
            }
            
            for subscriber in self.subscribers {
                subscriber.handleResult(result)
            }
            
            self.subscribers = []
            self.state = .filled(result)
        }
    }
    
}


public extension DeferredResult {
    
    public var completionHandler: (T?, Swift.Error?) -> Void {
        get {
            let block: (T?, Swift.Error?) -> Void = { (value, error) in
                let result: Result<T>
                if let error = error {
                    result = .failure(error)
                } else if let value = value {
                    result = .success(value)
                } else {
                    result = .failure(Error.completionHandlerMissingValueAndError)
                }
                self.fill(result: result)
            }
            return block
        }
    }
    
    public var resultHandler: ResultHandler<T> {
        get {
            let resultHandler: ResultHandler<T> = { self.fill(result: $0) }
            return resultHandler
        }
    }
    
    public convenience init(value: T) {
        self.init()
        self.fill(result: .success(value))
    }
    
    public convenience init(error: Swift.Error) {
        self.init()
        self.fill(result: .failure(error))
    }
    
    public func success(value: T) {
        self.fill(result: .success(value))
    }
    
    public func failure(error: Swift.Error) {
        self.fill(result: .failure(error))
    }
    
    public func fill(futureResult: FutureResult<T>) {
        futureResult.then { self.fill(result: $0) }
    }
    
    public func fill(
        result: Result<T>,
        after interval: TimeInterval,
        otherwise: (() -> Void)? = { fatalError("DeferredResult default otherwise block triggered") }
    ) {
        let deadline = DispatchTime.now() + interval
        let queue = DispatchQueue.global()
        queue.asyncAfter(deadline: deadline) {
            self.fill(result: result, otherwise: otherwise)
        }
    }
}
