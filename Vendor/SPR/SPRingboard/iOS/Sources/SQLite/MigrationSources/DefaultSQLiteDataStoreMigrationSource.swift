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


/// This migration source implementation reads migration files out of a
/// bundle. Unless otherwise specified, the main bundle is used.
///
/// The migrations must have the extension `.migration` and must be named so
/// that a case-sensitive, textual ordering of the file names will result in
/// correct ordering of the migrations. The best practice is to name your
/// migrations with a 4-digit number; for example, `0000.migration`,
/// `0001.migration`, `0002.migration`, and so on.
///
/// Individual statements within the migration files may span multiple lines.
/// Statements must be terminated by a trailing semi-colon (`;`) on a line or
/// a semi-colon alone on a line. The following is a valid migation file:
///
///     CREATE TABLE authors (
///       id INTEGER PRIMARY KEY,
///       first_name TEXT,
///       last_name TEXT NOT NULL)
///     ;
///
///     CREATE TABLE articles (
///       id INTEGER PRIMARY KEY,
///       title TEXT NOT NULL,
///       body TEXT,
///       publication_date TEXT NOT NULL)
///     ;
///
///     CREATE TABLE articles_authors ( article_id INTEGER, author_id INTEGER );
///     CREATE UNIQUE INDEX articles_authors_idx ON articles_authors(article_id, author_id);
///
public class DefaultSQLiteDataStoreMigrationSource: SQLiteDataStoreMigrationSource {

    private let migrationURLs: [URL]

    public var migrationCount: Int {
        let count = self.migrationURLs.count
        return count
    }

    public convenience init() {
        self.init(bundle: Bundle.main)
    }

    public init(bundle: Bundle) {
        var migrationURLs = bundle.urls(forResourcesWithExtension: "migration", subdirectory: nil) ?? []
        migrationURLs.sort { (lhs, rhs) -> Bool in
            lhs.lastPathComponent < rhs.lastPathComponent
        }
        self.migrationURLs = migrationURLs
    }

    public func statementsForMigration(_ index: Int) throws -> [String] {
        let fileURL = self.migrationURLs[index]
        let content = try String(contentsOf: fileURL, encoding: .utf8)

        var statements: [String] = []
        var lines: [String] = []
        content.enumerateLines { (line, _) in
            lines.append(line)
            if self.isLineEndOfStatement(line) {
                let statement = lines.joined().trimmingCharacters(in: .whitespacesAndNewlines)
                if !statement.isEmpty {
                    statements.append(statement)
                }
                lines.removeAll(keepingCapacity: true)
            }
        }
        if !lines.isEmpty {
            let statement = lines.joined().trimmingCharacters(in: .whitespacesAndNewlines)
            if !statement.isEmpty {
                statements.append(statement)
            }
        }

        return statements
    }

    // MARK: Private

    private func isLineEndOfStatement(_ line: String) -> Bool {
        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
        let endsWithSemicolon = trimmedLine.hasSuffix(";")
        return endsWithSemicolon
    }
}
