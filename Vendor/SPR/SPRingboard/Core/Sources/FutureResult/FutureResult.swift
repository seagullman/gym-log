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


/// A `FutureResult` is container that will be asynchronously filled with a 
/// `Result`. A `FutureResult` can be returned by an asynchronous function that 
/// can fail. The function later fills the `FutureResult` with a `Result` 
/// indicating the success or failure of the function. 
/// 
/// A `FutureResult` is only filled _once._ Handlers attached to the future 
/// before the value is filled are dispatched when the handler is filled. 
/// Handlers attached after the future has been filled are dispatched 
/// immediately. 
/// 
/// This base implementation does nothing — it exists to define the core API 
/// that subclasses must implement. It is written as a class instead of a 
/// protocol to keep it easy to use and extend. (It was initially written as a 
/// protocol, but it required deep knowledge of Swift's protocol capabilities 
/// to use, maintain, and extend.) 
/// 
/// Subclasses must be thread-safe.
public class FutureResult<SuccessValue> {
    
    /// Common errors causing a `FutureResult` to fail.
    public enum Error: Swift.Error {
        /// Processing failed because it took longer than allowed.
        case timeout
    }
    
    /// An enumeration representing the possible states for a `Future`.
    ///
    /// Useful for implementations of `FutureResult` to track their state.
    public enum State {
        
        /// The future is filled with a result.
        case filled(Result<SuccessValue>)
        
        /// The future has not yet been filled.
        case unfilled
    }
    
    /// Public initializer for subclasses to call. By default, the initializer
    /// would be `internal`.
    ///
    /// In _The Swift Programming Language (Swift 4)_ book, see Access Control
    /// > Initializers > Default Initializers for more information.
    public init() { }
    
    /// Run the provided result handler when the receiver is filled. If the 
    /// receiver has been filled, the result handler will be dispatched 
    /// immediately.
    /// 
    /// Multiple handlers may be attached by calling this method multiple
    /// times.
    ///
    /// Example:
    /// 
    ///     func loadUser() -> FutureResult<User> {
    ///         // make an HTTP request, parse the JSON, populate a User model, etc.
    ///     }
    ///     
    ///     loadUser().then { (result) in
    ///         switch result {
    ///         case .success(let user):
    ///             // update view with user
    ///         case .failure(let error):
    ///             // log error
    ///             // update view to indicate error
    ///         }    
    ///     }
    /// 
    /// - Parameters:
    ///     - queue: The dispatch queue on which the result handler will be 
    ///       executed. Defaults to the main queue. 
    ///     - handler: The result handler to process the outcome of the 
    ///       asynchronous operation that created the receiver. 
    public func then(upon queue: DispatchQueue = .main, handleResult handler: @escaping ResultHandler<SuccessValue>) -> Void { }
    
}
