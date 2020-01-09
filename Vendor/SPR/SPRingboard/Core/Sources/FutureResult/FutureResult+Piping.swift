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


fileprivate let uponQueue = DispatchQueue.global(qos: .utility)


/// Real-world business apps often perform a sequence of steps using the output
/// of the previous step as the input to the current step. By tradition, this
/// is called "piping" in reference to the UNIX pipe operator.
///
/// The methods in this extension make it easy to pipe together synchronous and
/// asynchronous tasks, accessing the output as a future.
public extension FutureResult {
    
    /// When the receiver fills with a successful result, execute the provided
    /// function with the receiver's success value, generating a new future
    /// that fills with the output of the function.
    ///
    /// The function will be executed on a global, concurrent dispatch queue.
    ///
    /// Example combining most piping methods:
    ///
    ///     func readOrder(_ orderID: Int) -> FutureResult<Order> {
    ///         // load from database or web service
    ///     }
    ///
    ///     func extractTrackingNumber(order: Order) throws -> String {
    ///         guard let trackingNumber = order.trackingNumber else {
    ///             throw OrderError.noTrackingNumber
    ///         }
    ///         return trackingNumber
    ///     }
    ///
    ///     // does not fail, fills with "Unknown" upon any internal error
    ///     func readShipmentStatus(trackingNumber: String) -> Future<String> {
    ///         // load from database or web service
    ///     }
    ///
    ///     func shipmentStatusForOrder(_ orderID: Int) -> FutureResult<String> {
    ///         let future: FutureResult<String>
    ///         future = readOrder(orderID)
    ///                  .transform(with: extractTrackingNumber(order:))
    ///                  .pipe(into: readShipmentStatus(trackingNumber:))
    ///         return future
    ///     }
    ///
    /// - Parameters:
    ///     - into: A closure that asynchronously performs work on the value
    ///       that fills the receiver upon success and fills a future another
    ///       value.
    /// - Returns: A `FutureResult` that fills with a `Result` based on the
    ///   receiver and the `into` function. If the receiver fails the
    ///   `FutureResult` returned will fill with a failure; otherwise, it will
    ///   fill with the value that fills the future returned by the function.
    public func pipe<NextValue>(into nextStep: @escaping (SuccessValue) -> Future<NextValue>) -> FutureResult<NextValue> {
        let deferred = DeferredResult<NextValue>()
        
        let block = { (result: Result<SuccessValue>) in
            switch result {
            case .success(let value):
                let future = nextStep(value)
                future.then { (nextValue) -> Void in
                    deferred.fill(result: .success(nextValue))
                }
            case .failure(let error):
                deferred.fill(result: .failure(error))
            }
        }
        self.then(upon: uponQueue, handleResult: block)
        
        return deferred
    }
    
    /// When the receiver fills with a successful result, execute the provided
    /// function with the receiver's success value, generating a new future
    /// that fills with the output of the function.
    ///
    /// The function will be executed on a global, concurrent dispatch queue.
    ///
    /// Example combining most piping methods:
    ///
    ///     func readOrder(_ orderID: Int) -> FutureResult<Order> {
    ///         // load from database or web service
    ///     }
    ///
    ///     func extractTrackingNumber(order: Order) throws -> String {
    ///         guard let trackingNumber = order.trackingNumber else {
    ///             throw OrderError.noTrackingNumber
    ///         }
    ///         return trackingNumber
    ///     }
    ///
    ///     // does not fail, fills with "Unknown" upon any internal error
    ///     func readShipmentStatus(trackingNumber: String) -> Future<String> {
    ///         // load from database or web service
    ///     }
    ///
    ///     func shipmentStatusForOrder(_ orderID: Int) -> FutureResult<String> {
    ///         let future: FutureResult<String>
    ///         future = readOrder(orderID)
    ///                  .transform(with: extractTrackingNumber(order:))
    ///                  .pipe(into: readShipmentStatus(trackingNumber:))
    ///         return future
    ///     }
    ///
    /// - Parameters:
    ///     - into: A closure that asynchronously performs work on the value
    ///       that fills the receiver upon success and fills a future another
    ///       value.
    /// - Returns: A `FutureResult` that fills with a `Result` based on the
    ///   receiver and the `into` function. If the receiver fails or the
    ///   `FutureResult` returned by the `into` function fails, the
    ///   `FutureResult` returned by this method will fill with a failure;
    ///   otherwise, it will fill with the value returned by the function.
    public func pipe<NextValue>(into nextStep: @escaping (SuccessValue) -> FutureResult<NextValue>) -> FutureResult<NextValue> {
        let deferred = DeferredResult<NextValue>()
        
        let block = { (result: Result<SuccessValue>) in
            switch result {
            case .success(let value):
                let futureResult = nextStep(value)
                futureResult.then { (nextResult) -> Void in
                    deferred.fill(result: nextResult)
                }
            case .failure(let error):
                deferred.fill(result: .failure(error))
            }
        }
        self.then(upon: uponQueue, handleResult: block)
        
        return deferred
    }
    
    /// Transforms (maps) the success value that fills the receiver into
    /// another value.
    ///
    /// When the receiver fills with a successful result, the provided function
    /// is executed with the success value. The output of that function is used
    /// to fill the returned `FutureResult`.
    ///
    /// The function will be executed on a global, concurrent dispatch queue.
    ///
    /// Example:
    ///
    ///     typealias Celcius = Double
    ///     typealias Fahrenheit = Double
    ///
    ///     func readTemperatureInRoom(_ roomID: Int) -> FutureResult<Fahrenheit> {
    ///         // ...
    ///     }
    ///
    ///     func convertToCelcius(fahrenheit: Fahrenheit) -> Celcius {
    ///         let celcius = (fahrenheit - 32.0) * 5.0 / 9.0
    ///         return celcius
    ///     }
    ///
    ///     let celciusResult: ResultFuture<Double>
    ///     celciusResult = readTemperatureInRoom(123)
    ///                     .tranform(with: convertToCelcius(fahrenheit:))
    ///
    /// - Parameters:
    ///     - with: A closure that performs work on the value that fills the
    ///       receiver upon success and returns another value.
    /// - Returns: A `FutureResult` that fills with a `Result` based on the
    ///   receiver and the `with` function. If the receiver fails or the `with`
    ///   function throws an error, the `FutureResult` returned will fill with
    ///   a failure; otherwise, it will fill with the value returned by the
    ///   function.
    public func transform<NextValue>(with transformer: @escaping (SuccessValue) throws -> NextValue) -> FutureResult<NextValue> {
        let deferred = DeferredResult<NextValue>()
        
        let block = { (result: Result<SuccessValue>) in
            switch result {
            case .success(let value):
                do {
                    let nextValue = try transformer(value)
                    deferred.fill(result: .success(nextValue))
                } catch (let error) {
                    deferred.fill(result: .failure(error))
                }
            case .failure(let error):
                deferred.fill(result: .failure(error))
            }
        }
        self.then(upon: uponQueue, handleResult: block)
        
        return deferred
    }
    
}
