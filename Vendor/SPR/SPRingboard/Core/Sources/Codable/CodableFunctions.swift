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

import Foundation


public extension SPRingboard {

    public typealias JSONObject = [String: Any?]
    public typealias JSONArray = [JSONObject]

    public enum JSONError: Swift.Error {
        case unexpectedType(Any)
    }

    public static func fromJSONArray<T>(_ jsonArray: JSONArray, toArrayOf type: T.Type) throws -> [T] where T: Decodable {
        var array: [T] = []

        for jsonObject in jsonArray {
            let object = try SPRingboard.fromJSONObject(jsonObject, to: type)
            array.append(object)
        }

        return array
    }

    public static func fromJSONObject<T>(_ jsonObject: JSONObject, to type: T.Type) throws -> T where T: Decodable {
        let plistData: Data = try PropertyListSerialization.data(fromPropertyList: jsonObject, format: .binary, options: 0)
        let decoder = PropertyListDecoder()
        let object = try decoder.decode(type, from: plistData)
        return object
    }

    public static func toJSONArray<T>(_ values: [T]) throws -> [[String: Any]] where T: Encodable {
        let array: [[String: Any]]

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary

        let plistData: Data = try encoder.encode(values)
        let plistAny: Any = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil)

        if let plistArray = plistAny as? [[String: Any]] {
            array = plistArray
        } else {
            throw JSONError.unexpectedType(plistAny)
        }

        return array
    }

    public static func toJSONObject<T>(_ value: T) throws -> [String: Any] where T: Encodable {
        let dictionary: [String: Any]

        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary

        let plistData: Data = try encoder.encode(value)
        let plistAny: Any = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil)

        if let plistDict = plistAny as? [String: Any] {
            dictionary = plistDict
        } else {
            throw JSONError.unexpectedType(plistAny)
        }

        return dictionary
    }

}
