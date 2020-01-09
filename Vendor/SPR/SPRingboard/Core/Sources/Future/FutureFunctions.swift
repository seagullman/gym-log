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


public extension SPRingboard {
    
    /// Create a future that is filled when two other futures are filled. The
    /// returned future fills with a tuple containing the values that filled
    /// the provided futures.
    public static func wait<A,B>(a: Future<A>, b: Future<B>) -> Future<(a:A,b:B)> {
        let deferred = Deferred<(a:A,b:B)>()
        
        a.then { (valueA: A) in
            b.then { (valueB: B) in
                let tuple = (a: valueA, b: valueB)
                deferred.fill(value: tuple)
            }
        }
        
        return deferred
    }
    
    /// Create a future that is filled when three other futures are filled. The
    /// returned future fills with a tuple containing the values that filled
    /// the provided futures.
    public static func wait<A,B,C>(a: Future<A>, b: Future<B>, c: Future<C>) -> Future<(a:A,b:B,c:C)> {
        let deferred = Deferred<(a:A,b:B,c:C)>()
        
        a.then { (valueA: A) in
            b.then { (valueB: B) in
                c.then { (valueC: C) in
                    let tuple = (a: valueA, b: valueB, c: valueC)
                    deferred.fill(value: tuple)
                }
            }
        }
        
        return deferred
    }
    
}
