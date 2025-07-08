//
//  AspectVGrid.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 05/05/2025.
//

import SwiftUI

/// A view that allocates items in a grid according to size. 
struct AspectVGrid<Item: Identifiable, ItemView: View>: View {
    var items: [Item]
    var aspectRatio: CGFloat = 1
    var content: (Item) -> ItemView
    
    init(_ items: [Item], aspectRatio: CGFloat, @ViewBuilder content: @escaping (Item) -> ItemView) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            let gridItemSize = gridItemWidthThatFits(
                count: items.count,
                size: geometry.size,
                atAspectRatio: aspectRatio
            )
            VStack {
                Spacer()
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: gridItemSize), spacing: Constants.horizontalSpacing)],
                    spacing: Constants.verticalSpacing
                ) {
                    ForEach(items) { item in
                        content(item)
                            .aspectRatio(aspectRatio, contentMode: .fit)
                    }
                }
                Spacer()
            }
            
        }
    }
        private func gridItemWidthThatFits(
            count: Int,
            size: CGSize,
            atAspectRatio aspectRatio: CGFloat
        ) -> CGFloat {
            let count = CGFloat(count)
            var columnCount = Constants.columnCount
            repeat {
                let width = size.width / columnCount
                let height = width / aspectRatio
                
                let rowCount = (count / columnCount).rounded(.up)
                if rowCount * height < size.height {
                    return (size.width / columnCount).rounded(.down)
                }
                columnCount += 1
            } while columnCount < count
            return min(size.width / count, size.height * aspectRatio).rounded(.down)
        }
}

    private struct Constants {
        static let columnCount: CGFloat = 1.0
        static let horizontalSpacing: CGFloat = 0
        static let verticalSpacing: CGFloat = 0

    }

