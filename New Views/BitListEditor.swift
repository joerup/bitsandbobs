//
//  BitListEditor.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 7/10/23.
//

import SwiftUI

struct BitListEditor: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Environment(\.presentationMode) var presentationMode
    
    var bob: Bob
    var bits: [Bit] {
        return bob.bitArray
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(self.bits, id: \.self) { bit in
                    Text(bit.name ?? "")
                        .lineLimit(0)
                }
                .onMove(perform: moveBits)
                .onDelete(perform: removeBits)
            }
            .environment(\.editMode, .constant(EditMode.active))
            .navigationTitle("Edit Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .font(.system(.headline, design: .rounded).bold())
                    }
                }
            }
            .tint(PersistenceController.themeColor)
        }
    }
    
    func moveBits(from source: IndexSet, to destination: Int) {
        var revisedItems: [Bit] = bits
        revisedItems.move(fromOffsets: source, toOffset: destination )
        for reverseIndex in stride( from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].order = Int16(reverseIndex)
        }
        bob.bits = NSSet(array: revisedItems)
        PersistenceController.shared.save()
    }

    func removeBits(offsets: IndexSet) {
        var revisedItems: [Bit] = bits
        for index in offsets {
            // Find the bit with the index relative to the starting group
            let bit = bits[index]
            // Remove the bit
            revisedItems.remove(at: Int(bit.order))
            bob.bits = NSSet(array: revisedItems)
            managedObjectContext.delete(bit)
        }
        reorderBits(revisedItems)
        PersistenceController.shared.save()
    }
    
    func reorderBits(_ array: [Bit]) {
        let revisedItems = array
        var index = 0
        while index < revisedItems.count {
            revisedItems[index].order = Int16(index)
            index += 1
        }
        bob.bits = NSSet(array: revisedItems)
        bob.nextBitID = Int16(revisedItems.count)
        PersistenceController.shared.save()
    }

}
