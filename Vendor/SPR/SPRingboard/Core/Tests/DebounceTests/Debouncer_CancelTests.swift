// SPRingboard Tests
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
import XCTest
@testable import SPRingboard


class Debouncer_CancelTests: XCTestCase {

    func testCancelBeforeDebounceIsIgnored() {
        let debouncer = Debouncer(milliseconds: 5, queue: Helpers.debounceQueue)
        var blockCalled = false
        
        // When I call cancel()
        debouncer.cancel()
        
        // And I call debounce(execute:)
        debouncer.debounce {
            blockCalled = true
        }
        
        // And I wait for the debounce interval to elapse
        Thread.sleep(forTimeInterval: TimeInterval.milliseconds(10))
        
        // Then the execute block should be called
        XCTAssertTrue(blockCalled)
    }
    
    func testCancelDuringDebounceIntervalPreventsBlockFromBeingCalled() {
        let debouncer = Debouncer(milliseconds: 5, queue: Helpers.debounceQueue)
        var blockCalled = false
        
        // When I call debounce(execute:)
        debouncer.debounce {
            blockCalled = true
        }
        
        // And I call cancel()
        debouncer.cancel()
        
        // And I wait for the debounce interval to elapse
        Thread.sleep(forTimeInterval: TimeInterval.milliseconds(10))
        
        // Then the execute block should NOT be called
        XCTAssertFalse(blockCalled)
    }
    
    func testCancelAfterDebounceIntervalIsIgnored() {
        let debouncer = Debouncer(milliseconds: 5, queue: Helpers.debounceQueue)
        var blockCalled = false
        
        // When I call debounce(execute:)
        debouncer.debounce {
            blockCalled = true
        }
        
        // And I wait for the debounce interval to elapse
        Thread.sleep(forTimeInterval: TimeInterval.milliseconds(10))
        
        // And I call cancel()
        debouncer.cancel()
        
        // Then the execute block should be called
        XCTAssertTrue(blockCalled)
    }
    
}
