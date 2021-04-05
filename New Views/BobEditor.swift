//
//  BobEditor.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 3/20/21.
//

import SwiftUI

struct BobEditor: View {
    
    @ObservedObject var collection = Collection.collection
    
    var bob: Bob? = nil
    
    @State var name = ""
    @State var desc = ""
    @State var icon = ""
    @State var bits = [Bit]()
    @State var attributes : [String] = [""]
    
    @State var showDelete = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ScrollView {
            
                VStack {
                    
                    Text(self.bob == nil ? "New Bob" : "Edit Bob")
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                    
                    Text(self.bob == nil ? "Create a new category" : "Edit the \(self.bob!.name) category")
                        .font(.system(size: 20))
                        .foregroundColor(Color(UIColor.systemGray2))
                    
                    VStack {
                    
                        Icon(icon: self.icon, size: geometry.size.width*0.5, square: true)
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
                    
                    Text("Attributes")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .padding(.top, 20)
                    
                    VStack {
                        ForEach(0..<attributes.count, id: \.self) { a in
                            TextField("Attribute", text: self.$attributes[a], onCommit: {if a == attributes.count-1 { self.attributes += [""] }})
                                .font(.system(size: 20))
                                .multilineTextAlignment(.center)
                                .padding(2).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(UIColor.systemGray5), lineWidth: 1))
                        }
                    }
                    .padding(.bottom, 20)
                    
                    Button {
                        addBob()
                    } label: {
                        Text("Save")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding(20)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        if bob != nil {
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
                        Alert(title: Text("Delete Bob"),
                              message: Text("Are you ABSOLUTELY SURE you want to delete the \(bob!.name) category? This will also delete all of the bits inside it!"),
                              primaryButton: .default(Text("Cancel"), action: { showDelete = false }),
                              secondaryButton: .default(Text("Delete"), action: { deleteBob() })
                        )
                    }
                }
                .padding(30)
                .padding(.top, -10)
            }
        }
        .onAppear() {
            if self.bob != nil {
                self.name = self.bob!.name
                self.desc = self.bob!.desc ?? ""
                self.icon = self.bob!.icon ?? ""
                self.bits = self.bob!.bits
                self.attributes = self.bob!.attributes
            }
        }
    }
    
    func addBob() {
        
        guard self.name != "" else {
            return
        }
        
        let id = self.bob == nil ? self.collection.bobs.count : self.bob!.id
        
        let bob = Bob(id: id,
                      name: self.name,
                      desc: self.desc,
                      icon: self.icon,
                      bits: self.bits,
                      attributes: self.attributes
                    )
        
        if self.bob == nil {
            self.collection.bobs += [bob]
        }
        else {
            self.collection.bobs[self.bob!.id] = bob
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    func deleteBob() {
        
        guard bob != nil else {
            presentationMode.wrappedValue.dismiss()
            return
        }
        
        self.collection.bobs.remove(at: bob!.id)
        
        for i in 0..<self.collection.bobs.count {
            self.collection.bobs[i].id = i
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

