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

import XCTest
@testable import SPRingboard


class ResultTests: XCTestCase {

    func testSuccessWithClass() {
        // Setup
        
        let input = ExampleClass(id: 13579)
        
        // Action
        
        let result: Result<ExampleClass> = .success(input)
        
        // Assertions
        
        if case Result.success(let value) = result {
            XCTAssertEqual(13579, value.id)
        } else {
            XCTFail("Result is not a success")
        }
    }

    func testSuccessWithStruct() {
        // Setup
        
        let input = ExampleStruct(id: 24680)
        
        // Action
        
        let result: Result<ExampleStruct> = .success(input)
        
        // Assertions
        
        if case Result.success(let value) = result {
            XCTAssertEqual(24680, value.id)
        } else {
            XCTFail("Result is not a success")
        }
    }

    func testSuccessWithEnum() {
        // Setup
        
        // Using a closure (rather than simply setting input=ExampleEnum.bravo) 
        // is necessary to suppress compiler warnings because otherwise the 
        // compiler is smart enough to realize that the `if` is always true and 
        // the `switch` is always `.bravo`. 
        let input = { return ExampleEnum.bravo }()
        
        // Action
        
        let result: Result<ExampleEnum> = .success(input)
        
        // Assertions
        
        if case Result.success(let value) = result {
            switch value {
            case .bravo:
                XCTAssertTrue(true)
            default:
                XCTFail("ExampleEnum value was expected to be .bravo")
            }
        } else {
            XCTFail("Result is not a success")
        }
    }

    func testSuccessWithArray() {
        // Setup
        
        let input = [13, 8, 5, 3, 2, 1, 1, 0]
        
        // Action
        
        let result: Result<[Int]> = .success(input)
        
        // Assertions
        
        if case Result.success(let value) = result {
            XCTAssertEqual(8, value.count)
            
            XCTAssertEqual(13, value[0])
            XCTAssertEqual( 8, value[1])
            XCTAssertEqual( 5, value[2])
            XCTAssertEqual( 3, value[3])
            XCTAssertEqual( 2, value[4])
            XCTAssertEqual( 1, value[5])
            XCTAssertEqual( 1, value[6])
            XCTAssertEqual( 0, value[7])
        } else {
            XCTFail("Result is not a success")
        }
    }

    func testSuccessWithOptionalPresent() {
        // Setup
        
        let input: Int? = 2
        
        // Action
        
        let result: Result<Int?> = .success(input)
        
        // Assertions
        
        if case Result.success(let value) = result {
            XCTAssertEqual(2, value)
        } else {
            XCTFail("Result is not a success")
        }
    }

    func testSuccessWithOptionalNil() {
        // Setup
        
        let input: Int? = nil
        
        // Action
        
        let result: Result<Int?> = .success(input)
        
        // Assertions
        
        if case Result.success(let value) = result {
            XCTAssertNil(value)
        } else {
            XCTFail("Result is not a success")
        }
    }

    func testFailureWithError() {
        // Setup
        
        // Action
        
        let result: Result<Int> = .failure(ExampleError.error3)
        
        // Assertions
        
        if case Result.failure(let error) = result {
            if case ExampleError.error3 = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Error was expected to be ExampleError.error3")
            }
        } else {
            XCTFail("Result was not failure")
        }
    }
    
    // MARK: - init(value:error:)
    
    func testInitWithValueCreatedSuccess() {
        // Setup
        
        let inputValue: String = "13213"
        
        // Action
        
        let result: Result<String>
        do {
            result = try Result.init(value: inputValue, error: nil)
        } catch {
            XCTFail("Result initialization threw Error")
            return
        }
        
        // Assertions
        
        if case Result.success(let value) = result {
            XCTAssertEqual(inputValue, value)
        } else {
            XCTFail("Result was not success")
        }
    }
    
    func testInitWithErrorCreatedFailure() {
        // Setup

        // Action
        
        let result: Result<String?>
        do {
            result = try Result.init(value: nil, error: ExampleError.error1)
        } catch {
            XCTFail("Result initialization threw ERror")
            return
        }

        // Assertions
        
        if case Result.failure(let error) = result {
            if case ExampleError.error1 = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Error was expected to be ExampleError.error1")
            }
        } else {
            XCTFail("Result was not failure")
        }
    }
    
    func testInitWithValueAndErrorCreatesFailure() {
        // Setup
        
        let inputValue: String = "58272"
        
        // Action
        
        let result: Result<String?>
        do {
            result = try Result.init(value: inputValue, error: ExampleError.error1)
        } catch {
            XCTFail("Result initialization threw Error")
            return
        }
        
        // Assertions
        
        if case Result.failure(let error) = result {
            if case ExampleError.error1 = error {
                XCTAssertTrue(true)
            } else {
                XCTFail("Error was expected to be ExampleError.error1")
            }
        } else {
            XCTFail("Result was not failure")
        }
    }
    
    func testInitWithoutValueAndErrorThrowsError() {
        // Action & Assertions
        
        do {
            let _: Result<Int> = try Result.init(value: nil, error: nil)
            XCTFail("Result initialization expected to throw Error")
        } catch (let error) {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - debugDescription
    
    func testSuccessDebugDescription() {
        // Setup
        let result: Result<String> = .success("I am a teapot")
        
        // Actions
        let debugString = result.debugDescription
        
        // Assertions
        XCTAssertTrue(debugString.hasPrefix("Result(.success"))
        XCTAssertTrue(debugString.contains("I am a teapot"))
        XCTAssertTrue(debugString.hasSuffix(")"))
    }
    
    func testFailureDebugDescription() {
        // Setup
        let result: Result<String> = .failure(ExampleError.error2)
        
        // Actions
        let debugString = result.debugDescription
        
        // Assertions
        XCTAssertTrue(debugString.hasPrefix("Result(.failure"))
        XCTAssertTrue(debugString.contains("ExampleError"))
        XCTAssertTrue(debugString.contains("error2"))
        XCTAssertTrue(debugString.hasSuffix(")"))
    }
    
    // MARK: - Helper Classes
    
    private class ExampleClass {
        public let id: Int
        public init(id: Int) {
            self.id = id
        }
    }
    
    private struct ExampleStruct {
        public let id: Int
    }
    
    private enum ExampleEnum {
        case alpha
        case bravo
        case charlie
    }
    
    private enum ExampleError: Error {
        case error1
        case error2
        case error3
    }
    
}
