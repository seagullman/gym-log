//
//  FutureSequenceTest.swift
//  DispatchTests
//
//  Created by Mikael Son on 9/6/17.
//

import XCTest
@testable import SPRingboard

class FutureSequenceTests: XCTestCase {

    func testFilter() {
        let expect = expectation(description: "async")
        var filteredSequence: [Int] = []
        
        // Given I have a future of a sequence
        let deferred = Deferred<[Int]>()
        
        // And the future is filled
        deferred.fill(value: [1,2,3,4,5,6])
        
        // When I call filter
        let filtered = deferred.filter { $0 > 3 }
        
        // Then the returned future should be filled
        filtered.then { (values) in
            filteredSequence = values
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        // And the returned future should only have values that passed
        // the filter
        // And the values should be in the original order
        XCTAssertEqual([4,5,6], filteredSequence)
    }
    
    func testFilterWithEmptySequence() {
        let expect = expectation(description: "async")
        var filteredSequence: [Int] = [1]
        
        // Given I have a future of a sequence
        let deferred = Deferred<[Int]>()
        
        // And the future is filled with an empty sequence
        deferred.fill(value: [])
        
        // When I call filter
        let filtered = deferred.filter { $0 > 3 }
        
        // Then the returned future should be filled
        filtered.then { (value) in
            filteredSequence = value
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        // And the returned future should be filled with an empty array
        XCTAssertEqual([], filteredSequence)
    }
    
    func testMap() {
        let expect = expectation(description: "async")
        var transformedSequence: [String] = []
        
        // Given I have a future of a sequence
        let deferred = Deferred<[Int]>()
        
        // And the future is filled
        deferred.fill(value: [1, 2, 3, 4])
        
        // When I call map
        let transformed = deferred.map { (value) -> String in
            return "\(value)"
        }
        
        // Then the returned future should be filled
        transformed.then { (values) in
            transformedSequence = values
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        // And the returned future should be filled with the transformed values
        // And the transformed values should be in the original order
        XCTAssertEqual(["1", "2", "3", "4"], transformedSequence)
    }
    
    func testMapWithEmptySequence() {
        let expect = expectation(description: "async")
        var transformedSequence: [String] = ["1"]
        
        // Given I have a future of a sequence
        let deferred = Deferred<[Int]>()
        
        // And the future is filled with an empty sequence
        deferred.fill(value: [])
        
        // When I call map
        let transformed = deferred.map { (value) -> String in
            return "\(value)"
        }
        
        // Then the returned future should be filled
        transformed.then { (values) in
            transformedSequence = values
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        // And the returned future should be filled with an empty array
        XCTAssertEqual([], transformedSequence)
    }
    
    func testFlatMap() {
        let expect = expectation(description: "async")
        var transformedSequence: [String] = []
        
        // Given I have a future of a sequence
        let deferred = Deferred<[Int]>()
        
        // And the future is filled
        deferred.fill(value: [1, 2, 3, 4])
        
        // When I call flatmap
        let transformed = deferred.compactMap { (value) -> String? in
            return "\(value)"
        }
        
        // Then the returned future should be filled
        transformed.then { (values) in
            transformedSequence = values
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        // And the returned future should be filled with the transformed values
        // And the transformed values should be in the original order
        XCTAssertEqual(["1", "2", "3", "4"], transformedSequence)
    }
    
    func testFlatMapWithEmptySequence() {
        let expect = expectation(description: "async")
        var transformedSequence: [String] = []
        
        // Given I have a future of a sequence
        let deferred = Deferred<[Int]>()
        
        // And the future is filled with an empty sequence
        deferred.fill(value: [1, 2, 3, 4])
        
        // When I call flatmap
        let transformed = deferred.compactMap { (value) -> String? in
            return "\(value)"
        }
        
        // Then the returned future should be filled
        transformed.then { (values) in
            transformedSequence = values
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        // And the returned future should be filled with an empty array
        XCTAssertEqual(["1", "2", "3", "4"], transformedSequence)
    }
    
    func testFlatMapWithNilTransformedSequence() {
        let expect = expectation(description: "async")
        var transformedSequence: [String] = []
        
        // Given I have a future of a sequence
        let deferred = Deferred<[Int]>()
        
        // And I have a transform function that returns some nil values
        let transform:(Int) -> String? = { (value) -> String? in
            if value % 2 == 0 {
                return nil
            } else {
                return "\(value)"
            }
        }
        
        // And the future is filled
        deferred.fill(value: [1, 2, 3, 4])
        
        // When I call flatmap with the transform function
        let transformed = deferred.compactMap(transform)
        
        // Then the returned future should be filled
        transformed.then { (values) in
            transformedSequence = values
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        // And the returned future should be filled with the non-nil transformed values
        // And the transformed values should be in the original order
        XCTAssertEqual(["1", "3"], transformedSequence)
    }

    func testFlatMapWithSequenceOfSequences() {
        let expect = expectation(description: "async")
        var transformedSequence: [Int] = []

        // Given I have a future of a sequence
        let deferred = Deferred<[[Int]]>()

        // And the future is filled
        deferred.fill(value: [[1, 2], [3, 4]])

        // When I call flatmap with the transform function
        let transformed = deferred.flatMap { $0 }

        // Then the returned future should be filled
        transformed.then { (values) in
            transformedSequence = values
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5)

        // And the returned future should be filled with the non-nil transformed values
        // And the transformed values should be in the original order
        XCTAssertEqual([1, 2, 3, 4], transformedSequence)
    }

    func testCompactMap() {
        let expect = expectation(description: "async")
        var transformedSequence: [String] = []

        // Given I have a future of a sequence
        let deferred = Deferred<[Int]>()

        // And the future is filled
        deferred.fill(value: [1, 2, 3, 4])

        // When I call compactMap
        let transformed = deferred.compactMap { (value) -> String? in
            return "\(value)"
        }

        // Then the returned future should be filled
        transformed.then { (values) in
            transformedSequence = values
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5)

        // And the returned future should be filled with the transformed values
        // And the transformed values should be in the original order
        XCTAssertEqual(["1", "2", "3", "4"], transformedSequence)
    }

    func testCompactMapWithEmptySequence() {
        let expect = expectation(description: "async")
        var transformedSequence: [String] = []

        // Given I have a future of a sequence
        let deferred = Deferred<[Int]>()

        // And the future is filled with an empty sequence
        deferred.fill(value: [1, 2, 3, 4])

        // When I call compactMap
        let transformed = deferred.compactMap { (value) -> String? in
            return "\(value)"
        }

        // Then the returned future should be filled
        transformed.then { (values) in
            transformedSequence = values
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5)

        // And the returned future should be filled with an empty array
        XCTAssertEqual(["1", "2", "3", "4"], transformedSequence)
    }

    func testCompactMapWithNilTransformedSequence() {
        let expect = expectation(description: "async")
        var transformedSequence: [String] = []

        // Given I have a future of a sequence
        let deferred = Deferred<[Int]>()

        // And I have a transform function that returns some nil values
        let transform:(Int) -> String? = { (value) -> String? in
            if value % 2 == 0 {
                return nil
            } else {
                return "\(value)"
            }
        }

        // And the future is filled
        deferred.fill(value: [1, 2, 3, 4])

        // When I call compactMap with the transform function
        let transformed = deferred.compactMap(transform)

        // Then the returned future should be filled
        transformed.then { (values) in
            transformedSequence = values
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5)

        // And the returned future should be filled with the non-nil transformed values
        // And the transformed values should be in the original order
        XCTAssertEqual(["1", "3"], transformedSequence)
    }
    
    func testReduce() {
        let expect = expectation(description: "async")
        var resultValue: Int = 0
        
        // Given I have a future of a sequence
        let deferred = Deferred<[Int]>()
        
        // And the future is filled
        deferred.fill(value: [1, 2, 3, 4])
        
        // When I call reduce
        let result = deferred.reduce(5) { (acc, val) -> Int in
            return acc + val
        }

        // Then the returned future should be filled
        result.then { (value) in
            resultValue = value
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        // And the returned future should be filled with the reduced value
        XCTAssertEqual(15, resultValue)
    }
    
    func testReduceWithEmptySequence() {
        let expect = expectation(description: "async")
        var resultValue: Int = 5
        
        // Given I have a future of a sequence
        let deferred = Deferred<[Int]>()
        
        // And the future is filled with an empty sequence
        deferred.fill(value: [])
        
        // When I call reduce
        let result = deferred.reduce(-123) { (acc, val) -> Int in
            return acc + val
        }
        
        // Then the returned future should be filled
        result.then { (value) in
            resultValue = value
            expect.fulfill()
        }
        waitForExpectations(timeout: 0.5)
        
        // And the returned future should be filled with the initial value
        XCTAssertEqual(-123, resultValue)
    }
    
}
