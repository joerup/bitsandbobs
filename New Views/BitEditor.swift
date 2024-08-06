//
//  BitEditor.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 3/20/21.
//

import SwiftUI
import WrappingHStack

struct BitEditor: View {
    
    var bit: Bit? = nil
    var bob: Bob
    var bits: [Bit]
    
    @State var name = ""
    @State var desc = ""
    @State var paragraph = ""
    @State var image = UIImage()
    @State var tags: [String] = []
    @State var attributes: [String:String] = [:]
    @State var checked = false
    
    private var create = true

    @State private var deleteBit = false
    
    @State private var createEmptyWarning = false
    @State private var cancelAlert = false
    @State private var editTags = false
    @FocusState private var keyboardFocused: Bool
    
    @State private var hasChanges = false

    @Environment(\.dismiss) var dismiss
    
    @Environment(\.managedObjectContext) var managedObjectContext
    var dismissNavigation: DismissAction? = nil
    
    init(bit: Bit? = nil, bob: Bob, bits: [Bit], dismissNavigation: DismissAction? = nil) {
        self.bit = bit
        self.bob = bob
        self.bits = bits
        self.dismissNavigation = dismissNavigation
        
        if let bit {
            self.create = false
            self._name = State(initialValue: bit.name ?? "")
            self._desc = State(initialValue: bit.desc ?? "")
            self._paragraph = State(initialValue: bit.paragraph ?? "")
            self._image = State(initialValue: bit.image != nil ? UIImage(data: bit.image!)! : UIImage())
            self._tags = State(initialValue: bit.tags ?? [])
            self._attributes = State(initialValue: bit.attributes ?? [:])
            self._checked = State(initialValue: bit.checked)
            if paragraph.filter({ $0 != " " }).isEmpty {
                self.paragraph = ""
            }
        }
    }

    var body: some View {
        
        NavigationStack {
            
            Form {
                
                Section(header: HStack {
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
                    .onChange(of: image) { _ in
                        hasChanges = true
                    }
                    Spacer()
                }) { }
                
                Section {
                    AStack {
                        Text("Name")
                        Spacer()
                        TextField("Name", text: self.$name)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: name) { _ in
                                hasChanges = true
                            }
                    }
                    AStack {
                        Text("Description")
                        Spacer()
                        TextField("Description", text: self.$desc)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: desc) { _ in
                                hasChanges = true
                            }
                    }
                    AStack {
                        Text("Collection")
                        Spacer()
                        HStack {
                            Spacer()
                            Text(self.bob.name ?? "")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                if bob.listType == 1 {
                    Section {
                        HStack {
                            Text("Check")
                            Spacer()
                            Checkmark(checked: checked) {
                                self.checked.toggle()
                                hasChanges = true
                            }
                            .padding(.vertical, 3)
                        }
                    }
                }
                
                Section(header: Text("Tags").font(.callout)) {
                    WrappingHStack(0...self.tags.count, id: \.self) { t in
                        ZStack(alignment: .topTrailing) {
                            ZStack {
                                Text(t < tags.count ? tags[t] : "").font(.system(.headline, design: .rounded).weight(.semibold)).opacity(0).disabled(true)
                                    .overlay {
                                        if t == tags.count {
                                            let allTags = self.bob.tagList.filter({ !tags.contains($0) })
                                            if allTags.isEmpty {
                                                Button {
                                                    self.tags.append("")
                                                } label: {
                                                    Image(systemName: "plus")
                                                        .font(.callout.weight(.semibold))
                                                        .padding(10)
                                                }
                                            } else {
                                                Menu {
                                                    ForEach(allTags, id: \.self) { tag in
                                                        Button {
                                                            self.tags.append(tag)
                                                        } label: {
                                                            Text(tag)
                                                        }
                                                    }
                                                    Section {
                                                        Button {
                                                            self.tags.append("")
                                                        } label: {
                                                            Label("New", systemImage: "plus")
                                                        }
                                                    }
                                                } label: {
                                                    Image(systemName: "plus")
                                                        .font(.callout.weight(.semibold))
                                                        .padding(10)
                                                }
                                            }
                                        } else if t == tags.count-1 {
                                            TextField("Tag", text: Binding(
                                                get: { self.tags[t] },
                                                set: { self.tags[t] = $0 }))
                                            .font(.system(.headline, design: .rounded).weight(.semibold))
                                            .focused($keyboardFocused)
                                            .onAppear {
                                                guard tags[t].isEmpty else { return }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    keyboardFocused = true
                                                }
                                            }
                                        } else {
                                            TextField("Tag", text: Binding(
                                                get: { self.tags[t] },
                                                set: { self.tags[t] = $0 }))
                                            .font(.system(.headline, design: .rounded).weight(.semibold))
                                        }
                                    }
                                
                            }
                            .padding(10)
                            .padding(.horizontal, 5)
                            .frame(minWidth: 40, minHeight: 40)
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray6)))
                            .padding(.vertical, 5)
                            
                            if t < tags.count {
                                Button {
                                    self.tags.remove(at: t)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(Color(uiColor: .systemGray3))
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing, -5)
                            }
                        }
                    }
                }
                .onChange(of: tags) { tags in
                    hasChanges = true
                    while self.tags.count >= 2 && self.tags[self.tags.count-2].isEmpty && self.tags[self.tags.count-1].isEmpty {
                        self.tags.removeLast()
                    }
                }
                
                if !self.bob.attributeList.isEmpty {
                    
                    Section(header: Text("Attributes").font(.callout)) {
                        
                        ForEach(self.bob.attributeList.indices, id: \.self) { a in
                            let attribute = self.bob.attributeList[a]
                            AStack(alignment: .center) {
                                Text(attribute.displayName ?? "")
                                Spacer()
                                VStack(alignment: .trailing) {
                                    let count = !attribute.allowMultiple ? 1 : attribute.maxCount != 0 ? Int(attribute.maxCount) : ((self.attributes[attribute.name ?? ""]?.filter({ $0 == Constants.delimiter }).count ?? 0) + ((self.attributes[attribute.name ?? ""]?.last ?? Constants.delimiter) == Constants.delimiter ? 1 : 2))
                                    ForEach(0..<count, id: \.self) { index in
                                        AttrValueSetter(attributes: self.$attributes, a: a, index: index, bob: self.bob)
                                    }
                                }
                            }
                        }
                    }
                    .onChange(of: attributes) { _ in
                        hasChanges = true
                    }
                }
                
                Section(header: Text("Text").font(.callout)) {
                    TextField("Text", text: self.$paragraph, axis: .vertical)
                        .onChange(of: paragraph) { _ in
                            hasChanges = true
                        }
                }
                
                if !create {
                    Button(role: .destructive) {
                        self.deleteBit.toggle()
                    } label: {
                        HStack {
                            Text("Delete Item")
                            Spacer()
                            Image(systemName: "trash")
                                .font(.callout)
                        }
                    }
                }
            }
            .navigationBarTitle(create ? "New Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if !hasChanges {
                            dismiss()
                        } else {
                            self.cancelAlert.toggle()
                        }
                    }) {
                        Text("Cancel")
                            .font(.system(.headline, design: .rounded))
                    }
                    .confirmationDialog("Cancel", isPresented: $cancelAlert) {
                        Button(create ? "Delete Item" : "Discard Changes", role: .destructive) {
                            dismiss()
                        }
                        Button(create ? "Save Item" : "Save Changes") {
                            saveBit()
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        saveBit()
                    }) {
                        Text("Save")
                            .font(.system(.headline, design: .rounded).bold())
                    }
                    .disabled(self.name == "")
                    .alert(isPresented: self.$createEmptyWarning) {
                        Alert(title: Text("Please give the item a name."))
                    }
                }
            }
            .alert(isPresented: $deleteBit) {
                Alert(
                    title: Text("Delete \(self.name)"),
                    message: Text("Are you sure you want to delete this item?"),
                    primaryButton: .cancel() {
                        deleteBit = false
                    },
                    secondaryButton: .destructive(Text("Delete")) {
                        dismiss()
                        dismissNavigation?()
                        removeBit()
                    }
                )
            }
        }
        .interactiveDismissDisabled()
        .tint(PersistenceController.themeColor)
    }
    
    func removeBit() {
        guard let bit else { return }
        var revisedItems: [Bit] = bits
        // Remove the bit
        revisedItems.remove(at: Int(bit.order))
        managedObjectContext.delete(bit)
        reorderBits(revisedItems)
        PersistenceController.shared.save()
    }
    
    func reorderBits(_ array: [Bit]) {
        let revisedItems = array
        var index = 0
        while index < revisedItems.count {
            revisedItems[index].order = Int16(index)
            index += 1
        }
        bob.nextBitID = Int16(revisedItems.count)
        PersistenceController.shared.save()
    }
        
    func saveBit() {

        guard self.name != "" else {
            self.createEmptyWarning.toggle()
            return
        }
        
        tags = tags.filter { !$0.isEmpty }
        
        if create {
            
            let bit = Bit(context: managedObjectContext)
           
            bit.order = bob.nextBitID
            bob.nextBitID += 1
            
            bit.name = self.name
            bit.desc = self.desc
            bit.paragraph = self.paragraph
            bit.image = self.image.jpegData(compressionQuality: 0.75)
            bit.icon = bit.image?.compressed()
            bit.bob = self.bob
            bit.tags = self.tags
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
                bit!.icon = bit!.image?.compressed()
                bit!.tags = self.tags
                bit!.attributes = self.attributes
                bit!.checked = self.checked
            }
            
            var revisedItems: [Bit] = bob.bitArray.map{ $0 }
            revisedItems[Int(bit!.order)] = bit!
            bob.bits = NSSet(array: revisedItems)
        }
        
        PersistenceController.shared.save()

        dismiss()
    }
}

struct AttrValueSetter: View {
    
    @Binding var attributes: [String:String]
    
    var a: Int
    var index: Int
    var bob: Bob
    
    @State private var newValue = ""
    
    var body: some View {
        
        Group {
            
            // Text
            if bob.attributeList[a].type == 0 {
                
                HStack {
                    
                    ZStack {
                        
                        // Text Display
                        HStack {
                            Spacer()
                            Text(self.newValue != "" ? self.newValue : self.bob.attributeList[a].displayName ?? "")
                                .foregroundColor(self.newValue == "" ? Color(UIColor.tertiaryLabel) : nil)
                                .lineLimit(0)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color(UIColor.systemGray3), lineWidth: 1)
                                )
                        }
                        
                        // Text Editor
                        TextField(self.bob.attributeList[a].displayName ?? "", text: self.$newValue)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: self.newValue, perform: { value in
                                setValue(value)
                            })
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                    }
                    
                    Menu {
                        // Picker
                        Picker("", selection: self.$newValue) {
                            ForEach(getPresets(a), id: \.self) { value in
                                Text(value)
                                    .tag(value)
                            }
                        }
                        Picker("", selection: self.$newValue) {
                            Text("None")
                                .tag("")
                        }
                    } label: {
                        Image(systemName: "chevron.down.circle")
                            .imageScale(.large)
                    }
                    .onChange(of: self.newValue, perform: { value in
                        setValue(value)
                    })
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
                            Text(self.newValue != "" ? self.newValue : bob.attributeList[a].displayName ?? "")
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
                            TextField(bob.attributeList[a].displayName ?? "", text: self.$newValue, onCommit: {
                                // Empty
                                if newValue.isEmpty {
                                    setValue("")
                                    return
                                }
                                // Reject if not a number
                                if Double(self.newValue) == nil {
                                    self.newValue = ""
                                    setValue("")
                                    return
                                }
                                // Turn to integer if decimals are not allowed
                                if !self.bob.attributeList[a].decimal && Int(self.newValue) == nil {
                                    self.newValue = String(Int(Double(self.newValue)!))
                                }
                                setValue(self.newValue)
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
                                setValue(value)
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
                    .onChange(of: self.newValue, perform: { value in
                        setValue(value)
                    })
            }
            
            // Date
            else if bob.attributeList[a].type == 3 {
                
                HStack {
                    let formatter = ISO8601DateFormatter()
                    if let date = formatter.date(from: self.newValue) {
                        DatePicker(selection: Binding(
                            get: {
                                return date
                            },
                            set: { date in
                                self.newValue = formatter.string(from: date)
                            }
                        ), displayedComponents: .date) {
                            Text("")
                        }
                        .datePickerStyle(CompactDatePickerStyle())
                        Button {
                            self.newValue = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                                .imageScale(.small)
                        }
                    } else {
                        Button {
                            self.newValue = formatter.string(from: Date())
                        } label: {
                            Text("Date")
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                                .padding(7)
                                .background(Color(UIColor.tertiarySystemFill).cornerRadius(7))
                        }
                    }
                }
                .onChange(of: self.newValue, perform: { value in
                    print(value)
                    setValue(value)
                })
            }
        }
        .onAppear {
            // Set the current value
            let value = self.attributes[self.bob.attributeList[a].name ?? ""] ?? ""
            let values = split(value)
            self.newValue = index < values.count ? values[index] : ""
            
            // Set all booleans to false
            if self.bob.attributeList[a].type == 2 && self.attributes[self.bob.attributeList[a].name ?? ""] == nil {
                self.newValue = "False"
            }
        }
    }
    
    func setValue(_ value: String) {
        let attribute = self.bob.attributeList[a]
        if attribute.allowMultiple {
            var values = split(self.attributes[attribute.name ?? ""] ?? "")
            while index >= values.count {
                values.append("")
            }
            values[index] = value
            if attribute.maxCount != 0 {
                while values.count > attribute.maxCount {
                    values.removeLast()
                }
            }
            self.attributes[attribute.name ?? ""] = join(values)
        } else {
            self.attributes[attribute.name ?? ""] = value
        }
    }
    
    func split(_ value: String) -> [String] {
        return value.components(separatedBy: CharacterSet(charactersIn: String(Constants.delimiter)))
    }
    func join(_ values: [String]) -> String {
        return values.joined(separator: String(Constants.delimiter))
    }
    
    func getPresets(_ attribute: Int) -> [String] {
        var presets = self.bob.attributeList[attribute].presets?.filter { !$0.isEmpty } ?? []
        let name = self.bob.attributeList[attribute].name ?? ""
        for bit in bob.bitArray {
            for value in bit.allAttributeValues(name) {
                if !presets.contains(value) && value != "" {
                    presets += [value]
                }
            }
        }
        return presets
    }
}

