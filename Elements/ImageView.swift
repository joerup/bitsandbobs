//
//  ImageView.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 6/12/21.
//

import Foundation
import SwiftUI
import UIKit

struct ImageView: View {
    
    @Binding var image: UIImage
    @State var originalImage = UIImage()
    
    @State private var displayPhotoLibrary = false
    @State private var displayCamera = false
    
    let defaultImages = ["cabinet","drawer","canyon","fire","mountain","plant","trees","snow","water","crystal","light"]
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        
        VStack {
            
            if image == originalImage {
                
                Text("Select an Image")
                    .font(.largeTitle)
                
                // DEFAULT LIBRARY
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(self.defaultImages, id: \.self) { image in
                            Button(action: {
                                self.image = UIImage(named: image) ?? UIImage()
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                }
                .padding(.horizontal, 10)
     
                // DEVICE PHOTO LIBRARY
                Button(action: {
                    self.displayPhotoLibrary = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 20))
     
                        Text("Photo Library")
                            .font(.headline)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(PersistenceController.themeColor)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                .sheet(isPresented: $displayPhotoLibrary) {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                }
                .padding(.top)
                
                // CAMERA
                Button(action: {
                    self.displayCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera")
                            .font(.system(size: 20))
     
                        Text("Camera")
                            .font(.headline)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(PersistenceController.themeColor)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                .sheet(isPresented: $displayCamera) {
                    ImagePicker(sourceType: .camera, selectedImage: self.$image)
                }
                .padding(.top)
                
                // REMOVE IMAGE
                Button(action: {
                    self.image = UIImage()
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
     
                        Text("No Image")
                            .font(.headline)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(PersistenceController.themeColor)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
                .sheet(isPresented: $displayCamera) {
                    ImagePicker(sourceType: .camera, selectedImage: self.$image)
                }
                .padding(.top)
            }
            else {
                
                VStack {
                    
                    Image(uiImage: self.image)
                        .resizable()
                        .scaledToFit()
                        .edgesIgnoringSafeArea(.all)
                    
                    HStack {
                        
                        // CANCEL
                        Button(action: {
                            self.image = self.originalImage
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Text("Cancel")
                                    .font(.headline)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                            .background(PersistenceController.themeColor)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        
                        // CHOOSE
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Text("Use Photo")
                                    .font(.headline)
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                            .background(PersistenceController.themeColor)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
        }
        .onAppear {
            self.originalImage = self.image
        }
    }
}
