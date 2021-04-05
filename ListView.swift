//
//  ListView.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import SwiftUI

struct ListView: View {
    
    @ObservedObject var collection = Collection.collection
    
    @State var newBob = false
    
    @State private var selectedBob: Bob? = nil
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ScrollView {
                
                List {
                
                    ForEach(self.collection.bobs, id: \.id) { bob in
                            
                        NavigationLink(destination: BobView(bob: bob)) {
                            
                            HStack {
                                
                                Icon(icon: bob.icon ?? "", size: 90, square: true, edit: collection.edit)
                                    .padding(.vertical, 10)
                                    .padding(.trailing, 4)
                                    .onTapGesture() { collection.edit ? selectedBob = bob : nil }
                                    .sheet(item: self.$selectedBob, content: { selectedBob in
                                        BobEditor(bob: selectedBob)
                                    })
                                
                                VStack(alignment: .leading) {
                                    
                                    Text(bob.name)
                                        .fontWeight(.bold)
                                        .font(.system(size: 30))
                                    
                                    Text(String(bob.id))
                                    
                                    Text(bob.desc ?? "")
                                        .foregroundColor(Color(UIColor.systemGray))
                                    
                                }
                            }
                        }
                    }
                    .onMove(perform: move)
                    .onDelete(perform: delete)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            self.newBob.toggle()
                        }, label: {
                            Text("New Bob")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .padding(20)
                        })
                        .sheet(isPresented: self.$newBob, content: {
                            BobEditor()
                        })
                        
                        Spacer()
                    }
                    
                    Text("Important: data will not currently save in the app between sessions. You can add your own bits & bobs but they will be gone once you close the app (for now).")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .environment(\.editMode, .constant(collection.edit ? EditMode.active : EditMode.inactive))
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            }
        }
        .navigationBarTitle("My Bobs")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            Button {
                withAnimation {
                    collection.edit.toggle()
                }
            } label: {
                Text(collection.edit ? "Done" : "Edit")
            }
        )
    }
    
    func move(from source: IndexSet, to destination: Int) {
        collection.bobs.move(fromOffsets: source, toOffset: destination)
        resetIDs()
    }
    func delete(at offsets: IndexSet) {
        collection.bobs.remove(atOffsets: offsets)
        resetIDs()
    }
    func resetIDs() {
        for i in 0..<collection.bobs.count {
            collection.bobs[i].id = i
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
