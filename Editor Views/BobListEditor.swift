//
//  BobListEditor.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 7/10/23.
//

import SwiftUI

struct BobListEditor: View {
        
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Environment(\.dismiss) var dismiss
    
    @FetchRequest(
        entity: Bob.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Bob.order, ascending: true)
        ]
    ) private var bobs: FetchedResults<Bob>
    
    @State private var deleteBob: Bob? = nil
    @State private var deleteBob2: Bob? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(self.bobs.map { $0 }, id: \.self) { bob in
                    Text(bob.name ?? "")
                        .lineLimit(0)
                }
                .onMove(perform: moveBobs)
                .onDelete(perform: removeBobs)
                .alert(item: $deleteBob) { bob in
                    Alert(
                        title: Text("Delete \(bob.name ?? "")"),
                        message: Text("Are you sure you want to delete this collection?"),
                        primaryButton: .cancel() {
                            deleteBob = nil
                        },
                        secondaryButton: .destructive(Text("Delete")) {
                            deleteBob2 = bob
                            deleteBob = nil
                        }
                    )
                }
            }
            .environment(\.editMode, .constant(EditMode.active))
            .navigationTitle("Edit Collections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Done")
                            .font(.system(.headline).bold())
                    }
                }
            }
            .tint(PersistenceController.themeColor)
            .alert(item: $deleteBob2) { bob in
                Alert(
                    title: Text("Delete \(bob.name ?? "")"),
                    message: Text("Are you absolutely sure you want to delete this collection? This will also delete all of the items, attributes, and settings it contains. This action cannot be undone."),
                    primaryButton: .cancel() {
                        deleteBob2 = nil
                    },
                    secondaryButton: .destructive(Text("Delete")) {
                        removeBob(bob)
                        deleteBob2 = nil
                    }
                )
            }
        }
    }
    
    func moveBobs(from source: IndexSet, to destination: Int) {
        var revisedItems: [Bob] = bobs.map{ $0 }
        revisedItems.move(fromOffsets: source, toOffset: destination )
        for reverseIndex in stride( from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].order = Int16(reverseIndex)
        }
        PersistenceController.shared.save()
    }
    
    func removeBobs(offsets: IndexSet) {
        for index in offsets {
            deleteBob = bobs[index]
        }
    }
    
    func removeBob(_ bob: Bob) {
        var reivsedItems: [Bob] = bobs.map { $0 }
        // Remove any bits of that bob
        for bit in bob.bitArray {
            managedObjectContext.delete(bit)
        }
        let index = reivsedItems.firstIndex(of: bob)!
        reivsedItems.remove(at: index)
        managedObjectContext.delete(bob)
        reorderBobs(reivsedItems)
        PersistenceController.shared.save()
    }
    
    func reorderBobs(_ array: [Bob]) {
        let revisedItems = array
        var index = 0
        while index < revisedItems.count {
            revisedItems[index].order = Int16(index)
            index += 1
        }
    }
}
