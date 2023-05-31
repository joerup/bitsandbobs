//
//  ListView.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import SwiftUI

struct ListView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(
        entity: Bob.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Bob.order, ascending: true)
        ]
    ) var bobs: FetchedResults<Bob>
    
    @State private var newBob = false
    @State private var editBobs = false
    
    @State private var showSettings = false
    
    @State private var search = ""

    var body: some View {

        GeometryReader { geometry in

            NavigationView {
                
                VStack(spacing: 0) {
                    
                    ScrollView {
                        
                        VStack {
                            
                            if self.bobs.isEmpty {
                                Button {
                                    self.newBob.toggle()
                                } label: {
                                    Text("Create your first collection!")
                                        .padding()
                                }
                            }
                            
                            ForEach(self.bobs, id: \.order) { bob in

                                NavigationLink(destination: BobView(bob: bob)) {

                                    ZStack {
                                        if bob.image == nil {
                                            Rectangle()
                                                .fill(Color.init(red: 0.9, green: 0.7, blue: 0.4, opacity: 0.2))
                                                .cornerRadius(20)
                                        }

                                        Image(uiImage: bob.image != nil ? UIImage(data: bob.image!) ?? UIImage(named: "") ?? UIImage() : UIImage(named: "") ?? UIImage())
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .blur(radius: 2)
                                            .frame(height: UIScreen.main.bounds.height*0.15)
                                            .cornerRadius(10)

                                        VStack {
                                            Text(bob.name ?? "")
                                                .font(.system(.largeTitle, design: .rounded).weight(.black))
                                                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                                                .tracking(-0.5)
                                                .lineLimit(0)
                                                .minimumScaleFactor(0.2)
                                                .foregroundColor(bob.image != nil ? Color(UIColor.white) : Color(UIColor.label))
                                                .shadow(color: .black, radius: bob.image != nil ? 10 : 0)

                                            if bob.desc != nil && bob.desc != "" {
                                                Text(bob.desc ?? "")
                                                    .font(.system(.headline, design: .rounded).weight(.bold))
                                                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                                                    .tracking(-0.25)
                                                    .lineLimit(0)
                                                    .minimumScaleFactor(0.2)
                                                    .foregroundColor(Color(bob.image != nil ? UIColor.white : UIColor.systemGray))
                                                    .shadow(color: .black, radius: bob.image != nil ? 10 : 0)
                                            }
                                        }
                                        .frame(height: UIScreen.main.bounds.height*0.15)

                                        HStack {
                                            Spacer()
                                            Image(systemName: "chevron.forward")
                                                .font(.body.bold())
                                                .dynamicTypeSize(...DynamicTypeSize.xLarge)
                                                .foregroundColor(.white)
                                                .shadow(color: .black, radius: bob.image != nil ? 10 : 0)
                                                .padding()
                                        }
                                    }
                                }
                            }
                            .listRowSeparator(.hidden)
                            .environment(\.editMode, .constant(self.editBobs ? EditMode.active : EditMode.inactive))
                            .sheet(isPresented: self.$editBobs) {
                                RearrangeBobOrder()
                            }
                        }
                        .padding(10)
                    }
                }
                .navigationBarTitle("Collections")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            self.showSettings.toggle()
                        }) {
                            Image(systemName: "gearshape.fill")
                        }
                    }
                    if !bobs.isEmpty {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                self.editBobs.toggle()
                            } label: {
                                Text("Edit")
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.newBob.toggle()
                        }, label: {
                            Image(systemName: "plus")
                        })
                    }
                }
                .sheet(isPresented: self.$showSettings) {
                    SettingsView()
                }
                .sheet(isPresented: self.$newBob, content: {
                    BobEditor()
                })
                
                Text("Select a category.")
                    .padding()
            }
            .accentColor(PersistenceController.themeColor)
            .phoneOnlyStackNavigationView(geometry)
        }
    }
}


struct RearrangeBobOrder: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Environment(\.presentationMode) var presentationMode
    
    @FetchRequest(
        entity: Bob.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Bob.order, ascending: true)
        ]
    ) var bobs: FetchedResults<Bob>
    
    @State private var deleteBob: Bob? = nil
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(self.bobs.map { $0 }, id: \.self) { bob in
                        Text(bob.name ?? "")
                            .lineLimit(0)
                    }
                    .onMove(perform: moveBobs)
                    .onDelete(perform: removeBobs)
                    .alert(item: $deleteBob) { bob in
                        Alert(
                            title: Text("Delete \(bob.name ?? "")"),
                            message: Text("Are you absolutely sure you want to delete this collection? This will also delete all of the items, attributes, and settings it contains. This action cannot be undone."),
                            primaryButton: .cancel() {
                                deleteBob = nil
                            },
                            secondaryButton: .destructive(Text("Delete")) {
                                removeBob(bob)
                                deleteBob = nil
                            }
                        )
                    }
                }
            }
            .environment(\.editMode, .constant(EditMode.active))
            .navigationTitle("Edit Collections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .font(.system(.headline, design: .rounded).bold())
                            .foregroundColor(PersistenceController.themeColor)
                    }
                }
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
    }
    
    func reorderBobs(_ array: [Bob]) {
        let revisedItems = array
        var index = 0
        while index < revisedItems.count {
            revisedItems[index].order = Int16(index)
            index += 1
        }
        PersistenceController.nextBobID = Int16(revisedItems.count)
        PersistenceController.shared.save()
    }
}


extension View {
    func phoneOnlyStackNavigationView(_ geometry: GeometryProxy) -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone || geometry.size.height >= geometry.size.width {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        } else {
            return AnyView(self)
        }
    }
}
