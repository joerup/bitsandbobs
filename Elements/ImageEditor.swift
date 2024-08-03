//
//  ImageEditor.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 6/12/21.
//

import Foundation
import SwiftUI
import UIKit
import PhotosUI

struct ImageEditor<Content: View>: View {
    
    @Binding var image: UIImage
    
    @State private var photoItem: PhotosPickerItem?
    
    @State private var displayMenu = false
    
    @State private var displayCamera = false
    @State private var displayLibrary = false
    
    var content: () -> Content
    
    var body: some View {
        Button {
            displayMenu.toggle()
        } label: {
            content()
        }
        .confirmationDialog("Choose a new photo", isPresented: $displayMenu) {
            Button {
                self.displayCamera = true
            } label: {
                Text("Camera").textCase(nil)
            }
            Button {
                self.displayLibrary = true
            } label: {
                Text("Photo Library").textCase(nil)
            }
            Button {
                self.image = UIImage()
            } label: {
                Text("Remove Image").textCase(nil)
            }
        } message: {
            Text("Choose a new photo").textCase(nil)
        }
        .sheet(isPresented: $displayCamera) {
            ImagePicker(sourceType: .camera, selectedImage: self.$image)
        }
        .photosPicker(isPresented: $displayLibrary, selection: self.$photoItem)
        .onChange(of: photoItem) { _ in
            Task {
                if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        self.image = uiImage
                        return
                    }
                }
                print("Failed")
            }
        }
    }
}
