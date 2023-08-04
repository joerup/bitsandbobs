//
//  Check.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 6/25/21.
//

import SwiftUI

struct Check: View {
    
    var bob: Bob
    var bit: Bit
    
    @Binding var update: Bool
    
    var scaleFactor: CGFloat = 1.0
    
    var body: some View {
        Checkmark(checked: bit.checked, scaleFactor: scaleFactor) {
            let revisedItems: [Bit] = bob.bitArray.map{ $0 }
            revisedItems[Int(bit.order)].checked.toggle()
            bob.bits = NSSet(array: revisedItems)
            PersistenceController.shared.save()
            update.toggle()
        }
    }
}

struct Checkmark: View {
    
    var checked: Bool
    var scaleFactor: CGFloat = 1.0
    
    var action: () -> Void
    
    private var size: CGFloat {
        return 32 * scaleFactor
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(checked ? PersistenceController.themeColor : Color(UIColor.systemGray5))
                .frame(width: size, height: size)
            if checked {
                Image(systemName: "checkmark")
                    .font(.system(size: size*7/16, weight: .black))
                    .foregroundColor(.white)
            } else {
                Image(systemName: "xmark")
                    .font(.system(size: size*7/16, weight: .black))
                    .foregroundColor(Color(uiColor: .systemGray4))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: size)
                .stroke(Color(uiColor: .systemGray5), lineWidth: size/15)
        )
        .onTapGesture(perform: action)
    }
}
