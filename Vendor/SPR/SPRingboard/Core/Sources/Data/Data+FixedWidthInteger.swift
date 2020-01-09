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


public extension Data {

    public enum Endianness {
        case big
        case little
    }

    // MARK: Appending Data

    public mutating func append<T>(fixedWidthInteger value: T, endianness: Endianness = .big) -> Void where T: FixedWidthInteger {
        var valueWithEndian: T
        switch endianness {
        case .big: valueWithEndian = value.bigEndian
        case .little: valueWithEndian = value.littleEndian
        }

        let valueSize = MemoryLayout.size(ofValue: valueWithEndian)
        withUnsafePointer(to: &valueWithEndian) { (pointerAsT) -> Void in
            pointerAsT.withMemoryRebound(to: UInt8.self, capacity: valueSize) { (pointerAsUInt8) -> Void in
                self.append(pointerAsUInt8, count: valueSize)
            }
        }
    }

    // MARK: Reading Bit Patterns

    public func read8BitPattern() -> UInt8 {
        let bitPattern = self.first ?? 0
        return bitPattern
    }

    public func read16BitPattern() -> UInt16 {
        var bitPattern: UInt16 = 0
        let sizeOfType = MemoryLayout.size(ofValue: bitPattern)
        guard self.count >= sizeOfType else { return 0 }

        for i in 0..<sizeOfType {
            let byte: UInt8 = self[i]
            let byteAsType = UInt16(byte)
            bitPattern &<<= 8
            bitPattern |= byteAsType
        }

        return bitPattern
    }

    public func read32BitPattern() -> UInt32 {
        var bitPattern: UInt32 = 0
        let sizeOfType = MemoryLayout.size(ofValue: bitPattern)
        guard self.count >= sizeOfType else { return 0 }

        for i in 0..<sizeOfType {
            let byte: UInt8 = self[i]
            let byteAsType = UInt32(byte)
            bitPattern &<<= 8
            bitPattern |= byteAsType
        }

        return bitPattern
    }

    public func read64BitPattern() -> UInt64 {
        var bitPattern: UInt64 = 0
        let sizeOfType = MemoryLayout.size(ofValue: bitPattern)
        guard self.count >= sizeOfType else { return 0 }

        for i in 0..<sizeOfType {
            let byte: UInt8 = self[i]
            let byteAsType = UInt64(byte)
            bitPattern &<<= 8
            bitPattern |= byteAsType
        }

        return bitPattern
    }

    // MARK: Extracting Values

    @discardableResult public func extract(_ value: inout UInt8) -> Data {
        value = self.read8BitPattern()

        let sizeOfType = MemoryLayout.size(ofValue: value)
        let remaining = (self.count > sizeOfType) ? self.advanced(by: sizeOfType) : Data()
        return remaining
    }

    @discardableResult public func extract(_ value: inout UInt16, endianness: Endianness = .big) -> Data {
        let bitPattern: UInt16 = self.read16BitPattern()

        switch endianness {
        case .big: value = bitPattern
        case .little: value = bitPattern.byteSwapped
        }

        let sizeOfType = MemoryLayout.size(ofValue: value)
        let remaining = (self.count > sizeOfType) ? self.advanced(by: sizeOfType) : Data()
        return remaining
    }

    @discardableResult public func extract(_ value: inout UInt32, endianness: Endianness = .big) -> Data {
        let bitPattern: UInt32 = self.read32BitPattern()

        switch endianness {
        case .big: value = bitPattern
        case .little: value = bitPattern.byteSwapped
        }

        let sizeOfType = MemoryLayout.size(ofValue: value)
        let remaining = (self.count > sizeOfType) ? self.advanced(by: sizeOfType) : Data()
        return remaining
    }

    @discardableResult public func extract(_ value: inout UInt64, endianness: Endianness = .big) -> Data {
        let bitPattern: UInt64 = self.read64BitPattern()

        switch endianness {
        case .big: value = bitPattern
        case .little: value = bitPattern.byteSwapped
        }

        let sizeOfType = MemoryLayout.size(ofValue: value)
        let remaining = (self.count > sizeOfType) ? self.advanced(by: sizeOfType) : Data()
        return remaining
    }

    @discardableResult public func extract(_ value: inout Int8) -> Data {
        let bitPattern = self.read8BitPattern()
        value = Int8(bitPattern: bitPattern)

        let sizeOfType = MemoryLayout.size(ofValue: value)
        let remaining = (self.count > sizeOfType) ? self.advanced(by: sizeOfType) : Data()
        return remaining
    }

    @discardableResult public func extract(_ value: inout Int16, endianness: Endianness = .big) -> Data {
        let bitPattern = self.read16BitPattern()

        switch endianness {
        case .big: value = Int16(bitPattern: bitPattern)
        case .little: value = Int16(bitPattern: bitPattern.byteSwapped)
        }

        let sizeOfType = MemoryLayout.size(ofValue: value)
        let remaining = (self.count > sizeOfType) ? self.advanced(by: sizeOfType) : Data()
        return remaining
    }

    @discardableResult public func extract(_ value: inout Int32, endianness: Endianness = .big) -> Data {
        let bitPattern = self.read32BitPattern()

        switch endianness {
        case .big: value = Int32(bitPattern: bitPattern)
        case .little: value = Int32(bitPattern: bitPattern.byteSwapped)
        }

        let sizeOfType = MemoryLayout.size(ofValue: value)
        let remaining = (self.count > sizeOfType) ? self.advanced(by: sizeOfType) : Data()
        return remaining
    }

    @discardableResult public func extract(_ value: inout Int64, endianness: Endianness = .big) -> Data {
        let bitPattern = self.read64BitPattern()

        switch endianness {
        case .big: value = Int64(bitPattern: bitPattern)
        case .little: value = Int64(bitPattern: bitPattern.byteSwapped)
        }

        let sizeOfType = MemoryLayout.size(ofValue: value)
        let remaining = (self.count > sizeOfType) ? self.advanced(by: sizeOfType) : Data()
        return remaining
    }

}
