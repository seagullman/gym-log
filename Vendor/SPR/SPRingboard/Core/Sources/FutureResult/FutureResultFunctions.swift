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
    
    /// Create a `FutureResult` that is filled when both parameters are filled
    /// with success.
    ///
    /// If either parameter fails, the returned `FutureResult` fails with the
    /// same error. If both parameters fail, it is undefined which failure will
    /// fill the returned `FutureResult`.
    public static func wait<A,B>(a: FutureResult<A>, b: FutureResult<B>) -> FutureResult<(a:A,b:B)> {
        let deferred = DeferredResult<(a:A,b:B)>()
        
        a.then { (resultA: Result<A>) in
            switch resultA {
            case .failure(let error):
                deferred.fill(result: .failure(error))
            case .success(let valueA):
                b.then { (resultB: Result<B>) in
                    switch resultB {
                    case .failure(let error):
                        deferred.fill(result: .failure(error))
                    case .success(let valueB):
                        let tuple = (a: valueA, b: valueB)
                        deferred.success(value: tuple)
                    }
                }
            }
        }
        
        return deferred
    }


    /// Create a `FutureResult` that is filled when all parameters are filled
    /// with success.
    ///
    /// If any parameter fails, the returned `FutureResult` fails with the same
    /// error. If multiple parameters fail, it is undefined which failure will
    /// fill the returned `FutureResult`.
    public static func wait<A,B,C>(a: FutureResult<A>, b: FutureResult<B>, c: FutureResult<C>) -> FutureResult<(a:A,b:B,c:C)> {
        let deferred = DeferredResult<(a:A,b:B,c:C)>()
        
        a.then { (resultA: Result<A>) in
            switch resultA {
            case .failure(let error):
                deferred.fill(result: .failure(error))
            case .success(let valueA):
                b.then { (resultB: Result<B>) in
                    switch resultB {
                    case .failure(let error):
                        deferred.fill(result: .failure(error))
                    case .success(let valueB):
                        c.then { (resultC: Result<C>) in
                            switch resultC {
                            case .failure(let error):
                                deferred.fill(result: .failure(error))
                            case .success(let valueC):
                                let tuple = (a: valueA, b: valueB, c: valueC)
                                deferred.success(value: tuple)
                            }
                        }
                    }
                }
            }
        }
        
        return deferred
    }


    /// Create a `FutureResult` that is filled when all four parameters are
    /// filled with success.
    ///
    /// If any parameter fails, the returned `FutureResult` fails with the
    /// same error. If multiple parameters fail, it is undefined which failure
    /// will fill the returned `FutureResult`.
    public static func wait<A,B,C,D>(a: FutureResult<A>, b: FutureResult<B>, c: FutureResult<C>, d: FutureResult<D>) -> FutureResult<(a:A,b:B,c:C,d:D)> {
        /// Developer's note:
        ///
        /// This function was created as a template to show how `wait` can be
        /// implemented for an arbitrary number of parameters by delegating
        /// to other `wait` functions. For brevity, `wait/N` will mean "a
        /// `wait` function that takes `N` parameters"; for example, this
        /// function is `wait/4`.
        ///
        /// The template is to call two other `wait` functions and combine
        /// the results using a call to `wait/2`. For example, this `wait/4`
        /// implementation calls `wait/2` with the first two parameters and
        /// `wait/2` with the last 2 parameters, then combines them with a
        /// final call to `wait/2`. To implement `wait/5`, you would call
        /// `wait/3` with the first 3 parameters and `wait/2` with the last 2
        /// parameters, then combine those using `wait/2`. To implement
        /// `wait/10`, you would create `wait/5` as described, then call it
        /// twice (once with the first 5 parameters, second with the last 5
        /// parameters), and finially combine the results with `wait/2`.
        
        let deferred = DeferredResult<(a:A,b:B,c:C,d:D)>()
        
        let frAB = wait(a: a, b: b)
        let frCD = wait(a: c, b: d)
        wait(a: frAB, b: frCD).then { (result: Result<(a: (a: A, b: B), b: (a: C, b: D))>) in
            switch result {
            case .success(let (a: (a: alpha, b: bravo), b: (a: charlie, b: delta))):
                let tuple = (a: alpha, b: bravo, c: charlie, d: delta)
                deferred.success(value: tuple)
            case .failure(let error):
                deferred.failure(error: error)
            }
        }
        
        return deferred
    }
    
}

