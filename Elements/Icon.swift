//
//  Icon.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import SwiftUI

struct Icon: View {
    
    var image: UIImage?
    var size: CGFloat
    var rectangle: Bool = false
    var faded: Bool = false
    
    var body: some View {
        
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color(uiColor: .quaternarySystemFill)
            }
        }
        .frame(width: (!rectangle ? 1 : 2.5) * self.size, height: self.size)
        .cornerRadius(!rectangle ? size : 20)
        .opacity(!faded ? 1 : 0.5)
        .overlay(
            RoundedRectangle(cornerRadius: !rectangle ? size : 20)
                .stroke(Color(uiColor: image == nil ? .systemGray5 : .systemGray4), lineWidth: size <= 50 ? size/15 : size <= 100 ? size/20 : size/30)
        )
    }
}
