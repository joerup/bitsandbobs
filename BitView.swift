//
//  BitView.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import SwiftUI
import Foundation
import CoreData
import WrappingHStack

struct BitView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Environment(\.dismiss) var dismiss
    
    @State var bit: Bit
    var bob: Bob

    @State private var editBit = false
    
    @State private var update = false
    
    var body: some View {

        GeometryReader { geometry in
            
            ZStack {

                ScrollView {
                    
                    ZStack {
                        
                        Group {
                            if let imageData = bit.image, let _ = UIImage(data: imageData) {
                                if let imageData = bob.image, let image = UIImage(data: imageData) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .blur(radius: 7)
                                        .opacity(0.2)
                                        .frame(width: max(geometry.size.width-20, 1), height: UIScreen.main.bounds.height*0.5)
                                        .cornerRadius(20)
                                        .padding(10)
                                }
                                else {
                                    Color.init(red: 0.9, green: 0.7, blue: 0.4, opacity: 0.2)
                                        .frame(width: max(geometry.size.width-20, 1), height: UIScreen.main.bounds.height*0.5)
                                        .cornerRadius(20)
                                        .padding(10)
                                }
                            }
                            else if let imageData = bob.image, let image = UIImage(data: imageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .blur(radius: 7)
                                    .opacity(0.2)
                                    .frame(width: max(geometry.size.width-20, 1), height: UIScreen.main.bounds.height*0.15)
                                    .cornerRadius(20)
                                    .padding(10)
                            }
                            else {
                                Color.init(red: 0.9, green: 0.7, blue: 0.4, opacity: 0.2)
                                    .frame(width: max(geometry.size.width-20, 1), height: UIScreen.main.bounds.height*0.15)
                                    .cornerRadius(20)
                                    .padding(10)
                            }
                        }
                        
                        VStack {
                            
                            if let image = bit.image, let uiImage = UIImage(data: image) {
                                
                                Spacer()
                                
                                Icon(image: uiImage, size: UIScreen.main.bounds.height*0.35)
                                    .shadow(color: .black.opacity(0.5), radius: 20)
                            }
                            
                            Spacer()
                            
                            HStack {
                                
                                if bob.listType == 2 {
                                    Text(String(bit.order+1))
                                        .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                                        .tracking(-0.5)
                                        .foregroundColor(Color(UIColor.label))
                                        .frame(width: 48, height: 48)
                                        .lineLimit(0)
                                        .minimumScaleFactor(0.5)
                                        .padding(10)
                                }
                                else if bob.listType == 1 {
                                    Circle()
                                        .frame(width: 48, height: 48)
                                        .opacity(0)
                                        .padding(10)
                                }
                                
                                Spacer()
                            
                                VStack {
                                    Text(bit.name ?? "")
                                        .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                                        .tracking(-0.5)
                                        .lineLimit(0)
                                        .minimumScaleFactor(0.2)
                                        .foregroundColor(Color(UIColor.label))

                                    if let desc = bit.desc, !desc.isEmpty {
                                        Text(desc)
                                            .font(.system(.headline, design: .rounded).weight(.heavy))
                                            .tracking(-0.25)
                                            .lineLimit(0)
                                            .minimumScaleFactor(0.2)
                                            .foregroundColor(Color(UIColor.systemGray))
                                    }
                                }
                                .padding(.horizontal)
                                
                                Spacer()
                                
                                if bob.listType == 1 {
                                    Check(bob: bob, bit: bit, update: $update, scaleFactor: 1.5)
                                        .padding(10)
                                }
                                else if bob.listType == 2 {
                                    Circle()
                                        .frame(width: 48, height: 48)
                                        .opacity(0)
                                        .padding(10)
                                }
                            }
                            .padding(.bottom, 20)
                        }
                        .frame(width: max(geometry.size.width-20, 1), height: bit.image != nil ? UIScreen.main.bounds.height*0.5 : UIScreen.main.bounds.height*0.15)
                        .padding(10)
                    }
                    .id(update)
                    
                    VStack(alignment: .leading) {
                        
                        if let tags = bit.tags, !tags.isEmpty {
                            WrappingHStack(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(.headline, design: .rounded).weight(.semibold))
                                    .padding(10)
                                    .padding(.horizontal, 5)
                                    .frame(minWidth: 40, minHeight: 40)
                                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(uiColor: .systemGray6)))
                                    .padding(.vertical, 5)
                            }
                            .padding(.horizontal, 15)
                            .padding(.bottom, 5)
                        }
                        
                        if bit.attributes != nil {
                                ForEach(0..<bob.attributeList.count, id: \.self) { a in
                                    if bit.attributes![bob.attributeList[a].name ?? ""] != nil &&
                                        bit.attributes![bob.attributeList[a].name ?? ""] != "" {
                                        AStack {
                                            Text(bob.attributeList[a].displayName ?? "")
                                                .font(.system(.headline, design: .rounded).weight(.semibold))
                                                .foregroundColor(Color(UIColor.systemGray))
                                            Spacer()
                                            Text(editAttributeValue(bit.attributes![bob.attributeList[a].name ?? ""] ?? "", attribute: bob.attributeList[a]))
                                                .font(.system(.headline, design: .rounded).weight(.medium))
                                                .multilineTextAlignment(.trailing)
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.top, 5)
                                    }
                                }
                            }
                        
                        Text(bit.paragraph ?? "")
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(4)
                            .padding(20)
                    }

                    Spacer()
                        .frame(height: UIScreen.main.bounds.height*0.1)

                }
                .sheet(isPresented: self.$editBit) {
                    BitEditor(bit: bit, bob: bob, bits: bob.bitArray, dismissNavigation: dismiss)
                }
            }
        }
        .navigationBarTitle("\(self.bit.name ?? "")")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("")
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Text("Edit")
                    .foregroundColor(PersistenceController.themeColor)
                    .onTapGesture {
                        self.editBit.toggle()
                    }
            }
        }
        .onChange(of: self.editBit) { value in
            if !value {
                let newBits = self.bob.bitArray
                let bit = newBits[Int(bit.order)]
                self.bit = bit
                update.toggle()
            }
        }
    }
    
    private func editAttributeValue(_ value: String, attribute: Attribute) -> String {
        
        // Return a series if there are multiple values
        if value.contains(Constants.delimiter) {
            let values = value.split(separator: Constants.delimiter).filter({ !$0.isEmpty }).map({ editAttributeValue(String($0), attribute: attribute) })
            return values.count == 1 ? values.first! : values.joined(separator: ", ")
        }
        
        if attribute.type == 0 {
            return value
        }
        else if attribute.type == 1 {
            if attribute.prefix != nil && attribute.suffix != nil && attribute.prefix != "" && attribute.suffix != "" {
                return attribute.prefix! + " " + value + " " + attribute.suffix!
            }
            else if attribute.prefix != nil && attribute.prefix != "" {
                return attribute.prefix! + " " + value
            }
            else if attribute.suffix != nil && attribute.suffix != "" {
                return value + " " + attribute.suffix!
            }
            return value
        }
        else if attribute.type == 2 {
            if attribute.boolType == 0 {
                return value
            }
            else if attribute.boolType == 1 {
                return value == "True" ? "Yes" : "No"
            }
        }
        else if attribute.type == 3 {
            if let date = ISO8601DateFormatter().date(from: value) {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                return formatter.string(from: date)
            }
        }
        return ""
    }
}
