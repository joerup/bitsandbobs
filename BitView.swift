//
//  BitView.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import SwiftUI
import Foundation
import CoreData

struct BitView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var bit: Bit
    var bob: Bob

    @State private var editBit = false
    
    @State private var update = false
    
    var body: some View {

        GeometryReader { geometry in
            
            ZStack {

                ScrollView {
                    
                    ZStack {
                        
                        if bit.image != nil {
                            if !bob.displayBitIcon {
                                Image(uiImage: UIImage(data: bit.image!)!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: max(geometry.size.width-20, 1), height: UIScreen.main.bounds.height*0.5)
                                    .cornerRadius(10)
                                    .padding(10)
                            }
                            else if bob.image != nil {
                                Image(uiImage: UIImage(data: bob.image!)!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .blur(radius: 7)
                                    .frame(width: max(geometry.size.width-20, 1), height: UIScreen.main.bounds.height*0.5)
                                    .cornerRadius(10)
                                    .padding(10)
                            }
                        }
                        
                        VStack {
                            
                            if bob.displayBitIcon && bit.image != nil {
                                
                                Spacer()
                                
                                Icon(image: UIImage(data: bit.image!)!, size: UIScreen.main.bounds.height*0.35)
                                    .shadow(color: .black, radius: 10)
                            }
                            
                            Spacer()
                            
                            HStack {
                                
                                if bob.listType == 2 {
                                    Text(String(bit.order+1))
                                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                                        .tracking(-0.5)
                                        .foregroundColor(Color(bit.image == nil ? UIColor.gray : UIColor.white))
                                        .shadow(color: .black, radius: bit.image != nil ? 10 : 0)
                                        .frame(width: 35, height: 35)
                                        .lineLimit(0)
                                        .minimumScaleFactor(0.5)
                                        .padding(10)
                                }
                                else if bob.listType == 1 {
                                    Circle()
                                        .frame(width: 35, height: 35)
                                        .opacity(0)
                                        .padding(10)
                                }
                                
                                Spacer()
                            
                                VStack {
                                    Text(bit.name ?? "")
                                        .font(.system(.largeTitle, design: .rounded).weight(.black))
                                        .tracking(-0.5)
                                        .lineLimit(0)
                                        .minimumScaleFactor(0.2)
                                        .foregroundColor(bit.image != nil ? Color(UIColor.white) : Color(UIColor.label))
                                        .shadow(color: .black, radius: bit.image != nil ? 10 : 0)

                                    if bit.desc != nil && bit.desc != "" {
                                        Text(bit.desc ?? "")
                                            .font(.system(.headline, design: .rounded).weight(.black))
                                            .tracking(-0.25)
                                            .lineLimit(0)
                                            .minimumScaleFactor(0.2)
                                            .foregroundColor(Color(bit.image != nil ? UIColor.white : UIColor.systemGray))
                                            .shadow(color: .black, radius: bit.image != nil ? 10 : 0)
                                    }
                                }
                                
                                Spacer()
                                
                                if bob.listType == 1 {
                                    Check(bob: bob, bit: bit, update: $update)
                                        .shadow(color: .black, radius: 10)
                                        .padding(10)
                                }
                                else if bob.listType == 2 {
                                    Circle()
                                        .frame(width: 35, height: 35)
                                        .opacity(0)
                                        .padding(10)
                                }
                            }
                            .padding(.bottom, 20)
                        }
                        .frame(width: max(geometry.size.width-20, 1), height: bit.image != nil ? UIScreen.main.bounds.height*0.5 : UIScreen.main.bounds.height*0.2)
                        .padding(10)
                    }
                    .id(update)
                    
                    if bit.attributes != nil {
                        ForEach(0..<bob.attributeList.count, id: \.self) { a in
                            if bit.attributes![bob.attributeList[a].name ?? ""] != nil &&
                                bit.attributes![bob.attributeList[a].name ?? ""] != "" &&
                                !(bob.attributeList[a].type == 2 && bob.attributeList[a].boolDisplayFalse && bit.attributes![bob.attributeList[a].name ?? ""] == "False") {
                                AStack {
                                    Text(bob.attributeList[a].displayName ?? "")
                                        .font(.headline)
                                        .fontWeight(.regular)
                                        .foregroundColor(Color(UIColor.systemGray))
                                    Spacer()
                                    Text(editAttributeValue(bit.attributes![bob.attributeList[a].name ?? ""] ?? "", attribute: bob.attributeList[a]))
                                        .font(.headline)
                                        .fontWeight(.regular)
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

                    Spacer()
                        .frame(height: UIScreen.main.bounds.height*0.1)

                }
                .sheet(isPresented: self.$editBit, content: {
                    BitEditor(bit: bit, bob: bob)
                })
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
            }
        }
    }
    
    func editAttributeValue(_ value: String, attribute: Attribute) -> String {
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
        return ""
    }
}
