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
    
    var body: some View {
        ZStack {
            Circle()
                .fill(self.bit.checked ? PersistenceController.themeColor : Color(UIColor.systemGray5))
                .frame(width: 32, height: 32)
            Circle()
                .stroke(Color(uiColor: .systemGray4))
                .frame(width: 32, height: 32)
            if self.bit.checked {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.white)
                    .animation(.easeInOut, value: bit.checked)
            } else {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(Color(uiColor: .systemGray4))
                    .animation(.easeInOut, value: bit.checked)
            }
        }
        .id(update)
        .onTapGesture {
            let revisedItems: [Bit] = bob.bitArray.map{ $0 }
            revisedItems[Int(bit.order)].checked.toggle()
            bob.bits = NSSet(array: revisedItems)
            PersistenceController.shared.save()
            update.toggle()
        }
    }
}
