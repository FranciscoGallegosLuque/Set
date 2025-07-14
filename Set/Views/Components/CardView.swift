//
//  CardView.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 14/07/2025.
//

import SwiftUI

struct CardView: View {
    private(set) var viewModel: SetGameViewModel
    let card: Card
    
    var body: some View {
        if card.isFaceUp {
            CardFrontView(viewModel: viewModel, card: card)
        } else {
            CardBackView()
        }
    }
}

#Preview {
    CardView(viewModel: SetGameViewModel(),
             card: Card(
                numberOfFigures: 2,
                cardFeatures: [
                    "color": "red",
                    "shape": "squiggle",
                    "shading": "striped"
                ]
        )
    )
}
