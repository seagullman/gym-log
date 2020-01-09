//
//  DeferredTests.swift
//  DispatchTests
//
//  Created by Mikael Son on 9/5/17.
//

import XCTest
@testable import SPRingboard

class DeferredTests: XCTestCase {
    
    func testDeferredOneCompletionHandler() {
        var outValue = -1
        var blockCalled = false
        let expectation = self.expectation(description: "Async")
        
        // Given I have a Deferred
        let deferred = Deferred<Int>()
        
        // And I add a completion handler
        deferred.then(upon: .global()) { i in
            outValue = i
            blockCalled = true
            expectation.fulfill()
        }
        
        // When I fill the Deferred
        deferred.fill(value: 1)
        waitForExpectations(timeout: 0.5)
        
        // Then the completion handler should be called
        XCTAssertTrue(blockCalled)
        
        // And the completion handler should receive the filled value
        XCTAssertEqual(1, outValue)
    }
    
    func testDeferredTwoCompletionHandler() {
        var outValue1 = -1
        var outValue2 = -1
        var block1Called = false
        var block2Called = false
        let expectation1 = self.expectation(description: "Async1")
        let expectation2 = self.expectation(description: "Async2")
        
        // Given I have a Deferred
        let deferred = Deferred<Int>()
        
        // When I add a completion handler
        deferred.then(upon: .global()) { i in
            outValue1 = i
            block1Called = true
            expectation1.fulfill()
        }
        
        // And I add a second completion handler
        deferred.then(upon: .global()) { Int in
            outValue2 = Int
            block2Called = true
            expectation2.fulfill()
        }
        
        // And I fill the Deferred
        deferred.fill(value: 1)
        waitForExpectations(timeout: 0.5)
        
        // Then both completion handlers should be called
        XCTAssertTrue(block1Called)
        XCTAssertTrue(block2Called)
        
        // And both completion handlers should receive the filled value
        XCTAssertEqual(1, outValue1)
        XCTAssertEqual(1, outValue2)
    }
    
}
