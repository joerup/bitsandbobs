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
    
    @State var name = ""
    @State var desc = ""
    @State var paragraph = ""
    @State var image = UIImage()
    @State var tags: [String] = []
    @State var attributes: [String:String] = [:]
    @State var checked = false
    
    @State private var create = true

    @State private var showDelete = false
    @State private var createEmptyWarning = false
    @State private var cancelAlert = false
    @State private var editTags = false
    @FocusState private var keyboardFocused: Bool

    @Environment(\.presentationMode) var presentationMode
    
    @Environment(\.managedObjectContext) var managedObjectContext

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
                    Spacer()
                }) { }
                
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
                
                Section(header: Text("Tags").font(.callout)) {
                    WrappingHStack(0...self.tags.count, id: \.self) { t in
                        ZStack(alignment: .topTrailing) {
                            ZStack {
                                Text("Tag").font(.system(.headline, design: .rounded).weight(.semibold)).opacity(0).disabled(true)
                                Text(t < tags.count ? tags[t] : "").font(.system(.headline, design: .rounded).weight(.semibold)).opacity(0).disabled(true)
                                    .overlay {
                                        if t == tags.count {
                                            ZStack {
                                                Button {
                                                    self.tags += [""]
                                                } label: {
                                                    Image(systemName: "plus")
                                                        .font(.callout.weight(.semibold))
                                                        .foregroundColor(PersistenceController.themeColor)
                                                }
                                                .buttonStyle(.plain)
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
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(uiColor: .systemGray6)))
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
                            
                    
                    let allTags = self.bob.tagList.filter({ !tags.contains($0) })
                    if !allTags.isEmpty {
                        WrappingHStack(allTags, id: \.self) { tag in
                            ZStack(alignment: .topTrailing) {
                                
                                Text(tag)
                                    .foregroundColor(.gray)
                                    .font(.system(.headline, design: .rounded).weight(.semibold))
                                    .padding(10)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(uiColor: .systemGray6).opacity(0.7)))
                                    .padding(.vertical, 5)
                                
                                Button {
                                    self.tags.append(tag)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(PersistenceController.themeColor)
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing, -5)
                            }
                        }
                    }
                }
                .onChange(of: tags) { tags in
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
                }
                
                Section(header: Text("Text").font(.callout), footer: Spacer().frame(height: 100)) {
                    TextField("Text", text: self.$paragraph, axis: .vertical)
                }
            }
            .navigationBarTitle(create ? "New Item" : "Edit Item")
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
                        Button(create ? "Delete Item" : "Discard Changes", role: .destructive) {
                            self.presentationMode.wrappedValue.dismiss()
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
                            .foregroundColor(self.name == "" ? .gray : PersistenceController.themeColor)
                    }
                    .alert(isPresented: self.$createEmptyWarning) {
                        Alert(title: Text("Please give the item a name."))
                    }
                }
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            if let bit {
                self.create = false
                self.name = bit.name ?? ""
                self.desc = bit.desc ?? ""
                self.paragraph = bit.paragraph ?? ""
                self.image = bit.image != nil ? UIImage(data: bit.image!)! : UIImage()
                self.tags = bit.tags ?? []
                self.attributes = bit.attributes ?? [:]
                self.checked = bit.checked
                if paragraph.filter({ $0 != " " }).isEmpty {
                    paragraph = ""
                }
            }
        }
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

        presentationMode.wrappedValue.dismiss()
    }
}

struct AttrValueSetter: View {
    
    @Binding var attributes: [String:String]
    
    var a: Int
    var index: Int
    var bob: Bob
    
    @State private var newValue = ""
    
    @State private var displayOutOfRangeWarning = false
    
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
                            TextField(self.bob.attributeList[a].displayName ?? "", text: self.$newValue)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: self.newValue, perform: { value in
                                    setValue(value)
                                })
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                        }
                    }
                    
                    Menu {
                        // Picker
                        Picker("", selection: self.$newValue) {
                            ForEach(getPresets(a), id: \.self) { value in
                                Text(value)
                                    .tag(value)
                            }
                        }
                        if getPresets(a).isEmpty {
                            Text("No presets. \(self.bob.attributeList[a].restrictPresets ? "Create some in the attribute menu!" : "Create a new value in the text box!")")
                                .multilineTextAlignment(.center)
                        }
                        Picker("", selection: self.$newValue) {
                            Text("None")
                                .tag("")
                        }
                    } label: {
                        Image(systemName: "chevron.down.circle")
                            .imageScale(.large)
                            .foregroundColor(PersistenceController.themeColor)
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
                        .accentColor(PersistenceController.themeColor)
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
    
    func getRangeText() -> String {
        let a = self.bob.attributeList[a]
        if a.decimal {
            return (a.minNum == -.infinity ? "-∞" : String(a.minNum)) + " " + (a.minIncluded ? "≤" : "<") + " x " + (a.maxIncluded ? "≤" : "<") + " " + (a.maxNum == .infinity ? "∞" : String(a.maxNum))
        } else {
            return (a.minNum == -.infinity ? "-∞" : String(Int(a.minNum))) + " " + (a.minIncluded ? "≤" : "<") + " x " + (a.maxIncluded ? "≤" : "<") + " " + (a.maxNum == .infinity ? "∞" : String(Int(a.maxNum)))
        }
    }
}

