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


/// An `ObjectDataSource` that wraps another `ObjectDataSource` and performs a
/// transformation on the objects returned by that data source.
///
/// This adapter is useful for converting domain models into view-oriented
/// models. This class is commonly applied in cases where the technology
/// storing the domain model provides high-performance or low-memory operation
/// (for example, `NSFetchedResultsController`), but the domain model objects
/// need to be transformed into view-oriented models for use by the View layer
/// of the application.
public final class TransformingObjectDataSource<OriginalType,TransformedType>: ObjectDataSource<TransformedType> {
    
    /// Function that converts an object of type `OriginalType` into an object
    /// of type `TransformedType`.
    ///
    /// - Parameter obj: Object to mapped.
    ///
    /// - Throws:
    ///   - Error if the object could not be transformed.
    ///
    /// - Returns: An object derived from the object passed as a parameter.
    public typealias Transformer = (_ obj: OriginalType) throws -> TransformedType
    
    private let wrappedODS: ObjectDataSource<OriginalType>
    private let transform: Transformer
    
    /// Create a `TransformingObjectDataSource` that transforms the objects
    /// returned by the originating object data source into objects of type
    /// `TransformedType`.
    ///
    /// - Parameter objectDataSource: ObjectDataSource providing objects to be
    ///   transformed by this class.
    /// - Parameter map: Function that transforms an object from the original
    ///   type to the output type.
    public init(objectDataSource: ObjectDataSource<OriginalType>, transform: @escaping Transformer) {
        self.wrappedODS = objectDataSource
        self.transform = transform
        
        super.init()
    }
    
    // MARK: ObjectDataSource
    
    public override func numberOfObjectsInSection(_ section: Int) -> Int {
        return self.wrappedODS.numberOfObjectsInSection(section)
    }
    
    public override func numberOfSections() -> Int {
        return self.wrappedODS.numberOfSections()
    }
    
    public override func objectAt(_ indexPath: IndexPath) throws -> TransformedType {
        let srcObj = try self.wrappedODS.objectAt(indexPath)
        let dstObj = try self.transform(srcObj)
        return dstObj
    }
    
    public override func titleOfSection(_ section: Int) -> String? {
        return self.wrappedODS.titleOfSection(section)
    }
    
}

