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


/// Wraps an `Error` in an `ObjectDataSource`.
///
/// The data source has one section with one row. Requesting the model at that
/// index path _throws_ the wrapped `Error` object.
public final class ErrorObjectDataSource<ObjectType>: ObjectDataSource<ObjectType> {
    
    /// The `Error` used to instantiate this object.
    public let error: Swift.Error
    
    /// Creates an ObjectDataSource that will throw the specified `Error` when
    /// the first row of the first section is retrieved.
    ///
    /// - Parameter error: The `Error` to throw when the first object in the
    ///   first section is retrieved.
    public init(error: Swift.Error) {
        self.error = error
        
        super.init()
    }
    
    // MARK: ObjectDataSource
    
    public override func numberOfSections() -> Int {
        return 1
    }
    
    public override func numberOfObjectsInSection(_ section: Int) -> Int {
        let count = (section == 0) ? 1 : 0
        return count
    }
    
    public override func objectAt(_ indexPath: IndexPath) throws -> ObjectType {
        guard
            indexPath.section == 0,
            indexPath.row == 0
            else {
                throw Error.invalidIndexPath(indexPath)
        }
        
        throw self.error
    }
    
    public override func titleOfSection(_ section: Int) -> String? {
        return nil
    }
    
}
