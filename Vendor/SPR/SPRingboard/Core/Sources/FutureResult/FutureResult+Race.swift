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


public extension FutureResult {
    
    /// Creates a future that is filled with the first result to fill any of
    /// the provided futures.
    ///
    /// If multiple futures have been filled before this method is called, it
    /// is indeterminate which future's result will fill the returned future.
    public static func race<A>(_ futures: [FutureResult<A>]) -> FutureResult<A> {
        let deferred = DeferredResult<A>()
        
        for future in futures {
            future.then { (result: Result<A>) in
                // fill the deferred if it not already filled, but do not treat
                // attempting to fill it multiple times as an error (specified
                // by passing `nil` to the otherwise parameter)
                deferred.fill(result: result, otherwise: nil)
            }
        }
        
        return deferred
    }
    
    /// Convenience function for racing two `FutureResult`s.
    public static func race<A>(_ first: FutureResult<A>, _ second: FutureResult<A>) -> FutureResult<A> {
        let future = FutureResult.race([first, second])
        return future
    }
    
}
