//
//  Check.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 6/25/21.
//

import SwiftUI

struct Check: View {
    
    @State var bob: Bob
    @State var bit: Bit
    
    @FetchRequest(
        entity: Bit.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Bit.order, ascending: true)
        ]
    ) var bits: FetchedResults<Bit>
    
    var body: some View {
        ZStack {
            Circle()
                .fill(self.bit.checked ? PersistenceController.themeColor : Color(UIColor.systemGray5))
                .frame(width: 35, height: 35)
                .animation(.easeInOut)
            Circle()
                .stroke(Color(UIColor.systemGray4))
                .frame(width: 35, height: 35)
            if self.bit.checked {
                Image(systemName: "checkmark")
                    .animation(.easeInOut)
            }
        }
        .onTapGesture {
            PersistenceController.haptic(.medium)
            let revisedItems: [Bit] = bob.bitArray.map{ $0 }
            revisedItems[Int(bit.order)].checked.toggle()
            bob.bits = NSSet(array: revisedItems)
            PersistenceController.shared.save()
        }
    }
}
