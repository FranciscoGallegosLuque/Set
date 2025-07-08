//
//  CardView.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 06/05/2025.
//

import SwiftUI

/// Returns a View of a Set card.
struct CardView: View {
    private(set) var viewModel: SetGameViewModel
    
    let card: Card

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let currentAspectRatio = (width / height)
            let padding = min(width, height) * Constants.padding
            cardContents(aspectRatio: currentAspectRatio, padding: padding)
                .cardify(selectionColor: viewModel.cardBackgroundColor(for: card))
                .foregroundStyle(viewModel.color(for: card))
        }
    }
    
    func cardContents(aspectRatio: CGFloat, padding: CGFloat) -> some View {
        VStack {
            ForEach(0..<card.numberOfItems, id: \.self) { _ in
                viewModel.shape(for: card)
                    .aspectRatio(aspectRatio * Constants.shapesAspectRatio, contentMode: .fit)
            }
        }
            .minimumScaleFactor(Constants.FontSize.scaleFactor)
            .multilineTextAlignment(.center)
            .padding(padding)
        
    }
    
    private struct Constants {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 0.18
        static let shapesAspectRatio: CGFloat = 3
        struct FontSize {
            static let largest: CGFloat = 200
            static let smallest: CGFloat = 10
            static let scaleFactor = smallest / largest
        }
    }
}

#Preview {
    CardView(viewModel: SetGameViewModel(),
             card: Card(
                numberOfItems: 2, 
                cardFeatures: [
                    "color": "red",
                    "shape": "squiggle",
                    "shading": "striped"
                ]
        )
    )
}
