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


/// A `Future` is container that will be asynchronously filled with a value. An 
/// asynchronous function can synchronously return a future, then fill the 
/// future later when its asynchronous operations complete. 
/// 
/// A future is only filled _once._ Handlers attached to the future before the
/// value is filled are executed at the time the handler is filled. Handlers 
/// attached after the future has been filled are executed immediately. 
/// 
/// This base implementation does nothing — it exists to define the core API 
/// that subclasses must implement. It is written as a class instead of a 
/// protocol to keep it easy to use and extend. (It was initially written as a 
/// protocol, but it required deep knowledge of Swift's protocol capabilities 
/// to use, maintain, and extend.) 
/// 
/// Subclasses must be thread-safe.
open class Future<Value> {
    
    /// An enumeration representing the possible states for a `Future`.
    ///
    /// Useful for implementations of `Future` to track their state.
    public enum State {
        
        // The future is filled with the associated value.
        case filled(Value)
        
        // The future has not yet been filled.
        case unfilled
    }
    
    /// Public initializer for subclasses to call. By default, the initializer
    /// would be `internal`.
    ///
    /// In _The Swift Programming Language (Swift 4)_ book, see Access Control
    /// > Initializers > Default Initializers for more information.
    public init() { }
    
    /// Attach a handler to be dispatched on the provided queue when the future
    /// is filled with a value. If the receiver is already filled, the handler
    /// will be dispatched immediately.
    ///
    /// Multiple handlers may be attached by calling this method multiple 
    /// times.
    ///
    /// Example:
    ///
    ///     let futureProduct: Future<Product> = loadProduct(withID: 123)
    ///     futureProduct.then(upon: .main) { (product) in
    ///         // update UI with product
    ///     }
    ///
    /// - Parameters:
    ///     - queue: The queue on which the handler will be asynchronously
    ///       dispatched. Defaults to the main queue.
    ///     - handler: A closure to be dispatched with the filled value.
    open func then(upon queue: DispatchQueue = .main, run handler: @escaping (Value) -> Void) { }
    
}
