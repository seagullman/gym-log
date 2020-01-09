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

import QuartzCore
import UIKit


/// Resize UIImages, accounting for EXIF data (i.e., orientation).
///
/// Based upon http://vocaro.com/trevor/blog/2009/10/12/resize-a-uiimage-the-right-way/
public extension UIImage {

    /// Returns a copy of the receiver, resized so that the longest side is the
    /// provided length.
    ///
    /// The new image's orientation will be `.up`, regardless of the current
    /// image's orientation. The new image will maintain the receiver's aspect
    /// ratio; however, if the new size is not integral, it will be rounded up.
    public func resizedTo(
        longestSide: CGFloat,
        interpolationQuality quality: CGInterpolationQuality = .default
    ) -> UIImage? {
        let newSize: CGSize
        if self.size.width > self.size.height {
            // landscape, width is longest edge
            let ratio = longestSide / self.size.width
            newSize = CGSize(width: longestSide, height: self.size.height * ratio)
        } else {
            // portrait or square, height is longest edge
            let ratio = longestSide / self.size.height
            newSize = CGSize(width: self.size.width * ratio, height: longestSide)
        }

        let resizedImage = self.resizedTo(newSize, interpolationQuality: quality)
        return resizedImage
    }

    /// Returns a copy of the receiver, resized to the provided bounds using an
    /// "aspect fill" content mode, taking into account the receiver's
    /// orientation.
    ///
    /// The new image's orientation will be `.up`, regardless of the current
    /// image's orientation. If the new size is not integral, it will be
    /// rounded up.
    public func resizedTo(
        _ bounds: CGSize,
        interpolationQuality quality: CGInterpolationQuality = .default
    ) -> UIImage? {
        // new size
        let horizontalRatio = bounds.width / self.size.width
        let verticalRatio = bounds.height / self.size.height
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: self.size.width * ratio, height: self.size.height * ratio)

        // new transposition
        let drawTransposed: Bool
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }

        // new transform
        let transform = self.transformForOrientation(newSize)

        // put it all together
        let resizedImage = self.resizedTo(
            newSize,
            transform: transform,
            drawTransposed: drawTransposed,
            interpolationQuality: quality
        )
        return resizedImage
    }

    // MARK: Private Helpers

    /// Returns an affine transform that takes into account the image
    /// orientation when drawing a scaled image.
    private func transformForOrientation(_ newSize: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransform.identity

        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform
                .translatedBy(x: newSize.width, y: newSize.height)
                .rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform
                .translatedBy(x: newSize.width, y: 0)
                .rotated(by: CGFloat.pi * 0.5)
        case .right, .rightMirrored:
            transform = transform
                .translatedBy(x: 0, y: newSize.height)
                .rotated(by: CGFloat.pi * -0.5)
        default:
            break
        }

        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform
                .translatedBy(x: newSize.width, y: 0)
                .scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform
                .translatedBy(x: newSize.height, y: 0)
                .scaledBy(x: -1, y: 1)
        default:
            break
        }

        return transform;
    }

    /// Returns a copy of the image that has been transformed using the given
    /// affine transform and scaled to the new size.
    ///
    /// The new image's orientation will be `.up`, regardless of the current
    /// image's orientation. If the new size is not integral, it will be
    /// rounded up.
    private func resizedTo(
        _ newSize: CGSize,
        transform: CGAffineTransform,
        drawTransposed: Bool,
        interpolationQuality: CGInterpolationQuality
    ) -> UIImage? {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        let transposedRect = CGRect(x: 0, y: 0, width: newSize.height, height: newSize.width)

        guard
            let imageRef = self.cgImage,
            let colorSpace = imageRef.colorSpace,
            // Build a context that's the same dimensions as the new size
            let bitmap = CGContext(
                data: nil,
                width: Int(newRect.size.width),
                height: Int(newRect.size.height),
                bitsPerComponent: imageRef.bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: imageRef.bitmapInfo.rawValue
            )
        else { return nil }

        // Rotate and/or flip the image if required by its orientation
        bitmap.concatenate(transform)

        // Set the quality level to use when rescaling
        bitmap.interpolationQuality = interpolationQuality

        // Draw into the context; this scales the image
        let drawRect = drawTransposed ? transposedRect : newRect
        bitmap.draw(imageRef, in: drawRect)

        // Get the resized image from the context and a UIImage
        let newImage: UIImage?
        if let newImageRef = bitmap.makeImage() {
            newImage = UIImage(cgImage: newImageRef)
        } else {
            newImage = nil
        }

        return newImage
    }


}
