//
//  ImageTransformer.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 12/24/24.
//

import SwiftUI

typealias ImageCompletion = (_ offset: CGSize, _ scale: CGFloat) -> Void

struct ImageTransformer<SelectorShape: Shape>: View {
    
    var image: UIImage
    
    var initialOffset: CGSize
    var initialScale: CGFloat
    
    var selectorShape: SelectorShape
    var aspectRatio: CGFloat
    
    var onConfirm: ImageCompletion
    var onCancel: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var lastDragOffset: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    let padding: CGFloat = 50
    
    init(image: UIImage, initialOffset: CGSize = .zero, initialScale: CGFloat = 1.0, selectorShape: SelectorShape = Rectangle(), aspectRatio: CGFloat = 1.0, onConfirm: @escaping ImageCompletion, onCancel: @escaping () -> Void) {
        self.image = image
        self.initialOffset = initialOffset
        self.initialScale = initialScale
        self.selectorShape = selectorShape
        self.aspectRatio = aspectRatio
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                Image(uiImage: image)
                    .offset(dragOffset)
                    .scaleEffect(geometry.size.minimum / image.size.minimum)
                    .scaleEffect(currentScale)
                    .frame(width: geometry.size.width, height: geometry.size.height * aspectRatio)
                    .overlay {
                        let origin = CGPoint(
                            x: max((geometry.size.width - geometry.size.height * aspectRatio) / 2, 0),
                            y: max((geometry.size.height * aspectRatio - geometry.size.width) / 2, 0) + (aspectRatio * geometry.size.minimum - geometry.size.minimum / aspectRatio) / 2
                        )
                        if #available(iOS 17.0, *) {
                            Rectangle()
                                .subtracting(
                                    selectorShape
                                        .path(in: .init(x: origin.x + padding, y: origin.y + padding, width: geometry.size.minimum, height: geometry.size.minimum / aspectRatio))
                                )
                                .fill(Color(UIColor.systemBackground).opacity(0.5))
                                .padding(-padding)
                        }
                        selectorShape
                            .stroke(Color.gray, lineWidth: 5)
                            .frame(width: geometry.size.minimum, height: geometry.size.minimum / aspectRatio)
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = lastDragOffset + value.translation * image.size.minimum / geometry.size.minimum / currentScale
                                clamp()
                            }
                            .onEnded { _ in
                                lastDragOffset = dragOffset
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { scale in
                                currentScale = lastScale * scale
                                clamp()
                            }
                            .onEnded { _ in
                                lastScale = currentScale
                            }
                    )
            }
            .padding(padding)
            .onAppear {
                self.dragOffset = initialOffset * image.size.minimum
                self.currentScale = initialScale == 0 ? 1.0 : initialScale
                self.lastDragOffset = dragOffset
                self.lastScale = currentScale
            }
            .clipped()
            .navigationBarTitle("Adjust", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    onCancel()
                },
                trailing: Button {
                    onConfirm(dragOffset / image.size.minimum, currentScale)
                } label: {
                    Text("Apply")
                        .fontWeight(.bold)
                }
            )
            .textCase(nil)
        }
    }
    
    private func clamp() {
        let size = image.size / 2
        
        // Define minimum and maximum scale factors
        let minScale: CGFloat = 1.0
        let maxScale: CGFloat = 2.0
        
        // Clamp the currentScale within the defined range
        if currentScale < minScale {
            currentScale = minScale
            lastScale = minScale
        } else if currentScale > maxScale {
            currentScale = maxScale
            lastScale = maxScale
        }
        
        // Determine the maximum allowable offset in each direction
        let maxOffsetX = size.width - size.minimum / currentScale
        let maxOffsetY = size.height - size.minimum / aspectRatio / currentScale
        
        // Clamp the dragOffset to ensure the image stays within bounds
        dragOffset.width = min(max(dragOffset.width, -maxOffsetX), maxOffsetX)
        dragOffset.height = min(max(dragOffset.height, -maxOffsetY), maxOffsetY)
    }
}
