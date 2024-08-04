//
//  BitListEditor.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 7/10/23.
//

import SwiftUI

struct BitListEditor: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Environment(\.dismiss) var dismiss
    
    var bob: Bob
    var bits: [Bit] {
        return bob.bitArray
    }
    
    @State private var deleteBit: Bit? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(self.bits, id: \.self) { bit in
                    Text(bit.name ?? "")
                        .lineLimit(0)
                }
                .onMove(perform: moveBits)
                .onDelete(perform: removeBits)
                .alert(item: $deleteBit) { bit in
                    Alert(
                        title: Text("Delete \(bit.name ?? "")"),
                        message: Text("Are you sure you want to delete this item?"),
                        primaryButton: .cancel() {
                            deleteBit = nil
                        },
                        secondaryButton: .destructive(Text("Delete")) {
                            removeBit(bit)
                            deleteBit = nil
                        }
                    )
                }
            }
            .environment(\.editMode, .constant(EditMode.active))
            .navigationTitle("Edit Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
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
        for index in offsets {
            deleteBit = bits[index]
        }
    }
    
    func removeBit(_ bit: Bit) {
        var revisedItems: [Bit] = bits
        revisedItems.remove(at: Int(bit.order))
        bob.bits = NSSet(array: revisedItems)
        managedObjectContext.delete(bit)
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
    }

}
