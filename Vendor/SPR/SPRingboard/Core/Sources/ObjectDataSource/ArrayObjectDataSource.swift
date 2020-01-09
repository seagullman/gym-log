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


/// An `ObjectDataSource` adapter backed by an array.
///
/// This adapter is useful for providing fixture data and when handling a data
/// storage technology that lacks its own `ObjectDataSource` implementation.
public final class ArrayObjectDataSource<ElementType>: ObjectDataSource<ElementType> {

    private let objects: [ElementType]
    private let sectionName: String?
    
    /// Creates an `ObjectDataSource` instance backed by an array.
    ///
    /// - Parameter objects: Array of objects to presented as an
    ///   `ObjectDataSource`.
    /// - Parameter sectionName: Optional name of the section for these
    ///   objects.
    public init(objects: [ElementType], sectionName: String? = nil) {
        self.objects = objects
        self.sectionName = sectionName
        
        super.init()
    }
    
    // MARK: ObjectDataSource
    
    public override func numberOfObjectsInSection(_ section: Int) -> Int {
        guard section == 0 else { return 0 }
        return objects.count
    }
    
    public override func numberOfSections() -> Int {
        return 1
    }
    
    public override func objectAt(_ indexPath: IndexPath) throws -> ElementType {
        guard
            indexPath.section == 0,
            indexPath.row < self.objects.count
            else {
                throw Error.invalidIndexPath(indexPath)
        }
        
        let object = self.objects[indexPath.row]
        return object
    }
    
    public override func titleOfSection(_ section: Int) -> String? {
        guard section == 0 else { return nil }
        return self.sectionName
    }
    
}
