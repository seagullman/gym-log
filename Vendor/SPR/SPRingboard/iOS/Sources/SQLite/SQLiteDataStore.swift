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


public class SQLiteDataStore {

    // MARK: Types

    public typealias RowHandler = SQLiteAdapter.RowHandler

    public enum Error: Swift.Error {
        case dataStoreAlreadyConnected
        case invalidDatabaseName(String)
        case operationRequiresConnection
        case operationRequiresSQLiteFile
        case unableToCreateDirectory
    }

    public enum StorageType {
        case file(basename: String)
        case memory
        case temporary
    }

    // MARK: Properties

    private let adapter: SQLiteAdapter
    private let keySource: SQLiteDataStoreKeySource?
    private let migrationSource: SQLiteDataStoreMigrationSource
    private let type: StorageType

    // Memoized values
    private var dbDirectoryURL: URL? = nil
    private var dbFileURL: URL? = nil

    private var connected: Bool

    public let name: String?

    public var changesCount: Int {
        return self.adapter.changesCount
    }
    
    public var lastInsertRowID: Int64 {
        return self.adapter.lastInsertRowID
    }

    // MARK: Init / Deinit

    public init(
        adapter: SQLiteAdapter,
        type: StorageType,
        keySource: SQLiteDataStoreKeySource? = nil,
        migrationSource: SQLiteDataStoreMigrationSource = DefaultSQLiteDataStoreMigrationSource()
    ) {
        self.adapter = adapter
        self.type = type
        self.keySource = keySource
        self.migrationSource = migrationSource

        if case let .file(basename: name) = type {
            self.name = name
        } else {
            self.name = nil
        }

        self.connected = false
    }

    deinit {
        if self.connected {
            try? self.disconnect()
        }
    }

    // MARK: SQLiteDataStore (Connection Lifecycle)

    public func connect() throws {
        guard !self.connected else {
            throw Error.dataStoreAlreadyConnected
        }

        try self.openDatabase()
        try self.migrateDatabase()

        self.connected = true
    }

    public func disconnect() throws {
        guard self.connected else { return }

        try self.adapter.close()
        self.connected = false
    }

    // MARK: Operations

    public func destroy() throws {
        // Vacuum the database to remove extra files (e.g., for WAL) so that
        // removing the primary SQLite file will remove "everything".
        if !self.connected {
            try self.connect()
        }
        try self.vacuum()

        // Close the database connection so that we do not have a file handle
        // open when we delete the file.
        try self.disconnect()

        // Delete the database file
        let fileURL = try self.databaseFileURL()
        let fileManager = FileManager.default
        try fileManager.removeItem(at: fileURL)

        // Delete the encryption key
        try self.keySource?.destroyKeyForDataStore(self)
    }

    public func executeQuery(_ statement: String, rowHandler: RowHandler) throws {
        guard self.connected else { throw Error.operationRequiresConnection }
        try self.adapter.executeQuery(statement, rowHandler: rowHandler)
    }

    public func executeQuery(_ statement: String, parameters: [String: Any?], rowHandler: RowHandler) throws {
        guard self.connected else { throw Error.operationRequiresConnection }
        try self.adapter.executeQuery(statement, parameters: parameters, rowHandler: rowHandler)
    }

    @discardableResult public func executeStatement(_ statement: String) throws -> Int {
        guard self.connected else { throw Error.operationRequiresConnection }
        try self.adapter.executeStatement(statement)
        return self.changesCount
    }

    @discardableResult public func executeStatement(_ statement: String, parameters: [String: Any?]) throws -> Int {
        guard self.connected else { throw Error.operationRequiresConnection }
        try self.adapter.executeStatement(statement, parameters: parameters)
        return self.changesCount
    }

    public func executeStatementsInFileAtURL(_ url: URL, separator: Character) throws {
        guard self.connected else { throw Error.operationRequiresConnection }

        let content = try String(contentsOf: url, encoding: .utf8)
        let statements = content.split(separator: separator)
        for rawStatement in statements {
            let statement = rawStatement.trimmingCharacters(in: .whitespacesAndNewlines)
            if !statement.isEmpty {
                try self.executeStatement(statement)
            }
        }
    }

    public func vacuum() throws {
        guard self.connected else { throw Error.operationRequiresConnection }
        try self.adapter.executeStatement("VACUUM")
    }

    // MARK: Private (Connect)

    private func openDatabase() throws {
        switch self.type {
        case .file(basename: let name):
            try self.connectToDatabaseFile(name: name)
        case .memory:
            try self.adapter.openInMemory()
        case .temporary:
            try self.adapter.openTemporaryFile()
        }

        try self.migrateDatabase()
    }

    private func connectToDatabaseFile(name: String) throws {
        guard
            !name.isEmpty,        // require at least one character
            !name.contains("/"),  // forbid filenames that would generate subdirectories
            !name.contains("."),  // forbid filenames from containing extension separators
            name == name.trimmingCharacters(in: .whitespacesAndNewlines) // forbid leading or trailing spaces
        else {
            throw Error.invalidDatabaseName(name)
        }

        // Create the directory to hold the SQLite file, if missing
        try self.createDatabaseDirectory()

        // Exclude the directory and its contents from backups to iTunes or
        // iCloud
        try self.excludeDatabaseDirectoryFromBackup()

        // Determine the full path to the database file
        let fileURL = try self.databaseFileURL()
        let filePath = fileURL.path

        // Open the database
        if self.adapter.supportsEncryption, let keySource = self.keySource {
            // Open an encrypted database
            let key = try keySource.keyForDataStore(self)
            try self.adapter.openFile(path: filePath, encryptionKey: key)
        } else {
            // Open a normal database
            try self.adapter.openFile(path: filePath)
        }
    }

    private func migrateDatabase() throws {
        // Extract the current database schema version
        var userVersion: Int? = nil
        try self.executeQuery("PRAGMA user_version") { (row) in
            userVersion = row.values.first as? Int
        }

        // Apply any pending migrations

        // Load the migration statements
        let statements: [String]
        if let schemaVersion = userVersion {
            statements = try self.migrationSource.statementsToMigrateFromSchemaVersion(schemaVersion)
        } else {
            statements = try self.migrationSource.allStatements()
        }
        // Execute the migration statements
        for statement in statements {
            try self.executeStatement(statement)
        }

        // Update the database schema version
        let version = self.migrationSource.migrationCount - 1
        try self.executeStatement("PRAGMA user_version = :version", parameters: ["version": version])
    }

    // MARK: Private (File Management)

    private func createDatabaseDirectory() throws {
        let directoryURL = try self.databaseDirectoryURL()

        let fileManager = FileManager.default
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
    }

    private func databaseDirectoryURL() throws -> URL {
        // Return memoized value, if available
        if let url = self.dbDirectoryURL { return url }

        let fileManager = FileManager.default

        // Get the URL to the "Application Support" directory
        let appSupportURLs = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        guard let appSupportURL = appSupportURLs.first else {
            throw Error.unableToCreateDirectory
        }

        // Get the URL to the "SQLite" directory under "Application Support"
        let dirURL = appSupportURL.appendingPathComponent("SQLite", isDirectory: true)

        // Memoize value for future use
        self.dbDirectoryURL = dirURL

        return dirURL
    }

    private func databaseFileURL() throws -> URL {
        // Return memoized value, if available
        if let url = self.dbFileURL { return url }

        guard case let .file(basename: name) = self.type else {
            throw Error.operationRequiresSQLiteFile
        }

        let parentDirectory = try self.databaseDirectoryURL()
        let filename = self.filenameForDatabaseName(name)
        let fileURL = parentDirectory.appendingPathComponent(filename, isDirectory: false)

        // Memoize value for future use
        self.dbFileURL = fileURL

        return fileURL
    }

    private func excludeDatabaseDirectoryFromBackup() throws {
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true

        var directoryURL = try databaseDirectoryURL()
        try directoryURL.setResourceValues(resourceValues)
    }

    private func filenameForDatabaseName(_ basename: String) -> String {
        let filename: String

        let lname = basename.lowercased()
        if lname.hasSuffix(".db") || lname.hasSuffix(".sqlite") || lname.hasSuffix(".sqlite3") {
            filename = basename
        } else {
            filename = "\(basename).sqlite"
        }

        return filename
    }

}
