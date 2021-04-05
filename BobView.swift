//
//  BobView.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import SwiftUI

struct BobView: View {
    
    @ObservedObject var collection = Collection.collection
    
    var bob: Bob
    
    @State var editBob = false
    @State var newBit = false
    
    @State private var selectedBit: Bit? = nil
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ScrollView {
                
                Icon(icon: bob.icon ?? "", size: geometry.size.width*0.5, square: true, edit: collection.edit)
                    .padding(.top, 10)
                    .onTapGesture() { collection.edit ? editBob = true : nil }
                    .sheet(isPresented: self.$editBob, content: {
                        BobEditor(bob: bob)
                    })
                
                Text(bob.name)
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                    .padding(.top, -5)
                
                Text(bob.desc ?? "")
                    .foregroundColor(Color(UIColor.systemGray))
                    .font(.system(size: 20))
                
                List {
                
                    ForEach(bob.bits, id: \.id) { bit in
                        
                        NavigationLink(destination: BitView(bit: bit, bob: bob)) {
                            
                            HStack {
                                
                                Icon(icon: bit.icon ?? "", size: 90, edit: collection.edit)
                                    .padding(.vertical, 10)
                                    .padding(.trailing, 4)
                                    .onTapGesture() { collection.edit ? selectedBit = bit : nil }
                                    .sheet(item: self.$selectedBit, content: { selectedBit in
                                        BitEditor(bit: selectedBit, bob: bob)
                                    })
                                
                                VStack(alignment: .leading) {
                                    
                                    Text(bit.name)
                                        .fontWeight(.bold)
                                        .font(.system(size: 30))
                                    
                                    Text(String(bit.id))
                                    
                                    Text(bit.desc ?? "")
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
                            self.newBit.toggle()
                        }, label: {
                            Text("New Bit")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .padding(20)
                        })
                        .sheet(isPresented: self.$newBit, content: {
                            BitEditor(bob: bob, attributes: [String](repeating: "", count: bob.attributes.count))
                        })
                        
                        Spacer()
                    }
                }
                .environment(\.editMode, .constant(collection.edit ? EditMode.active : EditMode.inactive))
                .frame(width: geometry.size.width-5, height: geometry.size.height-50, alignment: .center)
            }
        }
        .navigationBarTitle(bob.name)
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
        collection.bobs[bob.id].bits.move(fromOffsets: source, toOffset: destination)
        resetIDs()
    }
    func delete(at offsets: IndexSet) {
        collection.bobs[bob.id].bits.remove(atOffsets: offsets)
        resetIDs()
    }
    func resetIDs() {
        for i in 0..<collection.bobs[bob.id].bits.count {
            collection.bobs[bob.id].bits[i].id = i
        }
    }
}

//struct BobView_Previews: PreviewProvider {
//    static var previews: some View {
//        BobView()
//    }
//}
