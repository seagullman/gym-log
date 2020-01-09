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


/// A class that manages debouncing calls to closures. 
/// 
/// When the object is instantiated, a delay interval is specified. Calling 
/// one of the `debounce` methods will cause the provided closure to be invoked 
/// after that delay has elapsed _only if_ `debounce` has not been called 
/// during that time. However, if one of the `debounce` methods is called 
/// before the interval has elapsed, the previous closure is discarded and the 
/// interval period starts over. 
/// 
/// In user interfaces, debouncing is commonly used to wait until a user has 
/// paused typing to act upon the user's input; for example, to provide a tool 
/// tip or suggest an auto-completion. 
///
/// The delay is not precise: real-world testing indicates that the block may 
/// execute up to 3ms after the interval has elapsed. This is acceptable for 
/// debouncing most UI activity (which commonly uses debounce intervals 
/// measured in hundreds of milliseconds), but may not be appropriate for in 
/// situations that require more precise timing. 
///
/// This class is _not_ thread-safe. It is the responsibility of the caller to
/// ensure that an instance is not concurrently accessed from multiple threads.
public final class Debouncer {
    private let queue: DispatchQueue
    private let delay: DispatchTimeInterval
    
    /// DispatchWorkItem containing the closure provided to the most recent 
    /// invocation of `debounce`. The closure is wrapped in a 
    /// `DispatchWorkItem` so that it can be cancelled when `debounce` is 
    /// called before the specified time interval has elapsed.
    private var previousWorkItem: DispatchWorkItem? = nil
    
    /// Create a `Debouncer` that dispatches closures onto the provided queue 
    /// after the specified interval of inactivity. 
    ///
    /// - Parameters:
    ///     - delay: Time interval that must elapse after `debounce` is called
    ///       without another call to `debounce` before the closure is 
    ///       dispatched. 
    ///     - queue: The queue on which the debounced closures should be 
    ///       dispatched. Defaults to the main queue.
    public init(delay: DispatchTimeInterval, queue: DispatchQueue = .main) {
        self.queue = queue
        self.delay = delay
    }
    
    deinit {
        self.cancel()
    }
    
    /// Cancel the pending call to a closure.
    ///
    /// It is safe to call this method when there is no closure waiting for the 
    /// debounce interval to elapse. 
    public func cancel() {
        self.previousWorkItem?.cancel()
        self.previousWorkItem = nil
    }
    
    /// Dispatch the provided closure after the receiver's debounce interval 
    /// has elapsed _only if_ none of the receiver's `debounce` methods are 
    /// called during the debounce interval.
    /// 
    /// - Parameters:
    ///     - execute: Closure to dispatch.
    public func debounce(execute: @escaping () -> Void) {
        self.cancel()
        
        let dispatchTime = DispatchTime.now() + self.delay
        let workItem = DispatchWorkItem(block: execute)
        self.previousWorkItem = workItem
        
        self.queue.asyncAfter(deadline: dispatchTime, execute: workItem)
    }
}


/// Convenience initializers and methods that are built on top of the public 
/// and internal `Debouncer` APIs. These methods do not access private 
/// properties or methods. 
public extension Debouncer {
    
    /// Create a `Debouncer` that dispatches closures onto the provided queue 
    /// after the specified interval of inactivity. 
    ///
    /// - Parameters:
    ///     - milliseconds: Number of milliseconds that must elapse after 
    ///       `debounce` is called without another call to `debounce` to 
    ///       dispatch a debounced closure. Negative values are converted to
    ///       positive values.
    ///     - queue: The queue on which the debounced closures should be 
    ///       dispatched. Defaults to the main queue.
    public convenience init(milliseconds: Int, queue: DispatchQueue = DispatchQueue.main) {
        let absoluteMillis = abs(milliseconds)
        let delay = DispatchTimeInterval.milliseconds(absoluteMillis)
        self.init(delay: delay, queue: queue)
    }
    
    /// Create a `Debouncer` that dispatches closures onto a global queue with 
    /// the specified quality of service after the specified interval of 
    /// inactivity. 
    ///
    /// - Parameters:
    ///     - milliseconds: Number of milliseconds that must elapse after 
    ///       `debounce` is called without another call to `debounce` to 
    ///       dispatch a debounced closure. Negative values are converted to
    ///       positive values.
    ///     - qos: The quality of service for the global queue on which the 
    ///       debounced closures should be dispatched.
    public convenience init(milliseconds: Int, qos: DispatchQoS.QoSClass) {
        let queue = DispatchQueue.global(qos: qos)
        self.init(milliseconds: milliseconds, queue: queue)
    }
    
    /// Dispatch the provided result handler with the a successful result 
    /// containing the provided value after the receiver's debounce interval 
    /// has elapsed — _only if_ none of the receiver's `debounce` methods are 
    /// called during the debounce interval.
    /// 
    /// - Parameters:
    ///     - value: Value to pass to the result handler
    ///     - completion: Result handler to process the value
    public func debounce<T>(_ value: T, completion: @escaping ResultHandler<T>) {
        debounce { completion(.success(value)) }
    }
    
    /// Dispatch the provided completion handler with the value after the 
    /// receiver's debounce interval has elapsed — _only if_ none of the 
    /// receiver's `debounce` methods are called during the debounce interval.
    /// 
    /// - Parameters:
    ///     - value: Value to pass to the result handler
    ///     - completion: Result handler to process the value
    public func debounce<T>(_ value: T, completion: @escaping (T?, Swift.Error?) -> Void) {
        debounce { completion(value, nil) }
    }
    
}
