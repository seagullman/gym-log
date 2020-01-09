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


public extension FutureResult {
    
    /// Create a FutureResult that fills with a timeout failure if the receiver
    /// is not filled after the provided number of milliseconds have elapsed.
    ///
    /// A timeout failure is a `.failure` result with an error of
    /// `FutureResult.Error.timeout`.
    ///
    /// - Parameters:
    ///     - milliseconds: The number of milliseconds that must elapse without
    ///       the receiver filling for the returned future to fill with a
    ///       failure due to timeout. Negative values will be converted to
    ///       positive values.
    /// - Returns: A `FutureResult` that will fill with the receiver's result
    ///   or with a timeout failure if the receiver is not filled after
    ///   `milliseconds` have elapsed.
    public func timeoutAfter(milliseconds: Int) -> FutureResult<SuccessValue> {
        // Convert milliseconds to a TimeInterval
        let interval: TimeInterval = 0.001 * Double(milliseconds)
        
        // Pass through to timeoutAfter(interval:)
        let future = self.timeoutAfter(interval: interval)
        return future
    }
    
    /// Create a FutureResult that fills with a timeout failure if the receiver
    /// is not filled after the provided time interval has elapsed.
    ///
    /// A timeout failure is a `.failure` result with an error of
    /// `FutureResult.Error.timeout`.
    ///
    /// - Parameters:
    ///     - interval: The amount of time that must elapse without the
    ///       receiver filling for the returned future to fill with a timeout
    ///       failure. Negative values will be converted to positive values.
    /// - Returns: A `FutureResult` that will fill with the receiver's result
    ///   or with a timeout failure if the receiver is not filled after
    ///   `interval` seconds have elapsed.
    public func timeoutAfter(interval: TimeInterval) -> FutureResult<SuccessValue> {
        // Create a FutureResult that fails after the specified interval
        let absInterval = (interval < 0) ? -interval : interval
        let timeoutDeferred = DeferredResult<SuccessValue>()
        let timeoutResult: Result<SuccessValue> = .failure(FutureResult.Error.timeout)
        timeoutDeferred.fill(result: timeoutResult, after: absInterval)
        
        // Create a FutureResult that fills with this future's result or the
        // timeout error depending on which which finishes first
        let future = FutureResult.race(self, timeoutDeferred)
        return future
    }
    
}
