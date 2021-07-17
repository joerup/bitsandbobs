//
//  BitEditor.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 3/20/21.
//

import SwiftUI

struct BitEditor: View {
    
    var bit: Bit? = nil
    var bob: Bob
    
    @State var name = ""
    @State var desc = ""
    @State var paragraph = " "
    @State var image = UIImage()
    @State var attributes: [String:String] = [:]
    @State var checked = false
    
    @State private var create = true

    @State private var showDelete = false
    @State private var presentImageView = false
    @State private var createEmptyWarning = false

    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        
        ZStack {

            ScrollView {

                VStack {
                    
                    VStack {

                        Text(create ? "New Bit" : "Edit Bit")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text(create ? "Create a new item in the \(self.bob.name ?? "") category" : "Edit item in the \(self.bob.name ?? "") category")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.systemGray2))
                            .multilineTextAlignment(.center)
                        
                        ZStack {
                            
                            Icon(image: self.image, size: 150, faded: true)
                                .padding(.top, 10)
                            
                            Button(action: {
                                PersistenceController.haptic(.medium)
                                self.presentImageView.toggle()
                            }) {
                                Image(systemName: "photo")
                                    .foregroundColor(Color(UIColor.systemGray))
                                    .font(.largeTitle)
                            }
                            .sheet(isPresented: self.$presentImageView) {
                                ImageView(image: self.$image)
                            }
                        }
                        .padding(.bottom, 10)
                        
                        ZStack {
                            VStack {
                                TextField("Name", text: self.$name)
                                    .font(.title)
                                    .multilineTextAlignment(.center)

                                TextField("Description", text: self.$desc)
                                    .foregroundColor(Color(UIColor.systemGray))
                                    .font(.headline)
                                    .multilineTextAlignment(.center)
                            }
                            HStack {
                                Spacer()
                                if self.bob.listType == 1 {
                                    ZStack {
                                        Circle()
                                            .fill(self.checked ? PersistenceController.themeColor : Color(UIColor.systemGray5))
                                            .frame(width: 35, height: 35)
                                            .animation(.easeInOut)
                                        Circle()
                                            .stroke(Color(UIColor.systemGray4))
                                            .frame(width: 35, height: 35)
                                        if self.checked {
                                            Image(systemName: "checkmark")
                                                .animation(.easeInOut)
                                        }
                                    }
                                    .onTapGesture {
                                        PersistenceController.haptic(.medium)
                                        self.checked.toggle()
                                    }
                                }
                            }
                        }

                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    
                    Form {
                        
                        if !self.bob.attributeList.isEmpty {
                            
                            Section(header: Text("Attributes")) {
                                
                                ForEach(self.bob.attributeList.indices, id: \.self) { a in
                                    AttrValueSetter(attributes: self.$attributes, a: a, bob: self.bob)
                                        .padding(.vertical, 3)
                                }
                            }
                        }
                        
                        Section(header: Text("Paragraph")) {
                        
                            ZStack {
                                Text(self.paragraph)
                                    .padding([.leading, .trailing], 5)
                                    .padding([.top, .bottom], 15)
                                    .foregroundColor(Color.clear)
                                TextEditor(text: self.$paragraph)
                            }
                            .padding(2)
                        }
                    }
                    .frame(height: 350 + 50*CGFloat(self.bob.attributeList.count) + 0.7*CGFloat(self.paragraph.count))
                }
            }
            
            VStack {
                
                Spacer()
            
                Button(action: {
                    PersistenceController.haptic(.medium)
                    saveBit()
                }) {
                    Text("Save")
                        .font(.headline)
                        .padding(20)
                        .foregroundColor(.white)
                        .background(PersistenceController.themeColor)
                        .cornerRadius(100)
                }
                .shadow(color: Color(UIColor.systemGray6), radius: 10)
                .padding(20)
                .alert(isPresented: self.$createEmptyWarning) {
                    Alert(title: Text("Please give the bit a name."))
                }
            }
        }
        .onAppear {
            if bit != nil {
                self.create = false
                self.name = bit!.name ?? ""
                self.desc = bit!.desc ?? ""
                self.paragraph = bit!.paragraph ?? ""
                self.image = bit!.image != nil ? UIImage(data: bit!.image!)! : UIImage()
                self.attributes = bit!.attributes ?? [:]
                self.checked = bit!.checked
            }
        }
    }
    
    func saveBit() {

        guard self.name != "" else {
            self.createEmptyWarning.toggle()
            return
        }
        
        if create {
            
            let bit = Bit(context: managedObjectContext)
           
            bit.order = bob.nextBitID
            bob.nextBitID += 1
            
            bit.name = self.name
            bit.desc = self.desc
            bit.paragraph = self.paragraph
            bit.image = self.image.jpegData(compressionQuality: 0.75)
            bit.bob = self.bob
            bit.attributes = self.attributes
            bit.checked = self.checked
            
            bob.addToBits(bit)
        }
        else if bit != nil {
            
            managedObjectContext.performAndWait {
                bit!.name = self.name
                bit!.desc = self.desc
                bit!.paragraph = self.paragraph
                bit!.image = self.image.jpegData(compressionQuality: 0.75)
                bit!.attributes = self.attributes
                bit!.checked = self.checked
            }
            
            var revisedItems: [Bit] = bob.bitArray.map{ $0 }
            revisedItems[Int(bit!.order)] = bit!
            bob.bits = NSSet(array: revisedItems)
        }
        
        PersistenceController.shared.save()

        presentationMode.wrappedValue.dismiss()
    }
}

struct AttrValueSetter: View {
    
    @Binding var attributes: [String:String]
    
    var a: Int
    var bob: Bob
    
    @State private var newValue = ""
    
    @State private var displayOutOfRangeWarning = false
    
    var body: some View {
        
        HStack {
            Text(self.bob.attributeList[a].displayName ?? "")
                .fontWeight(.bold)
                .foregroundColor(Color(UIColor.systemGray))
            
            Spacer()
            
            // Text
            if bob.attributeList[a].type == 0 {
                
                HStack {
                    
                    ZStack {
                        
                        // Text Display
                        HStack {
                            Spacer()
                            Text(self.newValue != "" ? self.newValue : self.bob.attributeList[a].name ?? "")
                                .foregroundColor(self.newValue == "" ? Color(UIColor.systemGray) : nil)
                                .lineLimit(0)
                                .opacity(self.bob.attributeList[a].restrictPresets ? 1 : 0)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color(UIColor.systemGray3), lineWidth: self.bob.attributeList[a].restrictPresets ? 0 : 1)
                                )
                        }
                        
                        // Text Editor
                        if !self.bob.attributeList[a].restrictPresets {
                            TextField(self.bob.attributeList[a].name ?? "", text: self.$newValue)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: self.newValue, perform: { value in
                                    let name = self.bob.attributeList[a].name ?? ""
                                    self.attributes[name] = value
                                })
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                        }
                    }
                    
                    Menu {
                        // Picker
                        Picker("New", selection: self.$newValue) {
                            ForEach(getAttributeValues(a), id: \.self) { value in
                                Text(value)
                                    .tag(value)
                            }
                            if getAttributeValues(a).isEmpty {
                                Text("No presets. \(self.bob.attributeList[a].restrictPresets ? "Create some in the attribute menu!" : "Create a new value in the text box!")")
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .onChange(of: self.newValue, perform: { value in
                            PersistenceController.haptic(.medium)
                            let name = self.bob.attributeList[a].name ?? ""
                            self.attributes[name] = value
                        })
                    } label: {
                        Image(systemName: "chevron.down.circle")
                            .imageScale(.large)
                            .foregroundColor(PersistenceController.themeColor)
                    }
                }
            }
            
            // Number
            else if bob.attributeList[a].type == 1 {
                
                HStack {
                
                    ZStack {
                        
                        HStack {
                            
                            Spacer()
                            
                            // Prefix
                            if bob.attributeList[a].prefix ?? "" != "" {
                                Text(bob.attributeList[a].prefix!)
                                    .foregroundColor(Color(UIColor.systemGray))
                                    .multilineTextAlignment(.trailing)
                            }
                            
                            // Number Display
                            Text(self.newValue != "" ? self.newValue : self.getRangeText())
                                .multilineTextAlignment(.trailing)
                                .lineLimit(0)
                                .opacity(0)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                                )
                        }
                        
                        HStack {
                            
                            // Prefix
                            if bob.attributeList[a].prefix ?? "" != "" {
                                Text(bob.attributeList[a].prefix!)
                                    .opacity(0)
                            }
                            
                            // Number Editor
                            TextField(self.getRangeText(), text: self.$newValue, onCommit: {
                                // Reject if not a number
                                if Double(self.newValue) == nil {
                                    self.newValue = ""
                                    self.displayOutOfRangeWarning.toggle()
                                    return
                                }
                                // Turn to integer if decimals are not allowed
                                if !self.bob.attributeList[a].decimal && Int(self.newValue) == nil {
                                    self.newValue = String(Int(Double(self.newValue)!))
                                }
                                // Reject if too low out of range, included
                                if (Double(self.newValue)! < self.bob.attributeList[a].minNum) && self.bob.attributeList[a].minIncluded {
                                    self.newValue = ""
                                    self.displayOutOfRangeWarning.toggle()
                                }
                                // Reject if too low out of range, not included
                                else if (Double(self.newValue)! <= self.bob.attributeList[a].minNum) && !self.bob.attributeList[a].minIncluded {
                                    self.newValue = ""
                                    self.displayOutOfRangeWarning.toggle()
                                }
                                // Reject if too high out of range, included
                                else if (Double(self.newValue)! > self.bob.attributeList[a].maxNum) && self.bob.attributeList[a].maxIncluded {
                                    self.newValue = ""
                                    self.displayOutOfRangeWarning.toggle()
                                }
                                // Reject if too high out of range, not included
                                else if (Double(self.newValue)! >= self.bob.attributeList[a].maxNum) && !self.bob.attributeList[a].maxIncluded {
                                    self.newValue = ""
                                    self.displayOutOfRangeWarning.toggle()
                                }
                                let name = self.bob.attributeList[a].name ?? ""
                                self.attributes[name] = self.newValue
                            })
                            .onChange(of: self.newValue, perform: { value in
                                // Reject if not a number
                                if Double(value) == nil {
                                    return
                                }
                                // Turn to integer if decimals are not allowed
                                if !self.bob.attributeList[a].decimal && Int(value) == nil {
                                    return
                                }
                                // Reject if too low out of range, included
                                if (Double(value)! < self.bob.attributeList[a].minNum) && self.bob.attributeList[a].minIncluded {
                                    return
                                }
                                // Reject if too low out of range, not included
                                else if (Double(value)! <= self.bob.attributeList[a].minNum) && !self.bob.attributeList[a].minIncluded {
                                    return
                                }
                                // Reject if too high out of range, included
                                else if (Double(value)! > self.bob.attributeList[a].maxNum) && self.bob.attributeList[a].maxIncluded {
                                    return
                                }
                                // Reject if too high out of range, not included
                                else if (Double(value)! >= self.bob.attributeList[a].maxNum) && !self.bob.attributeList[a].maxIncluded {
                                    return
                                }
                                let name = self.bob.attributeList[a].name ?? ""
                                self.attributes[name] = value
                            })
                            .keyboardType(.numbersAndPunctuation)
                            .multilineTextAlignment(.trailing)
                            .minimumScaleFactor(0.5)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                        }
                    }
                    
                    // Suffix
                    if bob.attributeList[a].suffix ?? "" != "" {
                        Text(bob.attributeList[a].suffix!)
                            .foregroundColor(Color(UIColor.systemGray))
                            .multilineTextAlignment(.trailing)
                    }
                }
                .alert(isPresented: self.$displayOutOfRangeWarning) {
                    Alert(title: Text("Out of Range"), message: Text(getRangeText()))
                }
            }
            
            // Boolean
            else if bob.attributeList[a].type == 2 {
                
                Toggle(isOn: Binding(get: { self.newValue == "True" ? true : false },
                    set: { value in
                        if value == true {
                             self.newValue = "True"
                        } else {
                            self.newValue = "False"
                        }
                    })) {
                        Text("")
                    }
                    .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                    .onChange(of: self.newValue, perform: { value in
                        let name = self.bob.attributeList[a].name ?? ""
                        self.attributes[name] = value
                    })
            }
        }
        .onAppear {
            self.newValue = self.attributes[self.bob.attributeList[a].name ?? ""] ?? ""
            
            // Set all booleans to false
            if self.bob.attributeList[a].type == 2 && self.attributes[self.bob.attributeList[a].name ?? ""] == nil {
                self.newValue = "False"
            }
        }
    }
    
    func getAttributeValues(_ attribute: Int) -> [String] {
        var presets = self.bob.attributeList[attribute].presets ?? []
        let name = self.bob.attributeList[attribute].name ?? ""
        for bit in bob.bitArray {
            let value = bit.attributes?[name] ?? ""
            if !presets.contains(value) && value != "" {
                presets += [value]
            }
        }
        return presets
    }
    
    func getRangeText() -> String {
        let a = self.bob.attributeList[a]
        if a.decimal {
            return (a.minNum == -.infinity ? "-∞" : String(a.minNum)) + " " + (a.minIncluded ? "≤" : "<") + " x " + (a.maxIncluded ? "≤" : "<") + " " + (a.maxNum == .infinity ? "∞" : String(a.maxNum))
        } else {
            return (a.minNum == -.infinity ? "-∞" : String(Int(a.minNum))) + " " + (a.minIncluded ? "≤" : "<") + " x " + (a.maxIncluded ? "≤" : "<") + " " + (a.maxNum == .infinity ? "∞" : String(Int(a.maxNum)))
        }
    }
}

