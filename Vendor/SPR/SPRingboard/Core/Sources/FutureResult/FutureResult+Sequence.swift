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


public extension FutureResult where SuccessValue: Sequence {
    
    public func compactMap<T>(_ transform: @escaping (SuccessValue.Element) throws -> T?) -> FutureResult<[T]> {
        let future = self.transform { (sequence) throws -> [T] in
            let array = try sequence.compactMap(transform)
            return array
        }
        return future
    }

    public func filter(_ isIncluded: @escaping (SuccessValue.Element) throws -> Bool) -> FutureResult<[SuccessValue.Element]> {
        let future = self.transform { (sequence) throws -> [SuccessValue.Element] in
            let array = try sequence.filter(isIncluded)
            return array
        }
        return future
    }
    
    public func first(where isIncluded: @escaping (SuccessValue.Element) throws -> Bool) -> FutureResult<SuccessValue.Element?> {
        let future = self.transform { (sequence) throws -> SuccessValue.Element? in
            let element = try sequence.first(where: isIncluded)
            return element
        }
        return future
    }

    @available(swift, deprecated: 4.1, renamed: "compactMap(_:)", message: "Please use compactMap(_:) for the case where closure returns an optional value")
    public func flatMap<T>(_ transform: @escaping (SuccessValue.Element) throws -> T?) -> FutureResult<[T]> {
        return self.compactMap(transform)
    }
    
    public func map<T>(_ transform: @escaping (SuccessValue.Element) throws -> T) -> FutureResult<[T]> {
        let future = self.transform { (sequence) throws -> [T] in
            let array = try sequence.map(transform)
            return array
        }
        return future
    }
    
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, SuccessValue.Element) throws -> T) -> FutureResult<T> {
        let future = self.transform { (sequence) throws -> T in
            let reduced = try sequence.reduce(initialResult, nextPartialResult)
            return reduced
        }
        return future
    }
    
}

public extension FutureResult where SuccessValue: Sequence, SuccessValue.Element: Sequence {
    public func flatMap<T>(_ transform: @escaping (SuccessValue.Element) -> [T]) -> FutureResult<[T]> {
        let future = self.transform { (sequence) -> [T] in
            let reduced = sequence.flatMap(transform)
            return reduced
        }
        return future
    }
}
