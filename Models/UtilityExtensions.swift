//
//  UtilityExtensions.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 5/27/23.
//

import Foundation
import UIKit
import SwiftUI
import Compression

struct Constants {
    static let delimiter: Character = "‚"
}

extension Data {
    func compressToIcon(offset: CGSize = .zero, scale: CGFloat = 1.0) -> Data? {
        var image = UIImage(data: self)
        image = image?.cropped(offset: offset, scale: scale)
        image = image?.scaled(newWidth: 50)
        return image?.jpegData(compressionQuality: 0.75)
    }
}

extension UIImage {
    var isEmpty: Bool {
        return self.size == CGSize.zero
    }
    func equals(_ image: UIImage) -> Bool {
        guard let data1 = self.jpegData(compressionQuality: 0.75), let data2 = image.jpegData(compressionQuality: 0.75) else { return false }
        return data1 == data2
    }
    func equals(_ imageData: Data?) -> Bool {
        guard let data = self.jpegData(compressionQuality: 0.75) else { return false }
        return data == imageData
    }
    
    var fileSize: Int? {
        if let imageData = self.jpegData(compressionQuality: 1.0) {
            let fileSize = imageData.count
            return fileSize
        }
        return nil
    }
    func scaled(newWidth: CGFloat) -> UIImage? {
        guard self.size.width != newWidth else { return nil }
        
        let scaleFactor = newWidth / self.size.width
        
        let newHeight = self.size.height * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    func cropped(offset: CGSize, scale: CGFloat) -> UIImage? {
        let normalizedImage: UIImage = {
            guard self.imageOrientation != .up else { return self }
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1.0
            let renderer = UIGraphicsImageRenderer(size: self.size, format: format)
            return renderer.image { _ in
                self.draw(in: CGRect(origin: .zero, size: self.size))
            }
        }()

        let imageSize = normalizedImage.size
        let size = imageSize.minimum / scale
        let x = imageSize.width / 2 - imageSize.minimum * offset.width - size / 2
        let y = imageSize.height / 2 - imageSize.minimum * offset.height - size / 2
        let cropRect = CGRect(x: x, y: y, width: size, height: size)

        guard let cgImage = normalizedImage.cgImage?.cropping(to: cropRect) else {
            return nil
        }

        return UIImage(cgImage: cgImage, scale: self.scale, orientation: .up)
    }
}

struct AStack<Content: View>: View {
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var alignment: VerticalAlignment = .center
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        if dynamicTypeSize >= .accessibility1 && horizontalSizeClass == .compact {
            VStack(alignment: .leading, content: content)
        } else {
            HStack(alignment: alignment, content: content)
        }
    }
}

struct HeaderStack<Content: View>: View {
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        if dynamicTypeSize >= .accessibility1 {
            VStack(content: content)
        } else {
            ZStack(content: content)
        }
    }
}
 
extension CGSize {
    
    var minimum: CGFloat {
        min(width, height)
    }
    var maximum: CGFloat {
        max(width, height)
    }
    
    var sign: CGSize {
        return CGSize(width: width/abs(width), height: height/abs(height))
    }
    
    // MARK: - Addition
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width,
                      height: lhs.height + rhs.height)
    }
    
    static func += (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs + rhs
    }
    
    // MARK: - Subtraction
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width,
                      height: lhs.height - rhs.height)
    }
    
    static func -= (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs - rhs
    }
    
    // MARK: - Multiplication by CGFloat
    static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width * rhs,
                      height: lhs.height * rhs)
    }
    
    static func * (lhs: CGFloat, rhs: CGSize) -> CGSize {
        return rhs * lhs
    }
    
    static func *= (lhs: inout CGSize, rhs: CGFloat) {
        lhs = lhs * rhs
    }
    
    // MARK: - Division by CGFloat
    static func / (lhs: CGSize, rhs: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / rhs,
                      height: lhs.height / rhs)
    }
    
    static func /= (lhs: inout CGSize, rhs: CGFloat) {
        lhs = lhs / rhs
    }
    
    // MARK: - Element-wise Multiplication by CGSize
    static func * (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width * rhs.width,
                      height: lhs.height * rhs.height)
    }
    
    static func *= (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs * rhs
    }
    
    // MARK: - Element-wise Division by CGSize
    static func / (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width / rhs.width,
                      height: lhs.height / rhs.height)
    }
    
    static func /= (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs / rhs
    }
}
