//
//  VGrid.swift
//  Bits & Bobs
//
//  Created by Joe Rupertus on 12/26/24.
//

import SwiftUI

// MARK: - The user-facing `VGrid` container

struct VGrid<Content: View>: View {
    private let columns: [GridItem]
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat?
    private let pinnedViews: PinnedScrollableViews
    private let content: () -> Content

    init(
        columns: [GridItem],
        alignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        pinnedViews: PinnedScrollableViews = .init(),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.columns = columns
        self.alignment = alignment
        self.spacing = spacing
        self.pinnedViews = pinnedViews
        self.content = content
    }

    var body: some View {
        NonLazyVGridLayout(
            columns: columns,
            alignment: alignment,
            spacing: spacing ?? 8
        ) {
            content()
        }
    }
}

// MARK: - The 'NonLazyVGridLayout' bridging view

@available(iOS 16.0, *)
struct NonLazyVGridLayout<Content: View>: View {
    let columns: [GridItem]
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let content: Content

    init(
        columns: [GridItem],
        alignment: HorizontalAlignment,
        spacing: CGFloat,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.columns = columns
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        AnyLayout(
            VGridLayout(
                columns: columns,
                alignment: alignment,
                spacing: spacing
            )
        ) {
            content
        }
    }
}

// MARK: - The custom Layout itself

@available(iOS 16.0, *)
fileprivate struct VGridLayout: Layout {
    let columns: [GridItem]
    let alignment: HorizontalAlignment
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        guard !columns.isEmpty else {
            return .zero
        }

        let containerWidth = proposal.width ?? 300
        let columnCount = columns.count
        let totalSpacingX = spacing * CGFloat(columnCount - 1)
        let columnWidth = max(0, (containerWidth - totalSpacingX) / CGFloat(columnCount))

        var totalHeight: CGFloat = 0
        var rowHeight: CGFloat = 0
        var itemsInRow = 0

        for subview in subviews {
            let proposedSize = ProposedViewSize(width: columnWidth, height: nil)
            let size = subview.sizeThatFits(proposedSize)

            rowHeight = max(rowHeight, size.height)
            itemsInRow += 1

            if itemsInRow == columnCount {
                totalHeight += rowHeight + spacing
                rowHeight = 0
                itemsInRow = 0
            }
        }

        if itemsInRow != 0 {
            totalHeight += rowHeight
        } else {
            totalHeight = max(0, totalHeight - spacing)
        }

        return CGSize(width: containerWidth, height: totalHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        guard !columns.isEmpty else { return }

        let columnCount = columns.count
        let totalSpacingX = spacing * CGFloat(columnCount - 1)
        let columnWidth = max(0, (bounds.width - totalSpacingX) / CGFloat(columnCount))

        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        var itemsInRow = 0

        for subview in subviews {
            let proposedSize = ProposedViewSize(width: columnWidth, height: nil)
            let size = subview.sizeThatFits(proposedSize)

            subview.place(
                at: CGPoint(x: x, y: y),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: columnWidth, height: size.height)
            )

            rowHeight = max(rowHeight, size.height)
            itemsInRow += 1
            x += columnWidth + spacing

            if itemsInRow == columnCount {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
                itemsInRow = 0
            }
        }
    }
}
