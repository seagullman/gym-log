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


public extension Future where Value: Sequence {
    
    public func compactMap<T>(_ transform: @escaping (Value.Element) -> T?) -> Future<[T]> {
        let future = self.transform { (sequence) -> [T] in
            let array = sequence.compactMap(transform)
            return array
        }
        return future
    }

    public func filter(_ isIncluded: @escaping (Value.Element) -> Bool) -> Future<[Value.Element]> {
        let future = self.transform { (sequence) -> [Value.Element] in
            let array = sequence.filter(isIncluded)
            return array
        }
        return future
    }
    
    @available(swift, deprecated: 4.1, renamed: "compactMap(_:)", message: "Please use compactMap(_:) for the case where closure returns an optional value")
    public func flatMap<T>(_ transform: @escaping (Value.Element) -> T?) -> Future<[T]> {
        return self.compactMap(transform)
    }
    
    public func map<T>(_ transform: @escaping (Value.Element) -> T) -> Future<[T]> {
        let future = self.transform { (sequence) -> [T] in
            let array = sequence.map(transform)
            return array
        }
        return future
    }
    
    public func reduce<T>(_ initialResult: T, _ nextPartialResult: @escaping (T, Value.Element) -> T) -> Future<T> {
        let future = self.transform { (sequence) -> T in
            let reduced = sequence.reduce(initialResult, nextPartialResult)
            return reduced
        }
        return future
    }
    
}

public extension Future where Value: Sequence, Value.Element: Sequence {
    public func flatMap<T>(_ transform: @escaping (Value.Element) -> [T]) -> Future<[T]> {
        let future = self.transform { (sequence) -> [T] in
            let reduced = sequence.flatMap(transform)
            return reduced
        }
        return future
    }
}
