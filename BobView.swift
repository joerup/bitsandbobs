//
//  BobView.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import SwiftUI
import Foundation

struct BobView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext

    var bob: Bob
    
    @State private var groups: [String] = []
    @State private var bitLists: [String:[Bit]] = [:]
    @State private var groupableAttributes: [Attribute] = []
    @State private var sortableAttributes: [Attribute] = []
    
    @State private var topTitle = false

    @State private var editBob = false
    @State private var newBit = false
    @State private var editBits = false
    
    @State private var display: ListType = .smallList
    @State private var group = 0
    @State private var sort = 0
    @State private var tags: [String] = []
    @State private var checkedOnly: Bool? = nil
    @State private var attributeFilters: [(attribute: String, value: String)] = []
    @State private var sortReversed = false
    @State private var showTags = false
    @State private var showSearch = false
    @State private var search = ""
    @FocusState private var keyboardFocused: Bool
    
    @State private var update = false
    
    init(bob: Bob) {
        self.bob = bob
        self._display = State(initialValue: ListType.init(rawValue: Int(bob.displayType)) ?? .smallList)
        self._group = State(initialValue: Int(bob.group))
        self._sort = State(initialValue: Int(bob.sort))
        self._sortReversed = State(initialValue: bob.sortReversed)
    }
    
    var body: some View {

        GeometryReader { geometry in
            
            ScrollView {
                
                VStack(spacing: 0) {
                    
                    ZStack {
                        if bob.image == nil {
                            Rectangle()
                                .fill(Color.init(red: 0.9, green: 0.7, blue: 0.4, opacity: 0.2))
                                .frame(width: max(geometry.size.width-20, 1), height: UIScreen.main.bounds.height*0.15)
                                .cornerRadius(20)
                                .padding(10)
                        }
                        
                        Image(uiImage: bob.image != nil ? UIImage(data: bob.image!) ?? UIImage() : UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 1)
                            .frame(height: UIScreen.main.bounds.height*0.15)
                            .cornerRadius(20)
                            .padding(10)
                        
                        VStack {
                            Text(bob.name ?? "")
                                .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                                .tracking(-0.5)
                                .lineLimit(0)
                                .minimumScaleFactor(0.2)
                                .foregroundColor(bob.image != nil ? Color(UIColor.white) : Color(UIColor.label))
                                .shadow(color: .black, radius: bob.image != nil ? 10 : 0)
                            
                            if bob.desc != nil && bob.desc != "" {
                                Text(bob.desc ?? "")
                                    .font(.system(.headline, design: .rounded).weight(.heavy))
                                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                                    .tracking(-0.25)
                                    .lineLimit(0)
                                    .minimumScaleFactor(0.2)
                                    .foregroundColor(Color(bob.image != nil ? UIColor.white : UIColor.systemGray))
                                    .shadow(color: .black, radius: bob.image != nil ? 10 : 0)
                            }
                        }
                        .frame(height: UIScreen.main.bounds.height*0.15)
                        .padding(.horizontal)
                    }
                    
                    if showSearch {
                        HStack(spacing: 0) {
                            Image(systemName: "magnifyingglass")
                                .fontWeight(.bold)
                                .foregroundColor(PersistenceController.themeColor)
                                .dynamicTypeSize(..<DynamicTypeSize.xxxLarge)
                                .padding(.horizontal, 5)
                                .aspectRatio(1.0, contentMode: .fill)
                            TextField("Search", text: self.$search, onCommit: {
                                if search == "" {
                                    withAnimation {
                                        self.showSearch = false
                                    }
                                }
                            })
                            .fontWeight(.regular)
                            .dynamicTypeSize(..<DynamicTypeSize.xxxLarge)
                            .padding(.horizontal, 7)
                            .focused($keyboardFocused)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    keyboardFocused = true
                                }
                            }
                            Spacer()
                            Button {
                                withAnimation {
                                    self.search = ""
                                    self.showSearch = false
                                    setGroupAndSort()
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.small)
                                    .foregroundColor(Color(UIColor.systemGray))
                                    .dynamicTypeSize(..<DynamicTypeSize.xxxLarge)
                                    .padding(.horizontal, 5)
                            }
                            .buttonStyle(.plain)
                        }
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                        .frame(height: 32)
                        .padding(.horizontal, 5)
                        .background(Color(UIColor.systemGray6).cornerRadius(10))
                        .padding(.vertical, 2)
                        .padding(.bottom, 8)
                        .padding(.horizontal, 10)
                        .transition(.opacity)
                    }
                    
                    if showTags {
                        ScrollView(.horizontal) {
                            let filterableAttributes = bob.attributeList.filter { $0.taggable }
                            if bob.tagList.isEmpty && bob.listType != 1 && filterableAttributes.isEmpty {
                                Text("No filters available")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 10)
                                    .padding(5)
                            }
                            HStack(spacing: 20) {
                                if bob.listType == 1 {
                                    HStack(spacing: 5) {
                                        Button {
                                            if let checkedOnly, checkedOnly {
                                                self.checkedOnly = nil
                                            } else {
                                                self.checkedOnly = true
                                            }
                                        } label: {
                                            Image(systemName: "checkmark")
                                                .font(.system(.footnote, design: .rounded).weight(.semibold))
                                                .dynamicTypeSize(..<DynamicTypeSize.xLarge)
                                                .foregroundColor((checkedOnly ?? false) ? .white : .primary)
                                                .frame(width: 32, height: 32)
                                                .background(RoundedRectangle(cornerRadius: 15).fill((checkedOnly ?? false) ? PersistenceController.themeColor : Color(uiColor: .systemGray6)))
                                        }
                                        Button {
                                            if let checkedOnly, !checkedOnly {
                                                self.checkedOnly = nil
                                            } else {
                                                self.checkedOnly = false
                                            }
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.system(.footnote, design: .rounded).weight(.semibold))
                                                .dynamicTypeSize(..<DynamicTypeSize.xLarge)
                                                .foregroundColor(!(checkedOnly ?? true) ? .white : .primary)
                                                .frame(width: 32, height: 32)
                                                .background(RoundedRectangle(cornerRadius: 15).fill(!(checkedOnly ?? true) ? PersistenceController.themeColor : Color(uiColor: .systemGray6)))
                                        }
                                    }
                                }
                                if !bob.tagList.isEmpty {
                                    HStack(spacing: 5) {
                                        ForEach(bob.tagList, id: \.self) { tag in
                                            Button {
                                                if let index = tags.firstIndex(of: tag) {
                                                    self.tags.remove(at: index)
                                                } else {
                                                    self.tags.append(tag)
                                                }
                                            } label: {
                                                Text(tag)
                                                    .font(.system(.footnote, design: .rounded).weight(.semibold))
                                                    .foregroundColor(tags.contains(tag) ? .white : .primary)
                                                    .dynamicTypeSize(..<DynamicTypeSize.xxxLarge)
                                                    .padding(10)
                                                    .frame(height: 32)
                                                    .background(RoundedRectangle(cornerRadius: 15).fill(tags.contains(tag) ? PersistenceController.themeColor : Color(uiColor: .systemGray6)))
                                            }
                                        }
                                    }
                                }
                                ForEach(filterableAttributes, id: \.name) { attribute in
                                    HStack(spacing: 5) {
                                        ForEach(getAllAttributeValues(for: attribute, among: bob.bitArray), id: \.self) { value in
                                            let filter = (attribute: attribute.name ?? "", value: value)
                                            Button {
                                                if let index = attributeFilters.firstIndex(where: { $0.attribute == filter.attribute && $0.value == filter.value }) {
                                                    attributeFilters.remove(at: index)
                                                } else {
                                                    attributeFilters.append(filter)
                                                }
                                            } label: {
                                                let filterActive = attributeFilters.contains(where: { $0.attribute == filter.attribute && $0.value == filter.value })
                                                Text(attributeValueText(attribute: attribute, value: value))
                                                    .font(.system(.footnote, design: .rounded).weight(.semibold))
                                                    .foregroundColor(filterActive ? .white : .primary)
                                                    .dynamicTypeSize(..<DynamicTypeSize.xxxLarge)
                                                    .padding(10)
                                                    .frame(height: 32)
                                                    .background(RoundedRectangle(cornerRadius: 15).fill(filterActive ? PersistenceController.themeColor : Color(uiColor: .systemGray6)))
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        .scrollIndicators(.hidden)
                        .padding(.vertical, 2)
                        .padding(.bottom, 8)
                        .transition(.opacity)
                    }
                    
                    HStack {
                        
                        Menu {
                            Picker("", selection: self.$display) {
                                ForEach(ListType.allCases, id: \.rawValue) { type in
                                    Label(type.name, systemImage: type.icon)
                                        .tag(type)
                                }
                            }
                        } label: {
                            circle(icon: display.icon, active: false)
                        }
                        
                        Menu {
                            Picker("", selection: self.$group) {
                                ForEach(0..<groupableAttributes.count+1, id : \.self) { a in
                                    Text(getGroup(a, display: true))
                                        .tag(a)
                                }
                            }
                        } label: {
                            circle(icon: "folder", active: group != 0)
                        }
                        
                        Menu {
                            Picker("", selection: self.$sort) {
                                ForEach(0..<sortableAttributes.count+2, id : \.self) { a in
                                    Text(getSort(a, display: true))
                                        .tag(a)
                                }
                            }
                            Section {
                                Picker("", selection: self.$sortReversed) {
                                    Label("Forward", systemImage: "arrow.down")
                                        .tag(false)
                                    Label("Reverse", systemImage: "arrow.up")
                                        .tag(true)
                                }
                                .onTapGesture {
                                    sortReversed.toggle()
                                }
                            }
                        } label: {
                            circle(icon: "arrow.up.arrow.down", active: sort != 0 || sortReversed)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation {
                                self.showTags.toggle()
                                setGroupAndSort()
                            }
                        } label: {
                            circle(icon: "line.3.horizontal.decrease", active: showTags)
                        }
                        
                        Button {
                            withAnimation {
                                self.showSearch.toggle()
                                setGroupAndSort()
                            }
                        } label: {
                            circle(icon: "magnifyingglass", active: showSearch)
                        }
                    }
                    .onChange(of: self.display) { _ in
                        saveBob()
                    }
                    .onChange(of: self.group) { _ in
                        setGroupAndSort()
                        saveBob()
                    }
                    .onChange(of: self.sort) { _ in
                        setGroupAndSort()
                        saveBob()
                    }
                    .onChange(of: self.sortReversed) { _ in
                        setGroupAndSort()
                        saveBob()
                    }
                    .onChange(of: self.tags) { _ in
                        setGroupAndSort()
                    }
                    .onChange(of: self.checkedOnly) { _ in
                        setGroupAndSort()
                    }
                    .onChange(of: self.attributeFilters.count) { _ in
                        setGroupAndSort()
                    }
                    .onChange(of: self.search) { _ in
                        setGroupAndSort()
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                    
                    BitList(
                        bob: bob,
                        size: geometry.size,
                        groups: groups,
                        bitLists: bitLists,
                        display: display,
                        group: group,
                        sort: sort,
                        sortReversed: sortReversed,
                        groupName: getGroup(group),
                        groupAttribute: getGroupAttribute(group),
                        sortName: getSort(sort),
                        sortAttribute: getSortAttribute(sort),
                        setGroupAndSort: setGroupAndSort,
                        update: $update
                    )
                }
            }
        }
        .navigationBarTitle("\(self.bob.name ?? "")")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        self.editBob.toggle()
                    } label: {
                        Text("Edit Collection")
                    }
                    Button {
                        self.editBits.toggle()
                    } label: {
                        Text("Edit Items")
                    }
                } label: {
                    Text("Edit")
                        .foregroundColor(PersistenceController.themeColor)
                        .minimumScaleFactor(0.5)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.newBit.toggle()
                }, label: {
                    Image(systemName: "plus")
                })
            }
        }
        .onAppear {
            setGroupAndSort()
            update.toggle()
        }
        .onChange(of: self.newBit) { value in
            if !value {
                setGroupAndSort()
            }
        }
        .onChange(of: self.editBob) { value in
            if !value {
                setGroupAndSort()
            }
        }
        .sheet(isPresented: self.$newBit) {
            BitEditor(bob: bob)
        }
        .sheet(isPresented: self.$editBob) {
            BobEditor(bob: bob)
        }
        .sheet(isPresented: self.$editBits, onDismiss: { setGroupAndSort(); update.toggle() }) {
            BitListEditor(bob: bob)
        }
    }
    
    // Set group and sort
    func setGroupAndSort() {
        self.groupableAttributes = getGroupable()
        self.sortableAttributes = getSortable()
        self.groups = groupBits()
        self.bitLists = [:]
        for group in groups {
            self.bitLists[group] = sortBits(group: group)
        }
        if self.group-1 >= self.groupableAttributes.count {
            self.group = 0
            setGroupAndSort()
        }
        if self.sort-2 >= self.sortableAttributes.count {
            self.sort = 0
            setGroupAndSort()
        }
    }
    
    // MARK: Group
    
    // Get groupable attributes
    func getGroupable() -> [Attribute] {
        var groupable: [Attribute] = []
        for attribute in self.bob.attributeList {
            if (attribute.type == 0 && attribute.groupable) || (attribute.type == 1 && attribute.groupable && !attribute.decimal) || attribute.type == 2 {
                groupable += [attribute]
            }
        }
        return groupable
    }
    // Get specific group name
    func getGroup(_ num: Int, display: Bool = false) -> String {
        if num >= 1 && num-1 < groupableAttributes.count {
            return display ? groupableAttributes[num-1].displayName ?? "" : groupableAttributes[num-1].name ?? ""
        }
        return "None"
    }
    // Get specific group attribute
    func getGroupAttribute(_ num: Int) -> Attribute? {
        if num >= 1 && num-1 < groupableAttributes.count {
            return groupableAttributes[num-1]
        }
        return nil
    }
    // Group the bits
    func groupBits() -> [String] {
        let filteredBits = bob.bitArray.filter { $0.bob == self.bob }
        // Return a single item if no groups specified
        if self.group == 0 {
            return [""]
        }
        // Group by attribute
        else {
            // Get the attribute that groups are grouped by
            let attribute = getGroupAttribute(group)
            guard let attribute else { return [""] }
            // Get all the attribute values
            return getAllAttributeValues(for: attribute, among: filteredBits, includeAll: true)
        }
    }
    
    // MARK: Sort
    
    // Get sortable attributes
    func getSortable() -> [Attribute] {
        var sortable: [Attribute] = []
        for attribute in self.bob.attributeList {
            if (attribute.type == 0 && attribute.sortable) || attribute.type == 1, !attribute.allowMultiple {
                sortable += [attribute]
            }
        }
        return sortable
    }
    // Get specific sorting name
    func getSort(_ num: Int, display: Bool = false) -> String {
        if num >= 2 && num-2 < sortableAttributes.count {
            return display ? sortableAttributes[num-2].displayName ?? "" : sortableAttributes[num-2].name ?? ""
        }
        else if num == 1 {
            return "Name"
        }
        return bob.listType == 2 ? "Ranking" : "Default"
    }
    // Get specific sorting attribute
    func getSortAttribute(_ num: Int) -> Attribute? {
        if num >= 2 && num-2 < sortableAttributes.count {
            return sortableAttributes[num-2]
        }
        return nil
    }
    // Sort the bits
    func sortBits(group: String) -> [Bit] {
        var filteredBits = bob.bitArray.filter { $0.bob == self.bob }
        if showSearch && !search.isEmpty {
            filteredBits = filteredBits.filter { $0.name?.uppercased().contains(self.search.uppercased()) ?? false }
        }
        if showTags {
            filteredBits = filtered(filteredBits)
        }
        // Only include bits of a specific group if indicated
        var bitArray: [Bit] = filteredBits
        if group != "" || self.group != 0 {
            bitArray = []
            let attribute = getGroup(self.group)
            for bit in filteredBits {
                autoreleasepool {
                    if bit.allAttributeValues(attribute).contains(group) || ((bit.attributes![attribute] == nil || bit.attributes![attribute] == "") && group == "Unassigned") || ((bit.attributes![attribute] == nil || bit.attributes![attribute] == "") && group == "False" && getGroupAttribute(self.group)?.type == 2) {
                        bitArray += [bit]
                    }
                }
            }
        }
        // If group out of range, return
        if self.group-1 >= self.groupableAttributes.count {
            return self.sortReversed ? bitArray.reversed() : bitArray
        }
        // Sort by attribute
        if self.sort >= 2 {
            let attribute = getSortAttribute(sort)
            guard attribute != nil else { return self.sortReversed ? bitArray.reversed() : bitArray }
            // Sort by text
            if attribute!.type == 0 {
                var presets = attribute!.presets ?? []
                // Add all bits' values to presets
                for bit in bitArray {
                    autoreleasepool {
                        let value = bit.attributes?[attribute!.name ?? ""] ?? ""
                        if !presets.contains(value) && value != "" {
                            presets += [value]
                        }
                    }
                }
                // Sort by preset order
                if attribute!.sortTextType == 0 {
                    var sortedArray: [Bit] = []
                    for preset in presets {
                        sortedArray += bitArray.filter { $0.attributes![attribute!.name ?? ""] == preset }
                    }
                    let sorted = sortedArray + bitArray.filter { $0.attributes![attribute!.name ?? ""] == nil || $0.attributes![attribute!.name ?? ""] == "" }
                    return self.sortReversed ? sorted.reversed() : sorted
                }
                // Sort by name
                else if attribute!.sortTextType == 1 {
                    if self.sortReversed {
                        return bitArray.sorted { $0.attributes![attribute!.name ?? ""] ?? " " > $1.attributes![attribute!.name ?? ""] ?? " " }
                    }
                    else {
                        return bitArray.sorted { $0.attributes![attribute!.name ?? ""] ?? "ü" < $1.attributes![attribute!.name ?? ""] ?? "ü" }
                    }
                }
            }
            // Sort by number
            else if attribute!.type == 1 {
                if self.sortReversed {
                    return bitArray.sorted { Double($0.attributes![attribute!.name ?? ""] ?? "-inf") ?? -Double.infinity > Double($1.attributes![attribute!.name ?? ""] ?? "-inf") ?? -Double.infinity }
                }
                else {
                    return bitArray.sorted { Double($0.attributes![attribute!.name ?? ""] ?? "inf") ?? Double.infinity < Double($1.attributes![attribute!.name ?? ""] ?? "inf") ?? Double.infinity }
                }
            }
        }
        // Sort by name
        else if self.sort == 1 {
            let sorted = bitArray.sorted { $0.name ?? "" < $1.name ?? "" }
            return self.sortReversed ? sorted.reversed() : sorted
        }
        return self.sortReversed ? bitArray.reversed() : bitArray
    }
    
    private func getAllAttributeValues(for attribute: Attribute, among bits: [Bit], includeAll: Bool = false) -> [String] {
        // Group by text
        if attribute.type == 0 {
            var presets = attribute.presets ?? []
            // Add all bits' values to presets
            var unassigned = false
            for bit in bits {
                autoreleasepool {
                    for value in bit.allAttributeValues(attribute.name) {
                        if !presets.contains(value) && value != "" {
                            presets += [value]
                        }
                        else if value == "" {
                            unassigned = true
                        }
                    }
                }
            }
            // Remove empty presets
            presets = presets.filter { !$0.isEmpty }
            // Group by preset order
            if attribute.sortTextType == 0 {
                if attribute.unassignedGroup && unassigned {
                    presets += ["Unassigned"]
                }
                return presets
            }
            // Group by name
            else if attribute.sortTextType == 1 {
                presets = presets.sorted(by: { $0 < $1 })
                if attribute.unassignedGroup && unassigned {
                    presets += ["Unassigned"]
                }
                return presets
            }
        }
        // Group by number
        else if attribute.type == 1 {
            var values: [String] = []
            var unassigned = false
            for bit in bits {
                autoreleasepool {
                    for value in bit.allAttributeValues(attribute.name) {
                        if !values.contains(value) && value != "" {
                            values += [value]
                        }
                        else if value == "" {
                            unassigned = true
                        }
                    }
                }
            }
            if unassigned {
                values += ["Unassigned"]
            }
            return values.sorted { Double($0) ?? .infinity < Double($1) ?? .infinity }
        }
        // Group by boolean
        else if attribute.type == 2 {
            return includeAll || !attribute.boolDisplayFalse ? ["True","False"] : ["True"]
        }
        return [""]
    }
    
    private func filtered(_ bits: [Bit]) -> [Bit] {
        bits.filter { bit in
            if let checkedOnly {
                if checkedOnly && !bit.checked { return false }
                if !checkedOnly && bit.checked { return false }
            }
            if !tags.isEmpty, !(bit.tags ?? []).contains(where: { tags.contains($0) }) {
                return false
            }
            for attribute in Set(attributeFilters.map({ $0.attribute })) {
                let selectedValues = attributeFilters.filter({ $0.attribute == attribute }).map({ $0.value })
                if !bit.allAttributeValues(attribute).contains(where: { selectedValues.contains($0) }) {
                    return false
                }
            }
            return true
        }
    }
    
    private func attributeValueText(attribute: Attribute, value: String) -> String {
        let value = BitList.editValueName(value, attribute: attribute)
        switch attribute.type {
        case 2: return attribute.boolDisplayFalse ? "\(attribute.name ?? "")" : value
        default: return value
        }
    }
    
    // MARK: Save
    
    func saveBob() {
        
        managedObjectContext.performAndWait {
            bob.displayType = Int16(self.display.rawValue)
            bob.group = Int16(self.group)
            bob.sort = Int16(self.sort)
            bob.sortReversed = self.sortReversed
        }
        
        PersistenceController.shared.save()
    }
    
    // MARK: Display
    
    private func circle(icon: String, active: Bool) -> some View {
        Circle()
            .fill(active ? PersistenceController.themeColor : Color(uiColor: .systemGray6))
            .frame(width: 40, height: 40)
            .overlay {
                Image(systemName: icon)
                    .fontWeight(.bold)
                    .dynamicTypeSize(..<DynamicTypeSize.xxxLarge)
                    .foregroundColor(active ? .white : PersistenceController.themeColor)
            }
    }
    
    @ViewBuilder
    private var backgroundImage: some View {
        if let imageData = bob.image, let image = UIImage(data: imageData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 100)
                .opacity(0.2)
        }
    }
}

