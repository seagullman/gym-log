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

#if GRDBCIPHER

import Foundation
import GRDBCipher


public class GRDBCipherSQLiteAdapter: SQLiteAdapter {

    // MARK: Properties

    private var dbQueue: DatabaseQueue? = nil
    private var trace: Bool = false

    // MARK: Init / Deinit

    public init() { }

    // MARK: SQLiteAdapter

    public var changesCount: Int {
        guard let dbQueue = self.dbQueue else { return -1 }

        var count: Int = -2
        do {
            try dbQueue.inDatabase { (db) throws -> Void in
                count = db.changesCount
            }
        } catch {
            count = -3
        }

        return count
    }

    public var lastInsertRowID: Int64 {
        guard let dbQueue = self.dbQueue else { return -1 }

        var lastID: Int64 = -2
        do {
            try dbQueue.inDatabase { (db) throws -> Void in
                lastID = db.lastInsertedRowID
            }
        } catch {
            lastID = -3
        }

        return lastID
    }

    public let supportsEncryption: Bool = true

    public func openFile(path: String) throws {
        var config: Configuration = Configuration()
        config.foreignKeysEnabled = false
        config.trace = (self.trace) ? { print($0) } : nil

        self.dbQueue = try DatabaseQueue.init(path: path, configuration: config)
    }

    public func openFile(path: String, encryptionKey: String) throws {
        var config: Configuration = Configuration()
        config.foreignKeysEnabled = false
        config.passphrase = encryptionKey
        config.trace = (self.trace) ? { print($0) } : nil

        self.dbQueue = try DatabaseQueue.init(path: path, configuration: config)
    }

    public func openInMemory() throws {
        var config: Configuration = Configuration()
        config.foreignKeysEnabled = false
        config.trace = (self.trace) ? { print($0) } : nil

        self.dbQueue = try DatabaseQueue.init(path: ":memory:", configuration: config)
    }

    public func openTemporaryFile() throws {
        var config: Configuration = Configuration()
        config.foreignKeysEnabled = false
        config.trace = (self.trace) ? { print($0) } : nil

        self.dbQueue = try DatabaseQueue.init(path: "", configuration: config)
    }

    public func close() throws {
        self.dbQueue = nil
    }

    public func executeQuery(_ statement: String, rowHandler: RowHandler) throws {
        guard let dbQueue = self.dbQueue else {
            throw SQLiteAdapterError.operationRequiresConnection
        }

        try dbQueue.inDatabase { (db) throws -> Void in
            let selectStatement = try db.cachedSelectStatement(statement)

            let cursor = try Row.fetchCursor(selectStatement)
            try self.processCursor(cursor, withRowHandler: rowHandler)
        }
    }

    public func executeQuery(_ statement: String, parameters: [String : Any?], rowHandler: RowHandler) throws {
        guard let dbQueue = self.dbQueue else {
            throw SQLiteAdapterError.operationRequiresConnection
        }

        let arguments = try self.makeStatementArguments(parameters: parameters)
        try dbQueue.inDatabase { (db) throws -> Void in
            let selectStatement = try db.cachedSelectStatement(statement)
            selectStatement.arguments = arguments

            let cursor = try Row.fetchCursor(selectStatement)
            try self.processCursor(cursor, withRowHandler: rowHandler)
        }
    }

    public func executeStatement(_ statement: String) throws -> Int {
        guard let dbQueue = self.dbQueue else {
            throw SQLiteAdapterError.operationRequiresConnection
        }

        var changesCount: Int = 0
        try dbQueue.inDatabase { (db) throws -> Void in
            try db.execute(statement)
            changesCount = db.changesCount
        }

        return changesCount
    }

    public func executeStatement(_ statement: String, parameters: [String : Any?]) throws -> Int {
        guard let dbQueue = self.dbQueue else {
            throw SQLiteAdapterError.operationRequiresConnection
        }

        var changesCount: Int = 0
        let arguments = try self.makeStatementArguments(parameters: parameters)
        try dbQueue.inDatabase { (db) throws -> Void in
            try db.execute(statement, arguments: arguments)
            changesCount = db.changesCount
        }

        return changesCount
    }

    public func enableTracing() {
        self.trace = true
    }

    public func disableTracing() {
        self.trace = false
    }

    // MARK: Private

    private func makeStatementArguments(parameters: [String: Any?]) throws -> StatementArguments {
        var convertablesByName: [String: DatabaseValueConvertible?] = [:]
        for (name, anyValue) in parameters {
            if anyValue == nil {
                convertablesByName[name] = nil
            } else if let convertableValue = anyValue as? DatabaseValueConvertible {
                convertablesByName[name] = convertableValue
            } else {
                throw SQLiteAdapterError.invalidParameter(name: name, value: anyValue)
            }
        }

        let arguments = StatementArguments(convertablesByName)
        return arguments
    }

    private func processCursor(_ cursor: RowCursor, withRowHandler handler: RowHandler) throws {
        while let row = try cursor.next() {
            var dictionary: [String: Any?] = [:]
            for (columnName, dbValue) in row {
                dictionary[columnName] = dbValue
            }
            try handler(dictionary)
        }
    }

}

#endif

