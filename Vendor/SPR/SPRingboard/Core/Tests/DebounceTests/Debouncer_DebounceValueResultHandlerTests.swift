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


class Debouncer_DebounceValueResultHandlerTests: XCTestCase {

    func testDebounceTriggersWhenIntervalElapses() {
        let debouncer = Debouncer(milliseconds: 10, queue: Helpers.debounceQueue)
        var handlerCalled = false
        var blockStart: TimeInterval = 0.0
        var blockStop: TimeInterval = 0.0
        
        // When I call debounce(_:completion:)
        blockStart = Date.timeIntervalSinceReferenceDate
        debouncer.debounce(1) { (result: Result<Int>) in
            blockStop = Date.timeIntervalSinceReferenceDate
            handlerCalled = true
        }
        
        // And I wait for the debounce interval to elapse
        Thread.sleep(forTimeInterval: TimeInterval.milliseconds(15))
        
        // Then the completion handler should be called
        XCTAssertTrue(handlerCalled)
        
        // And the interval between debounce() and the handler being called should be at least the dispatch interval
        let interval = blockStop - blockStart
        XCTAssertLessThanOrEqual(TimeInterval.milliseconds(10), interval)
        
        // And the interval between debounce() and the handler being called should not be more than the dispatch interval + 3ms
        XCTAssertGreaterThan(TimeInterval.milliseconds(13), interval)
    }

    func testDebounceResetsInterval() {
        let debouncer = Debouncer(milliseconds: 20, queue: Helpers.debounceQueue)
        var handler1Called = false
        var handler2Called = false
        var handler2Value: Int = -1
        var handler2Start: TimeInterval = 0.0
        var handler2Stop: TimeInterval = 0.0
        
        // When I call debounce(_:completion:)
        debouncer.debounce(1) { (result: Result<Int>) in
            handler1Called = true
        }
        
        // And I wait less than the debounce interval
        Thread.sleep(forTimeInterval: TimeInterval.milliseconds(10))
        
        // And I call debounce(_:completion:)
        handler2Start = Date.timeIntervalSinceReferenceDate
        debouncer.debounce(2) { (result: Result<Int>) in
            handler2Stop = Date.timeIntervalSinceReferenceDate
            handler2Called = true
            if case Result.success(let value) = result {
                handler2Value = value
            }
        }
        
        // And I wait for the debounce interval to elapse
        Thread.sleep(forTimeInterval: TimeInterval.milliseconds(25))
        
        // Then the first completion handler should NOT be called
        XCTAssertFalse(handler1Called)
        
        // And the second completion handler should be called
        XCTAssertTrue(handler2Called)
        
        // And the second completion handler should be called with the second value
        XCTAssertEqual(2, handler2Value)
        
        // And the debounce interval should elapse between the second debounce() and the second completion handler being called
        let interval = handler2Stop - handler2Start
        XCTAssertLessThanOrEqual(TimeInterval.milliseconds(20), interval)
    }

    func testDebouncePassesThroughInputValue() {
        let debouncer = Debouncer(milliseconds: 10, queue: Helpers.debounceQueue)
        var handlerSuccess = false
        var handlerValue: Int = -1
        
        // When I call debounce(_:completion:)
        debouncer.debounce(1) { (result: Result<Int>) in
            if case Result.success(let value) = result {
                handlerSuccess = true
                handlerValue = value
            }
        }
        
        // And I wait for the debounce interval to elapse
        Thread.sleep(forTimeInterval: TimeInterval.milliseconds(15))
        
        // Then the completion handler should be called with a success result
        XCTAssertTrue(handlerSuccess)
        
        // And the success result's value should equal the input value
        XCTAssertEqual(1, handlerValue)
    }
    
}
