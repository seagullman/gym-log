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


/// Private queue for Deferred instances to use for ensuring serialized access
/// to the instance variables.
///
/// Used as the target of each Deferred's own private queue, as recommended in 
/// WWDC 2017 Session 706 as a best practice. It could be reasonably argued 
/// that this is a premature performance optimization (Bad Idea[TM]) right now.
fileprivate let sharedPrivateQueue = DispatchQueue(label: "sprcore.deferred.shared", qos: .utility)


/// An implementation of `Future` that can be filled.
/// 
/// Example:
/// 
///     func tellMeTheTimeOnTheMinute() -> Future<Date> {
///         let deferred = Deferred<Int>()
///
///         DispatchQueue.global().async {
///            // determine how many seconds we are into the current minute
///            let timeInterval = Date.timeIntervalSinceReferenceDate
///            let secondsSinceReferenceDate = Int64(timeInterval)
///            let secondsIntoCurrentMinute = secondsSinceReferenceDate % 60
///            
///            // determine number of seconds left in the current minute
///            let secondsUntilNextMinute = 60 - secondsIntoCurrentMinute
///            let sleepInterval = TimeInterval(secondsUntilNextMinute)
///            
///            // wait until the next minute starts
///            Thread.sleep(forTimeInterval: sleepInterval)
///
///            // fill the future with the current Date
///            let date = Date()
///            deferred.fill(date)
///         }
///
///         return deferred
///     }
public final class Deferred<T>: Future<T> {
    
    private struct Subscriber {
        internal let queue: DispatchQueue
        internal let handler: (T) -> Void
        
        internal func handle(_ value: T) {
            let block = self.handler
            self.queue.async {
                block(value)
            }
        }
    }
    
    private let privateQueue = DispatchQueue(label: "sprcore.deferred", target: sharedPrivateQueue)
    private var subscribers: [Subscriber] = []
    private var state: State = .unfilled
    
    // MARK: - Future
    
    public override func then(upon queue: DispatchQueue = .main, run handler: @escaping (T) -> Void) {
        let subscriber = Subscriber(queue: queue, handler: handler)
        self.privateQueue.async {
            switch self.state {
            case .unfilled:
                self.subscribers.append(subscriber)
            case .filled(let value):
                subscriber.handle(value)
            }
        }
    }
    
    // MARK: - Public API
    
    public func fill(value: T) -> Void {
        self.privateQueue.async {
            guard case .unfilled = self.state else { 
                // TODO: log ERROR
                return 
            }
            
            for subscriber in self.subscribers {
                subscriber.handle(value)
            }
            
            self.subscribers = []
            self.state = .filled(value)
        }
    }
    
}

public extension Deferred {
    
    public var completionHandler: (T) -> Void {
        let block: (T) -> Void = { (value) in
            self.fill(value: value)
        }
        return block
    }
    
}
