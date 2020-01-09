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


/// A collection of convenience methods for working with the main 
/// `DispatchQueue`. 
public final class MainQueue {

    static private let mainSpecificKey = DispatchSpecificKey<String>()
    static private let mainSpecificValue: String = { () -> String in
        let key = MainQueue.mainSpecificKey
        let value = "sprcore.mainqueue"
        DispatchQueue.main.setSpecific(key: key, value: value)
        return value
    }()
    
    /// Execute a closure on the main queue. When called on the main queue, the 
    /// closure is executed synchronously and completes before this method 
    /// returns. Otherwise, the closure is dispatched asynchronously to the 
    /// main queue. 
    /// 
    /// - Parameters:
    ///     - block: The closure to be run on the main queue.
    public static func run(block: @escaping () -> Void) {
        // The block for MainQueue.mainSpecificValue is run the first time the
        // property is accessed, and must be run before we try to get the
        // current block's specific, so we access it immediately in this
        // method.
        let valueOnMainQueue = MainQueue.mainSpecificValue
        
        if
            let value = DispatchQueue.getSpecific(key: MainQueue.mainSpecificKey),
            value == valueOnMainQueue
        {
            // on main queue, so execute the block inline
            block()
        } else {
            // not on main queue, dispatch to the main queue
            DispatchQueue.main.async(execute: block)
        }
    }

}


