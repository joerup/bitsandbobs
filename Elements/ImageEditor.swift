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
    @State private var displayCamera = false
    @State private var displayLibrary = false
    
    var content: () -> Content
    
    var body: some View {
        Menu {
            Button {
                self.displayCamera = true
            } label: {
                HStack {
                    Image(systemName: "camera")
                    Text("Camera").textCase(nil)
                }
            }
            Button {
                self.displayLibrary = true
            } label: {
                HStack {
                    Image(systemName: "photo")
                    Text("Photo Library").textCase(nil)
                }
            }
            Button {
                self.image = UIImage()
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Remove Image").textCase(nil)
                }
            }
        } label: {
            content()
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
