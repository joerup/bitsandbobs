//
//  UtilityExtensions.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 5/27/23.
//

import Foundation
import UIKit
import SwiftUI

extension UIImage {
    func equals(_ image: UIImage) -> Bool {
        guard let data1 = self.jpegData(compressionQuality: 0.75), let data2 = image.jpegData(compressionQuality: 0.75) else { return false }
        return data1 == data2
    }
    func equals(_ imageData: Data?) -> Bool {
        guard let data = self.jpegData(compressionQuality: 0.75) else { return false }
        return data == imageData
    }
    var isEmpty: Bool {
        return self.size == CGSize.zero
    }
}

struct AStack<Content: View>: View {
    
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        if dynamicTypeSize >= .accessibility1 && horizontalSizeClass == .compact {
            VStack(alignment: .leading, content: content)
        } else {
            HStack(content: content)
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
