//
//  SetGameViewModel.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 05/05/2025.
//

import Foundation
import SwiftUI

class SetGameViewModel: ObservableObject {
    //MARK: -Properties
    @Published var game: SetGame = createGame()
    
    //MARK: -Computed Properties
    var cards: [Card] {
        game.cards
    }
    
    var deckCards: [Card] {
        game.deckCards
    }
    
    var tableCards: [Card] {
        game.tableCards
    }
    
    //MARK: -Intents
    private static func createGame() -> SetGame {
        SetGame(
            theme: Theme(
                features: [
                    Theme.Feature(possibleValues: ["red","blue","green"]),
                    Theme.Feature(possibleValues: ["diamond","rectangle","capsule"]),
                    Theme.Feature(possibleValues: ["solid","striped","empty"]),
                ]
            ),
            display: 12,
            numberOfItems: [1, 2, 3]
        )
    }
    
    //MARK: -Public Methods
    func color(for card: Card) -> Color {
        switch card.features[0] {
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        default: return .black
        }
    }

    func cardBackgroundColor(for card: Card) -> Color {
        if card.selectionStatus == .matched {
            return .green.opacity(0.4)
        } else if card.selectionStatus == .misMatched {
            return .red.opacity(0.3)
        } else if card.selectionStatus == .selected {
            return .teal.opacity(0.4)
        } else {
            return .white
        }
    }

    
    @ViewBuilder
    func shape(for card: Card) -> some View {
        switch card.features[1] {
        case "diamond": applyShading(to: Diamond(), shading: card.features[2]).aspectRatio(2, contentMode: .fit)
        case "rectangle": applyShading(to: Rectangle(), shading: card.features[2]).aspectRatio(2, contentMode: .fit)
        case "capsule": applyShading(to: Capsule(), shading: card.features[2]).aspectRatio(2, contentMode: .fit)
        default: Text("Error")
        }
    }
    
    //MARK: -Private Methods
    @ViewBuilder
    private func applyShading(to shape: some Shape, shading: String) -> some View {
        switch shading {
        case "solid": shape
        case "striped": shape.opacity(0.3)
        case "empty": shape.stroke()
        default: shape
        }
    }
    //MARK: -Intents
    
    func select(_ card: Card) {
        game.handleCardSelection(card: card)
    }
    
    func addThree() {
        game.addCards()
    }
    
    func startNewGame() {
        self.game = SetGameViewModel.createGame() 
    }
    
}


