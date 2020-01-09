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

import XCTest
@testable import SPRingboard


class FutureResultWaitTests: XCTestCase {
    
    func testWait2_FilledSuccess() {
        // Setup
        
        let frA: FutureResult<Int> = DeferredResult<Int>(value: 123)
        let frB: FutureResult<Double> = DeferredResult<Double>(value: 3.14159)
        
        // Action
        
        let expectation: XCTestExpectation = self.expectation(description: "Asynchronous task completes")
        
        let frWait: FutureResult<(a:Int, b:Double)> = SPRingboard.wait(a: frA, b: frB)
        frWait.then { (resultAB: Result<(a: Int, b: Double)>) in
            
            // Asserts
            
            guard case .success((a: let alpha, b: let bravo)) = resultAB else {
                XCTFail("Result is not success")
                expectation.fulfill()
                return
            }
            
            XCTAssertEqual(123, alpha)
            XCTAssertEqual(3.14159, bravo, accuracy: 0.00001)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 0.1)
    }
    
    func testWait3_FilledSuccess() {
        // Setup
        
        let frA: FutureResult<Int> = DeferredResult<Int>(value: 123)
        let frB: FutureResult<Double> = DeferredResult<Double>(value: 3.14159)
        let frC: FutureResult<String> = DeferredResult<String>(value: "Example")

        // Action
        
        let expectation: XCTestExpectation = self.expectation(description: "Asynchronous task completes")
        
        let frWait = SPRingboard.wait(a: frA, b: frB, c: frC)
        frWait.then { (resultABC: Result<(a: Int, b: Double, c: String)>) in
            
            // Asserts
            
            guard case .success((a: let alpha, b: let bravo, c: let charlie)) = resultABC else {
                XCTFail("Result is not success")
                expectation.fulfill()
                return
            }
            
            XCTAssertEqual(123, alpha)
            XCTAssertEqual(3.14159, bravo, accuracy: 0.00001)
            XCTAssertEqual("Example", charlie)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 0.1)
    }
    
    func testWait4_FilledSuccess() {
        // Setup
        
        let frA: FutureResult<Int> = DeferredResult<Int>(value: 123)
        let frB: FutureResult<Double> = DeferredResult<Double>(value: 3.14159)
        let frC: FutureResult<String> = DeferredResult<String>(value: "Example")
        let frD: FutureResult<Bool> = DeferredResult<Bool>(value: true)

        // Action
        
        let expectation: XCTestExpectation = self.expectation(description: "Asynchronous task completes")
        
        let frWait = SPRingboard.wait(a: frA, b: frB, c: frC, d: frD)
        frWait.then { (resultABCD: Result<(a: Int, b: Double, c: String, d: Bool)>) in
            
            // Asserts
            
            guard case .success((a: let alpha, b: let bravo, c: let charlie, d: let delta)) = resultABCD else {
                XCTFail("Result is not success")
                expectation.fulfill()
                return
            }
            
            XCTAssertEqual(123, alpha)
            XCTAssertEqual(3.14159, bravo, accuracy: 0.00001)
            XCTAssertEqual("Example", charlie)
            XCTAssertEqual(true, delta)
            expectation.fulfill()
        }
        self.waitForExpectations(timeout: 0.1)
    }

}
