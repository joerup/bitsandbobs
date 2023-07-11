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
    
    @State var create = true
    
    @State var nextAttrID: Int16 = 0

    @State private var showDelete = false
    
    @State private var newAttributeText = false
    @State private var newAttributeNum = false
    @State private var newAttributeBool = false
    @State private var newAttributeDate = false
    
    @State private var editAttributes = false
    @State private var editAttribute: Attribute? = nil
    
    @State private var deleteAttribute = false
    @State private var createEmptyWarning = false
    @State private var cancelAlert = false

    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        
        NavigationStack {
                
            Form {
                
                Section(header:
                    HStack {
                        Spacer()
                        ImageEditor(image: self.$image) {
                            ZStack {
                                Icon(image: self.image, size: 100, faded: true)
                                Image(systemName: "photo")
                                    .foregroundColor(Color(UIColor.systemGray))
                                    .font(.largeTitle)
                            }
                        }
                        .padding(.top, 10)
                        Spacer()
                    }
                ) { }

                Section {
                    AStack {
                        Text("Name")
                        Spacer()
                        TextField("Name", text: self.$name)
                            .multilineTextAlignment(.trailing)
                    }
                    AStack {
                        Text("Description")
                        Spacer()
                        TextField("Description", text: self.$desc)
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Collection Type", selection: self.$listType) {
                        Text("Basic")
                            .tag(0)
                        Text("Checklist")
                            .tag(1)
                        Text("Ranking")
                            .tag(2)
                    }
                    .pickerStyle(.menu)
                    .accentColor(PersistenceController.themeColor)
                }
                
                Section(header: HStack {
                    Text("Attributes")
                        .lineLimit(0)
                        .font(.callout)
                    Spacer()
                    if !attributes.isEmpty {
                        Button(action: {
                            self.editAttributes.toggle()
                        }) {
                            Text(self.editAttributes ? "Done" : "Edit")
                                .font(.callout)
                                .foregroundColor(PersistenceController.themeColor)
                        }
                        .padding(.leading)
                    }
                },
                    footer: Text("Each item in the collection can be given a value for each attribute.")
                ) {
                    ForEach(self.attributes, id: \.self) { attribute in
                        Button(action: {
                            self.editAttribute = attribute
                        }) {
                            HStack {
                                Text(attribute.displayName ?? "")
                                    .foregroundColor(Color(UIColor.label))
                                Spacer()
                                Text(getAttributeDescription(attribute))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 5)
                        }
                    }
                    .onMove(perform: moveAttributes)
                    .onDelete(perform: removeAttributes)
                    
                    Menu {
                        Button {
                            self.newAttributeText.toggle()
                        } label: {
                            Text("Text").textCase(nil)
                        }
                        Button {
                            self.newAttributeNum.toggle()
                        } label: {
                            Text("Number").textCase(nil)
                        }
                        Button {
                            self.newAttributeBool.toggle()
                        } label: {
                            Text("Boolean").textCase(nil)
                        }
//                        Button {
//                            self.newAttributeDate.toggle()
//                        } label: {
//                            Text("Date").textCase(nil)
//                        }
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "plus")
                                .font(.callout.weight(.semibold))
                                .foregroundColor(PersistenceController.themeColor)
                            Spacer()
                        }
                    }
                }
            }
            .environment(\.editMode, .constant(self.editAttributes ? EditMode.active : EditMode.inactive))
            .sheet(isPresented: self.$newAttributeText) {
                AttrEditor(attributes: self.$attributes, nextAttrID: self.$nextAttrID, bob: bob, type: 0)
            }
            .sheet(isPresented: self.$newAttributeNum) {
                AttrEditor(attributes: self.$attributes, nextAttrID: self.$nextAttrID, bob: bob, type: 1)
            }
            .sheet(isPresented: self.$newAttributeBool) {
                AttrEditor(attributes: self.$attributes, nextAttrID: self.$nextAttrID, bob: bob, type: 2)
            }
            .sheet(isPresented: self.$newAttributeDate) {
                AttrEditor(attributes: self.$attributes, nextAttrID: self.$nextAttrID, bob: bob, type: 3)
            }
            .sheet(item: self.$editAttribute) { attribute in
                AttrEditor(attribute: attribute, attributes: self.$attributes, nextAttrID: self.$nextAttrID, bob: bob, create: false)
            }
            .navigationBarTitle(create ? "New Collection" : "Edit Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if create && name.isEmpty {
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            self.cancelAlert.toggle()
                        }
                    }) {
                        Text("Cancel")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(PersistenceController.themeColor)
                    }
                    .confirmationDialog("Cancel", isPresented: $cancelAlert) {
                        Button(create ? "Delete Collection" : "Discard Changes", role: .destructive) {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        Button(create ? "Save Collection" : "Save Changes") {
                            saveBob()
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        saveBob()
                    }) {
                        Text("Save")
                            .font(.system(.headline, design: .rounded).bold())
                            .foregroundColor(self.name == "" ? .gray : PersistenceController.themeColor)
                    }
                    .alert(isPresented: self.$createEmptyWarning) {
                        Alert(title: Text("Please give the collection a name."))
                    }
                }
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            guard let bob else { return }
            self.create = false
            self.name = bob.name ?? ""
            self.desc = bob.desc ?? ""
            self.image = bob.image != nil ? UIImage(data: bob.image!)! : UIImage()
            self.attributes = bob.attributeList
            self.nextAttrID = bob.nextAttrID
            self.listType = Int(bob.listType)
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
        else if attribute.type == 3 {
            string += "Date"
        }
        if attribute.allowMultiple {
            string += " (Multiple)"
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
            
        }
        else if bob != nil {
            
            managedObjectContext.performAndWait {
                bob!.name = self.name
                bob!.desc = self.desc
                bob!.image = self.image.jpegData(compressionQuality: 0.75)
                bob!.attributes = NSSet(array: self.attributes)
                bob!.nextAttrID = self.nextAttrID
                bob!.listType = Int16(self.listType)
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

