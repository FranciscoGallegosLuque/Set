//
//  CardView.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 06/05/2025.
//

import SwiftUI

/// Returns a View of the front of a Set card.
struct CardFrontView: View {
    private(set) var viewModel: SetGameViewModel
    let card: Card

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let currentAspectRatio = (width / height)
            let padding = min(width, height) * Constants.padding
            cardContents(aspectRatio: currentAspectRatio, padding)
                .cardify(selectionColor: viewModel.selectionColor(for: card), isFaceUp: card.isFaceUp)
                .foregroundStyle(viewModel.color(for: card))
              

        }
    }
    
    /// Return a View with the contents shown by the card View.
    /// - Parameters:
    ///   - aspectRatio: Each symbols' card aspect ratio.
    ///   - padding: Each symbol's padding.
    /// - Returns: A View of the symbol or symbols to be displayed as Card contents.
    private func cardContents(aspectRatio: CGFloat, _ padding: CGFloat) -> some View {
        VStack {
            ForEach(0..<card.numberOfFigures, id: \.self) { _ in
                viewModel.symbolView(for: card)
                    .aspectRatio(aspectRatio * Constants.shapesAspectRatio, contentMode: .fit)
            }
        }
            .minimumScaleFactor(Constants.FontSize.scaleFactor)
            .multilineTextAlignment(.center)
            .padding(padding)
        
    }
    
    
    private struct Constants {
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
    CardFrontView(viewModel: SetGameViewModel(),
             card: Card(
                numberOfFigures: 2,
                cardFeatures: [
                    "color": "red",
                    "shape": "squiggle",
                    "shading": "striped"
                ],
                deckStatus: .table,
        )
    )
}
