//
//  Icon.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import SwiftUI

struct Icon: View {
    
    var icon: String
    var size: CGFloat
    var square: Bool = false
    var edit: Bool = false
    
    var body: some View {
        
        ZStack {
        
            Image(self.icon)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: self.size, height: self.size)
                .cornerRadius(!square ? 100 : 20)
                .overlay(
                    RoundedRectangle(cornerRadius: !square ? 100 : 20)
                        .stroke(Color(UIColor.systemGray5), lineWidth: 4)
                )
                .opacity(!edit ? 1 : 0.3)
            
            if edit {
                Text("Edit")
                    .fontWeight(.bold)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .font(.system(size: self.size/4))
                    .animation(.default)
            }
            
        }
    }
}

