//
//  BobEditor.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 3/20/21.
//

import SwiftUI

struct BobEditor: View {

    var bob: Bob? = nil
    
    @State var name = ""
    @State var desc = ""
    @State var image = UIImage()
    @State var attributes: [Attribute] = []
    @State var listType: Int = 0
    @State var displayBitIcon = false
    @State var displayBitImgList: Int = 0
    @State var displayBitDescList = true
    
    @State var create = true
    
    @State var nextAttrID: Int16 = 0

    @State private var showDelete = false
    
    @State private var newAttribute = false
    @State private var editAttributes = false
    @State private var editAttribute: Attribute? = nil
    
    @State private var presentImageView = false
    @State private var deleteAttribute = false
    @State private var createEmptyWarning = false

    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        
        ZStack {
            
            ScrollView {

                VStack {
                    
                    VStack {
                        
                        Text(create ? "New Bob" : "Edit Bob")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        Text(create ? "Create a new category" : "Edit the \(name) category")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.systemGray2))
                            .multilineTextAlignment(.center)

                        ZStack {
                            
                            Icon(image: self.image, size: 150, square: true, faded: true)
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

                        TextField("Name", text: self.$name)
                            .font(.title)
                            .multilineTextAlignment(.center)

                        TextField("Description", text: self.$desc)
                            .foregroundColor(Color(UIColor.systemGray))
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    
                    Form {
                        
                        Section(header: Text("Bob Type")) {
                        
                            Picker("Bob Type", selection: self.$listType) {
                                Text("List")
                                    .tag(0)
                                Text("Checklist")
                                    .tag(1)
                                Text("Ranking")
                                    .tag(2)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        Section(header: Text("Attributes")) {
                            
                            ZStack {
                                Text("Attributes")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                HStack {
                                    Button(action: {
                                        PersistenceController.haptic(.medium)
                                        self.newAttribute.toggle()
                                    }) {
                                        Text("New")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(PersistenceController.themeColor)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    Spacer()
                                    Button(action: {
                                        PersistenceController.haptic(.medium)
                                        self.editAttributes.toggle()
                                    }) {
                                        Text(self.editAttributes ? "Done" : "Edit")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(PersistenceController.themeColor)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical, 10)
                                
                            if self.attributes.isEmpty {
                                Text("Define attributes which each bit can be given a value for. For example, 'Level', 'Gender', 'Type', etc.")
                                    .multilineTextAlignment(.center)
                                    .font(.caption)
                                    .foregroundColor(Color(UIColor.systemGray2))
                                    .padding(15)
                            }
                            
                            ForEach(self.attributes, id: \.self) { attribute in
                                Button(action: {
                                    PersistenceController.haptic(.medium)
                                    self.editAttribute = attribute
                                }) {
                                    NavigationLink(destination: EmptyView()) {
                                        HStack {
                                            Text(attribute.displayName ?? "")
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color(UIColor.label))
                                            Spacer()
                                            Text(getAttributeDescription(attribute))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.trailing, 5)
                                    }
                                }
                            }
                            .onMove(perform: moveAttributes)
                            .onDelete(perform: removeAttributes)
                        }
                        
                        Section(header: Text("Bit List Options")) {
                            
                            HStack {
                                Text("Icons")
                                Spacer()
                                Picker("Icons", selection: self.$displayBitImgList) {
                                    Text("Large")
                                        .tag(1)
                                    Text("Small")
                                        .tag(0)
                                    Text("None")
                                        .tag(2)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                            
                            Toggle("Show Description", isOn: self.$displayBitDescList)
                                .toggleStyle(SwitchToggleStyle(tint: PersistenceController.themeColor))
                        }
                        
                        Section(header: Text("Bit Display Options")) {
                            
                            HStack {
                                Text("Bit Image")
                                Spacer()
                                Picker("Bit Image", selection: self.$displayBitIcon) {
                                    Text("Full Image")
                                        .tag(false)
                                    Text("Icon")
                                        .tag(true)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                    }
                    .frame(height: self.attributes.isEmpty ? 800 : CGFloat(self.attributes.count) * 50 + 700)
                    .environment(\.editMode, .constant(self.editAttributes ? EditMode.active : EditMode.inactive))
                    .animation(.default)
                    .sheet(isPresented: self.$newAttribute) {
                        AttrEditor(attributes: self.$attributes, nextAttrID: self.$nextAttrID, bob: bob)
                    }
                    .sheet(item: self.$editAttribute) { attribute in
                        AttrEditor(attribute: attribute, attributes: self.$attributes, nextAttrID: self.$nextAttrID, bob: bob, create: false)
                    }
                }
            }
            
            VStack {
                
                Spacer()
            
                Button(action: {
                    PersistenceController.haptic(.medium)
                    saveBob()
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
                    Alert(title: Text("Please give the bob a name."))
                }
            }
        }
        .onAppear {
            if bob != nil {
                self.create = false
                self.name = bob!.name ?? ""
                self.desc = bob!.desc ?? ""
                self.image = bob!.image != nil ? UIImage(data: bob!.image!)! : UIImage()
                self.attributes = bob!.attributeList
                self.nextAttrID = bob!.nextAttrID
                self.listType = Int(bob!.listType)
                self.displayBitIcon = bob!.displayBitIcon
                self.displayBitImgList = Int(bob!.displayBitImgList)
                self.displayBitDescList = bob!.displayBitDescList
            }
        }
    }
    
    func getAttributeDescription(_ attribute: Attribute) -> String {
        var string = ""
        if attribute.type == 0 {
            if attribute.restrictPresets {
                string += "Preset "
            }
            string += "Text"
        }
        else if attribute.type == 1 {
            if attribute.decimal {
                string += "Decimal "
            }
            string += "Number"
            if attribute.prefix != nil && attribute.suffix != nil && attribute.prefix != "" && attribute.suffix != "" {
                string += " (\(attribute.prefix!) x \(attribute.suffix!))"
            }
            else if attribute.prefix != nil && attribute.prefix != "" {
                string += " (\(attribute.prefix!))"
            }
            else if attribute.suffix != nil && attribute.suffix != "" {
                string += " (\(attribute.suffix!))"
            }
        }
        else if attribute.type == 2 {
            if attribute.boolType == 0 {
                string += "T/F "
            }
            else if attribute.boolType == 1 {
                string += "Y/N "
            }
            string += "Boolean"
        }
        return string
    }

    func saveBob() {

        guard self.name != "" else {
            self.createEmptyWarning.toggle()
            return
        }
        
        if create {
            
            let bob = Bob(context: managedObjectContext)
            
            bob.order = PersistenceController.nextBobID
            PersistenceController.nextBobID += 1
            
            bob.name = self.name
            bob.desc = self.desc
            bob.image = self.image.jpegData(compressionQuality: 0.75)
            bob.attributes = NSSet(array: self.attributes)
            bob.nextAttrID = self.nextAttrID
            bob.listType = Int16(self.listType)
            bob.displayBitIcon = self.displayBitIcon
            bob.displayBitImgList = Int16(self.displayBitImgList)
            bob.displayBitDescList = self.displayBitDescList
            
        }
        else if bob != nil {
            
            managedObjectContext.performAndWait {
                bob!.name = self.name
                bob!.desc = self.desc
                bob!.image = self.image.jpegData(compressionQuality: 0.75)
                bob!.attributes = NSSet(array: self.attributes)
                bob!.nextAttrID = self.nextAttrID
                bob!.listType = Int16(self.listType)
                bob!.displayBitIcon = self.displayBitIcon
                bob!.displayBitImgList = Int16(self.displayBitImgList)
                bob!.displayBitDescList = self.displayBitDescList
            }
        }
        
        PersistenceController.shared.save()

        presentationMode.wrappedValue.dismiss()
    }
    
    func moveAttributes(from source: IndexSet, to destination: Int) {
        var revisedItems: [Attribute] = attributes.map{ $0 }
        revisedItems.move(fromOffsets: source, toOffset: destination )
        for reverseIndex in stride( from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].order = Int16(reverseIndex)
        }
        self.attributes = revisedItems
        PersistenceController.shared.save()
    }
    
    func removeAttributes(at offsets: IndexSet) {
        var revisedItems: [Attribute] = attributes.map{ $0 }
        for index in offsets {
            let attribute = attributes[index]
            revisedItems.remove(at: index)
            managedObjectContext.delete(attribute)
        }
        reorderAttributes(revisedItems)
    }
    
    func reorderAttributes(_ array: [Attribute]) {
        let revisedItems = array
        var index = 0
        while index < revisedItems.count {
            revisedItems[index].order = Int16(index)
            index += 1
        }
        self.attributes = revisedItems
        self.nextAttrID = Int16(revisedItems.count)
        PersistenceController.shared.save()
    }
}

