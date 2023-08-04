//
//  BobList.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 2/21/21.
//

import SwiftUI

struct BobList: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(
        entity: Bob.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Bob.order, ascending: true)
        ]
    ) var bobs: FetchedResults<Bob>
    
    @State private var newBob = false
    @State private var editBobs = false
    
    @State private var showSettings = false
    
    @State private var search = ""

    var body: some View {

        GeometryReader { geometry in

            NavigationView {
                
                VStack(spacing: 0) {
                    
                    ScrollView {
                        
                        VStack {
                            
                            if self.bobs.isEmpty {
                                Button {
                                    self.newBob.toggle()
                                } label: {
                                    Text("Create your first collection!")
                                        .padding()
                                }
                                .onAppear {
                                    self.newBob.toggle()
                                }
                            }
                            
                            ForEach(self.bobs, id: \.order) { bob in

                                NavigationLink(destination: BobView(bob: bob)) {

                                    ZStack {
                                        if bob.image == nil {
                                            Rectangle()
                                                .fill(Color.init(red: 0.9, green: 0.7, blue: 0.4, opacity: 0.2))
                                                .cornerRadius(20)
                                        }

                                        Image(uiImage: bob.image != nil ? UIImage(data: bob.image!) ?? UIImage(named: "") ?? UIImage() : UIImage(named: "") ?? UIImage())
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .blur(radius: 1)
                                            .frame(height: UIScreen.main.bounds.height*0.15)
                                            .cornerRadius(20)

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
                                }
                            }
                            .listRowSeparator(.hidden)
                            .environment(\.editMode, .constant(self.editBobs ? EditMode.active : EditMode.inactive))
                            .sheet(isPresented: self.$editBobs) {
                                BobListEditor()
                            }
                        }
                        .padding(10)
                    }
                }
                .navigationBarTitle("Collections")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            self.showSettings.toggle()
                        }) {
                            Image(systemName: "gearshape.fill")
                        }
                    }
                    if !bobs.isEmpty {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                self.editBobs.toggle()
                            } label: {
                                Text("Edit")
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            self.newBob.toggle()
                        }, label: {
                            Image(systemName: "plus")
                        })
                    }
                }
                .sheet(isPresented: self.$showSettings) {
                    SettingsView()
                }
                .sheet(isPresented: self.$newBob, content: {
                    BobEditor()
                })
                
                Text("Select a category.")
                    .padding()
            }
            .accentColor(PersistenceController.themeColor)
            .phoneOnlyStackNavigationView(geometry)
        }
    }
}


extension View {
    func phoneOnlyStackNavigationView(_ geometry: GeometryProxy) -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone || geometry.size.height >= geometry.size.width {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        } else {
            return AnyView(self)
        }
    }
}
