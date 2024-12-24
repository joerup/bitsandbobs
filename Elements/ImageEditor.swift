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

struct ImageEditor<Content: View, SelectorShape: Shape>: View {
    
    @Binding var image: UIImage
    @Binding var offset: CGSize
    @Binding var scale: CGFloat
    
    var selectorShape: SelectorShape
    var aspectRatio: CGFloat = 1.0
    
    @State private var photoItem: PhotosPickerItem?
    @State private var imageItem: ImageItem?
    
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
                self.displayCamera.toggle()
            } label: {
                Text("Camera").textCase(nil)
            }
            Button {
                self.displayLibrary.toggle()
            } label: {
                Text("Photo Library").textCase(nil)
            }
            Button {
                self.imageItem = ImageItem(image: image)
            } label: {
                Text("Reposition").textCase(nil)
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
            ImagePicker(sourceType: .camera) { image in
                imageItem = ImageItem(image: image)
            }
        }
        .photosPicker(isPresented: $displayLibrary, selection: self.$photoItem)
        .onChange(of: photoItem) { _ in
            Task {
                if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        imageItem = ImageItem(image: image)
                    }
                }
            }
        }
        .sheet(item: $imageItem) { imageItem in
            ImageTransformer(
                image: imageItem.image,
                initialOffset: offset,
                initialScale: scale,
                selectorShape: selectorShape,
                aspectRatio: aspectRatio,
                onConfirm: { offset, scale in
                    self.image = imageItem.image
                    self.offset = offset
                    self.scale = scale
                    self.imageItem = nil
                }, onCancel: {
                    self.imageItem = nil
                }
            )
        }
    }
}
 
struct ImageItem: Identifiable {
    let id = UUID()
    let image: UIImage
}
