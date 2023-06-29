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
    var square: Bool = false
    var faded: Bool = false
    
    var body: some View {
        
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray
            }
        }
        .frame(width: self.size, height: self.size)
        .cornerRadius(!square ? size : 20)
        .overlay(
            RoundedRectangle(cornerRadius: !square ? size : 20)
                .stroke(Color(UIColor.systemGray5), lineWidth: size <= 50 ? size/15 : size/30)
        )
        .opacity(!faded ? 1 : 0.3)
    }
}
