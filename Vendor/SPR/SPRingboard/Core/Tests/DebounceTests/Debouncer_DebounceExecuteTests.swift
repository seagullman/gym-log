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


class Debouncer_DebounceExecuteTests: XCTestCase {

    func testDebounceTriggersWhenIntervalElapses() {
        let debouncer = Debouncer(milliseconds: 10, queue: Helpers.debounceQueue)
        var blockCalled = false
        var blockStart: TimeInterval = 0.0
        var blockStop: TimeInterval = 0.0
        
        // When I call debounce(execute:)
        blockStart = Date.timeIntervalSinceReferenceDate
        debouncer.debounce {
            blockStop = Date.timeIntervalSinceReferenceDate
            blockCalled = true
        }
        
        // And I wait for the debounce interval to elapse
        Thread.sleep(forTimeInterval: TimeInterval.milliseconds(15))
        
        // Then the execute block should be called
        XCTAssertTrue(blockCalled)
        
        // And the interval between debounce(execute:) and the execute block being called should be at least the dispatch interval
        let interval = blockStop - blockStart
        XCTAssertLessThanOrEqual(TimeInterval.milliseconds(10), interval)
        
        // And the interval between debounce(execute:) and the execute block being called should not be more than the dispatch interval + 3ms
        XCTAssertGreaterThan(TimeInterval.milliseconds(13), interval)
    }
    
    func testDebounceResetsInterval() {
        let debouncer = Debouncer(milliseconds: 20, queue: Helpers.debounceQueue)
        var block1Called = false
        var block2Called = false
        var block2Start: TimeInterval = 0.0
        var block2Stop: TimeInterval = 0.0
        
        // When I call debounce(execute:)
        debouncer.debounce { block1Called = true }
        
        // And I wait less than the debounce interval
        Thread.sleep(forTimeInterval: TimeInterval.milliseconds(10))
        
        // And I call debounce(execute:)
        block2Start = Date.timeIntervalSinceReferenceDate
        debouncer.debounce { 
            block2Stop = Date.timeIntervalSinceReferenceDate
            block2Called = true 
        }
        
        // And I wait for the debounce interval to elapse
        Thread.sleep(forTimeInterval: TimeInterval.milliseconds(25))
        
        // Then the first execute block should NOT be called
        XCTAssertFalse(block1Called)
        
        // And the second execute block should be called
        XCTAssertTrue(block2Called)
        
        // And the debounce interval should elapse between the second debounce(execute:) and the second execute block being called
        let interval = block2Stop - block2Start
        XCTAssertLessThanOrEqual(TimeInterval.milliseconds(20), interval)
    }
        
}
