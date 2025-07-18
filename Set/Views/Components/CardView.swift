//
//  CardView.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 14/07/2025.
//

import SwiftUI


/// A conditional View that return the front or the back of the Set card.
struct CardView: View {
    private(set) var cardViewModel: CardViewModel
    let card: Card
    
    var wasMatched: Bool {
        card.selectionStatus == .matched
    }
    var wasMisMatched: Bool {
        card.selectionStatus == .misMatched
    }
    
    
    
//    init(card: Card) {
//        self.card = card
//        self.cardViewModel =
//    }
    
    var scale: Double {
        wasMisMatched ? 0.9 : 1
    }
    
    var rotation: Double {
        wasMatched ? 360 : 0
    }

    var body: some View {
        Group {
            if card.isFaceUp {
                CardFrontView(cardViewModel: cardViewModel, card: card)
            } else {
                CardBackView()
            }
        }
        .rotation3DEffect(.degrees(rotation), axis: (0,0,1))
        .scaleEffect(scale)
    }
    
}

#Preview {
    CardView(cardViewModel: CardViewModel(tableCards: 12),
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
