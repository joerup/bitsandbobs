//
//  BitEditor.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 3/20/21.
//

import SwiftUI

struct BitEditor: View {
    
    @ObservedObject var collection = Collection.collection
    
    var bit: Bit? = nil
    var bob: Bob
    
    @State var name = ""
    @State var desc = ""
    @State var paragraph = ""
    @State var icon = ""
    @State var attributes = [String]()
    
    @State var showDelete = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ScrollView {
                
                VStack {
                    
                    Text(self.bit == nil ? "New Bit" : "Edit Bit")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                    
                    Text(self.bit == nil ? "Create a new item in the \(self.bob.name) category" : "Edit item in the \(self.bob.name) category")
                        .font(.system(size: 20))
                        .foregroundColor(Color(UIColor.systemGray2))
                    
                    VStack {
                    
                        Icon(icon: self.icon, size: geometry.size.width*0.5)
                            .padding(.top, 10)
                        
                        TextField("Name", text: self.$name)
                            .font(.system(size: 40))
                            .multilineTextAlignment(.center)
                            .padding(2).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray5), lineWidth: 1))
                        
                        TextField("Description", text: self.$desc)
                            .foregroundColor(Color(UIColor.systemGray))
                            .font(.system(size: 20))
                            .multilineTextAlignment(.center)
                            .padding(2).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray5), lineWidth: 1))
                            
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                    
                    ForEach(0..<bob.attributes.count, id: \.self) { a in
                        HStack {
                            Text(bob.attributes[a])
                                .font(.system(size: 25))
                                .fontWeight(.bold)
                                .foregroundColor(Color(UIColor.systemGray))
                            Spacer()
                            if a < self.attributes.count {
                                TextField(bob.attributes[a], text: self.$attributes[a])
                                    .font(.system(size: 25))
                                    .multilineTextAlignment(.trailing)
                                    .padding(2).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray5), lineWidth: 1))
                            }
                        }
                        .padding(.top, 5)
                    }
                    
                    TextField("Paragraph", text: self.$paragraph)
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .padding(2).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray5), lineWidth: 1))
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    
                    Button {
                        addBit()
                    } label: {
                        Text("Save")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(20)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        if bit != nil {
                            showDelete = true
                        }
                    } label: {
                        Text("Delete")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(20)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .alert(isPresented: $showDelete) {
                        Alert(title: Text("Delete Bit"),
                              message: Text("Are you ABSOLUTELY SURE you want to delete \(bit!.name)?"),
                              primaryButton: .default(Text("Cancel"), action: { showDelete = false }),
                              secondaryButton: .default(Text("Delete"), action: { deleteBit() })
                        )
                    }
                }
                .padding(30)
                .padding(.top, -10)
            }
        }
        .onAppear() {
            if self.bit != nil {
                self.name = self.bit!.name
                self.desc = self.bit!.desc ?? ""
                self.paragraph = self.bit!.paragraph ?? ""
                self.icon = self.bit!.icon ?? ""
                self.attributes = self.bit!.attributes
                while self.attributes.count < self.bob.attributes.count {
                    self.attributes += [""]
                }
            }
        }
    }
    
    func addBit() {
        
        guard self.name != "" else {
            return
        }
        
        let id = self.bit == nil ? bob.bits.count : self.bit!.id
        
        let bit = Bit(id: id,
                      name: self.name,
                      desc: self.desc,
                      paragraph: self.paragraph,
                      icon: self.icon,
                      attributes: self.attributes
                    )
        
        if self.bit == nil {
            self.collection.bobs[self.bob.id].bits += [bit]
        }
        else {
            self.collection.bobs[self.bob.id].bits[self.bit!.id] = bit
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    func deleteBit() {
        
        guard bit != nil else {
            presentationMode.wrappedValue.dismiss()
            return
        }
        
        self.collection.bobs[bob.id].bits.remove(at: bit!.id)
        
        for i in 0..<self.collection.bobs[bob.id].bits.count {
            self.collection.bobs[bob.id].bits[i].id = i
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}
