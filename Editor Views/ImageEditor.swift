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
    
    private var allowRepositioning: Bool
    private var selectorShape: SelectorShape
    private var aspectRatio: CGFloat
    
    @State private var photoItem: PhotosPickerItem?
    @State private var imageItem: ImageItem?
    
    @State private var displayMenu = false
    
    @State private var displayCamera = false
    @State private var displayLibrary = false
    
    var content: () -> Content
    
    init(image: Binding<UIImage>, offset: Binding<CGSize>, scale: Binding<CGFloat>, allowRepositioning: Bool = false, selectorShape: SelectorShape = Rectangle(), aspectRatio: CGFloat = 1.0, content: @escaping () -> Content) {
        self._image = image
        self._offset = offset
        self._scale = scale
        self.allowRepositioning = allowRepositioning
        self.selectorShape = selectorShape
        self.aspectRatio = aspectRatio
        self.content = content
    }
    
    var body: some View {
        Group {
            if allowRepositioning && !image.isEmpty {
                Menu {
                    Button {
                        self.displayMenu.toggle()
                    } label: {
                        Label("New Photo", systemImage: "photo")
                    }
                    Button {
                        self.imageItem = ImageItem(image: image, offset: offset, scale: scale)
                    } label: {
                        Label("Reposition", systemImage: "crop")
                    }
                } label: {
                    content()
                }
            } else {
                Button {
                    self.displayMenu.toggle()
                } label: {
                    content()
                }
            }
        }
        .confirmationDialog("Choose a new photo", isPresented: $displayMenu) {
            Button {
                self.displayCamera.toggle()
            } label: {
                Text("Camera")
            }
            Button {
                self.displayLibrary.toggle()
            } label: {
                Text("Photo Library")
            }
            Button {
                self.image = UIImage()
            } label: {
                Text("No Photo")
            }
        } message: {
            Text("Choose a new photo")
        }
        .sheet(isPresented: $displayCamera) {
            ImagePicker(sourceType: .camera) { image in
                selectImage(image)
            }
        }
        .photosPicker(isPresented: $displayLibrary, selection: self.$photoItem)
        .onChange(of: photoItem) { _ in
            Task {
                if let data = try? await photoItem?.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        selectImage(image)
                    }
                }
            }
        }
        .sheet(item: $imageItem) { imageItem in
            ImageTransformer(
                image: imageItem.image,
                initialOffset: imageItem.offset,
                initialScale: imageItem.scale,
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
        .textCase(nil)
    }
    
    private func selectImage(_ image: UIImage) {
        if allowRepositioning {
            self.imageItem = ImageItem(image: image, offset: .zero, scale: 1.0)
        } else {
            self.image = image
        }
    }
}
 
struct ImageItem: Identifiable {
    let id = UUID()
    let image: UIImage
    let offset: CGSize
    let scale: CGFloat
}
