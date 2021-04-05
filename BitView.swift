//
//  BitView.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import SwiftUI

struct BitView: View {
    
    @ObservedObject var collection = Collection.collection
    
    var bit: Bit
    var bob: Bob
    
    @State var editBit = false
    
    var body: some View {
        
        GeometryReader { geometry in
        
            ScrollView {
                
                VStack {
                
                    Icon(icon: bit.icon ?? "", size: geometry.size.width*0.5, edit: collection.edit)
                        .padding(.top, 10)
                        .onTapGesture() { collection.edit ? editBit = true : nil }
                        .sheet(isPresented: self.$editBit, content: {
                            BitEditor(bit: bit, bob: bob)
                        })
                    
                    Text(bit.name)
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.top, -5)
                    
                    Text(bit.desc ?? "")
                        .foregroundColor(Color(UIColor.systemGray))
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 10)
                
                ForEach(0..<bit.attributes.count, id: \.self) { a in
                    if bit.attributes[a] != "" {
                        HStack {
                            Text(bob.attributes[a])
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(Color(UIColor.systemGray))
                            Spacer()
                            Text(bit.attributes[a])
                                .font(.system(size: 25))
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 5)
                    }
                }
                
                Text(bit.paragraph ?? "")
                    .font(.system(size: 20))
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                
                Spacer()
                    .frame(height: geometry.size.height*0.1)
                
            }
        }
        .navigationBarTitle(bit.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            Button {
                withAnimation {
                    collection.edit.toggle()
                    collection.edit ? self.editBit = true : nil
                }
            } label: {
                Text(collection.edit ? "Done" : "Edit")
            }
        )
    }
}

//struct BitView_Previews: PreviewProvider {
//    static var previews: some View {
//        BitView()
//    }
//}
