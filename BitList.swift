//
//  BitList.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 7/9/23.
//

import SwiftUI
import WrappingHStack

struct BitList: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var bob: Bob
    
    var size: CGSize
    
    var groups: [String]
    var bitLists: [String : [Bit]]
    
    var display: ListType
    var group: Int
    var sort: Int
    var sortReversed: Bool
    
    var groupName: String
    var groupAttribute: Attribute?
    
    var sortName: String
    var sortAttribute: Attribute?
    
    var setGroupAndSort: () -> Void
    
    @Binding var update: Bool
    
    @State var groupShowing: [String : Bool] = [:]
    @State private var moveBitWarning = false
    
    private var smallIconSize: CGFloat {
        return horizontalSizeClass == .regular && verticalSizeClass == .regular ? 36 : 32
    }
    private var mediumIconSize: CGFloat {
        return horizontalSizeClass == .regular && verticalSizeClass == .regular ? 60 : 50
    }
    private var largeIconSize: CGFloat {
        return horizontalSizeClass == .regular && verticalSizeClass == .regular ? 100 : 80
    }
    
    var body: some View {
            
        Group {
            
            if self.bob.bitArray.isEmpty {
                HStack {
                    Spacer()
                    Text("This collection is empty.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(UIColor.systemGray))
                        .padding()
                    Spacer()
                }
            } else {
                
                VStack(spacing: 0) {
                    
                    ForEach(self.groups, id: \.self) { group in
                        
                        let name = BitList.editValueName(group, attribute: groupAttribute)
                        let bits = self.bitLists[group] ?? []
                        
                        Section(header: name.isEmpty ? nil : 
                            HStack(alignment: .bottom) {
                                Button {
                                    if self.groupShowing[group] == nil {
                                        self.groupShowing[group] = false
                                    } else {
                                        self.groupShowing[group]?.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Text(name)
                                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                        Image(systemName: "chevron.\((groupShowing[group] ?? true) ? "down" : "forward")")
                                            .font(.system(.caption2, design: .rounded, weight: .semibold))
                                    }
                                }
                                .foregroundColor(Color(uiColor: .secondaryLabel))
                                .dynamicTypeSize(..<DynamicTypeSize.accessibility1)
                                
                                Spacer()
                                
                                Text(bitCountText(bits: bits))
                                    .font(.system(.footnote, design: .rounded, weight: .medium))
                                    .foregroundColor(Color(uiColor: .tertiaryLabel))
                                    .dynamicTypeSize(..<DynamicTypeSize.xxxLarge)
                            }
                            .padding(.horizontal, 15)
                            .padding(.bottom, 7)
                            .padding(.top, 15)
                        ) {
                            if !bits.isEmpty && (self.groupShowing[group] ?? true) {
                                switch display {
                                case .smallList, .largeList:
                                    list(name: name, bits: bits, size: size)
                                case .smallGrid, .largeGrid:
                                    grid(name: name, bits: bits, size: size)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                
                HStack {
                    Spacer()
                    Text("\(displayedBitCountText(bits: bob.bitArray))")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundColor(Color(UIColor.systemGray2))
                        .dynamicTypeSize(..<DynamicTypeSize.xxxLarge)
                    Spacer()
                }
                .padding(15)
            }
        }
        .onChange(of: update) { _ in }
    }
    
    @ViewBuilder
    private func list(name: String, bits: [Bit], size: CGSize) -> some View {
        LazyVStack(spacing: 3) {
            ForEach(bits, id: \.order) { bit in
                NavigationLink(destination: BitView(bit: bit, bob: bob)) {
                    bitRow(bit: bit)
                }
                .padding(.vertical, display == .smallList ? 5 : 8)
                .padding(.horizontal, 10)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(15)
            }
        }
    }
    
    @ViewBuilder
    private func grid(name: String, bits: [Bit], size: CGSize) -> some View {
        let count = (size.width-50) / (display == .smallGrid ? (mediumIconSize+4) : (largeIconSize+5))
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: Int(count))) {
            ForEach(bits, id: \.order) { bit in
                NavigationLink(destination: BitView(bit: bit, bob: bob)) {
                    bitGridItem(bit: bit, size: count/floor(count) * (display == .smallGrid ? mediumIconSize : largeIconSize))
                }
            }
        }
        .padding(10)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(15)
    }
    
    private func bitRow(bit: Bit) -> some View {
        HStack {

            if bob.listType == 2 {
                VStack {
                    Text(String(bit.order+1))
                        .font(.system(bit.order < 9 ? .title3 : .headline, design: .rounded).weight(.semibold))
                        .fontWeight(.bold)
                        .foregroundColor(Color(UIColor.systemGray))
                        .minimumScaleFactor(0.5)
                }
                .frame(width: smallIconSize*0.7, height: smallIconSize, alignment: .center)
                .padding(.trailing, -2)
            }

            icon(bit: bit, size: display == .smallList ? smallIconSize : mediumIconSize)
                .padding(.trailing, 2)

            VStack(alignment: .leading) {

                Text(bit.name ?? "")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.label : UIColor.systemGray))
                    .tracking(-0.5)
                    .lineLimit(0)

                if self.sort >= 2 && bit.attributes != nil && display == .largeList {
                    if sortAttribute?.type == 1 && bit.attributes![sortName] != nil && bit.attributes![sortName] != "" {
                        Text(BitList.editAttributeNumber(bit.attributes![sortName]!, attribute: sortAttribute))
                            .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.systemGray : UIColor.systemGray2))
                            .tracking(-0.25)
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .lineLimit(0)
                    }
                    else if bit.attributes![sortName] != nil && bit.attributes![sortName] != "" {
                        Text(bit.attributes![sortName]!)
                            .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.systemGray : UIColor.systemGray2))
                            .tracking(-0.25)
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .lineLimit(0)
                    }
                }
                else if bit.desc != nil && bit.desc != "" && display == .largeList {
                    Text(bit.desc!)
                        .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.systemGray : UIColor.systemGray2))
                        .tracking(-0.25)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .lineLimit(0)
                }
            }

            Spacer()

            if bob.listType == 1 {
                Check(bob: bob, bit: bit, update: $update)
            }
            
            Image(systemName: "chevron.forward")
                .foregroundColor(Color(uiColor: .quaternaryLabel))
                .imageScale(.small)
        }
        .id(update)
    }
    
    private func bitGridItem(bit: Bit, size: CGFloat) -> some View {
        VStack {
            icon(bit: bit, size: size)
                .overlay(alignment: .bottomLeading) {
                    if bob.listType == 2 {
                        Text(String(bit.order+1))
                            .font(.system(size: 48*size/80, design: .rounded).weight(.heavy))
                            .lineLimit(0)
                            .monospacedDigit()
                            .tracking(-0.5)
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .padding(5*size/80)
                            .minimumScaleFactor(0.05)
                            .frame(width: 32*size/80, height: 32*size/80)
                            .background(Circle().fill(Color(UIColor.systemGray6)))
                            .overlay(RoundedRectangle(cornerRadius: 32*size/80).stroke(Color(uiColor: .systemGray5), lineWidth: 32*size/80/15))
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    if bob.listType == 1 {
                        Check(bob: bob, bit: bit, update: $update, scaleFactor: size/80)
                    }
                }
            
            if display == .largeGrid {
                Text(bit.name ?? "")
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundColor(Color(bob.listType != 1 || bit.checked ? UIColor.label : UIColor.systemGray))
                    .tracking(-0.5)
                    .lineLimit(0)
                    .frame(maxWidth: size)
                    .dynamicTypeSize(..<DynamicTypeSize.accessibility1)
            }
        }
        .padding(2)
        .id(update)
    }
    
    private func icon(bit: Bit, size: CGFloat) -> some View {
        Group {
            if let icon = bit.icon, let image = UIImage(data: icon) {
                Icon(
                    image: image,
                    offset: bit.imageOffset,
                    scale: bit.imageScale,
                    size: size,
                    faded: bob.listType == 1 && !bit.checked
                )
            } else {
                Icon(
                    image: nil,
                    size: size,
                    faded: bob.listType == 1 && !bit.checked
                )
                .overlay {
                    Text(String(bit.name?.first ?? " "))
                        .font(.system(size: size/2, weight: .black, design: .rounded))
                        .foregroundColor(.gray)
                        .opacity(0.2)
                }
            }
        }
    }
    
    private func removeBit(bit: Bit) {
        var revisedItems: [Bit] = bob.bitArray.map{ $0 }
        revisedItems.remove(at: Int(bit.order))
        bob.bits = NSSet(array: revisedItems)
        managedObjectContext.delete(bit)
        reorderBits(revisedItems)
        PersistenceController.shared.save()
    }
    
    private func reorderBits(_ array: [Bit]) {
        let revisedItems = array
        var index = 0
        while index < revisedItems.count {
            revisedItems[index].order = Int16(index)
            index += 1
        }
        bob.bits = NSSet(array: revisedItems)
        bob.nextBitID = Int16(revisedItems.count)
        PersistenceController.shared.save()
        setGroupAndSort()
    }
    
    private func bitCountText(bits: [Bit]) -> String {
        return bob.listType == 1 ? "\(bits.filter({ $0.checked }).count) of \(bits.count)" : "\(bits.count)"
    }
    private func displayedBitCountText(bits: [Bit]) -> String {
        let displayedBits = Array(Set(groups.map({ bitLists[$0] ?? [] }).joined()))
        return bitCountText(bits: displayedBits) + " item\(displayedBits.count == 1 ? "" : "s")"
    }
    
    static func editValueName(_ value: String, attribute: Attribute?) -> String {
        if attribute?.type == 1 && Double(value) != nil {
            return editAttributeNumber(value, attribute: attribute)
        }
        else if attribute?.type == 2 {
            if attribute?.boolType == 1 {
                return "\(attribute?.displayName ?? ""): \(value == "True" ? "Yes" : "No")"
            } else {
                return "\(attribute?.displayName ?? ""): \(value)"
            }
        }
        return value
    }
    
    static func editAttributeNumber(_ value: String, attribute: Attribute?) -> String {
        guard attribute != nil else { return value }
        if attribute!.prefix != nil && attribute!.suffix != nil && attribute!.prefix != "" && attribute!.suffix != "" {
            return attribute!.prefix! + " " + value + " " + attribute!.suffix!
        }
        else if attribute!.prefix != nil && attribute!.prefix != "" {
            return attribute!.prefix! + " " + value
        }
        else if attribute!.suffix != nil && attribute!.suffix != "" {
            return value + " " + attribute!.suffix!
        }
        return value
    }
}

enum ListType: Int, CaseIterable {
    
    case smallList = 0
    case largeList = 1
    case smallGrid = 3
    case largeGrid = 4
    
    var name: String {
        switch self {
        case .smallList:
            return "Small List"
        case .largeList:
            return "Large List"
        case .smallGrid:
            return "Small Grid"
        case .largeGrid:
            return "Large Grid"
        }
    }
    var icon: String {
        switch self {
        case .smallList:
            return "list.bullet"
        case .largeList:
            return "checklist.unchecked"
        case .smallGrid:
            return "circle.grid.3x3"
        case .largeGrid:
            return "circle.grid.2x2"
        }
    }
}
