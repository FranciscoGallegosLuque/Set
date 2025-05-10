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
    var cards: [SetGame.Card] {
        game.cards
    }
    
    var deckCards: [SetGame.Card] {
        game.deckCards
    }
    
    var tableCards: [SetGame.Card] {
        game.tableCards
    }
    
    //MARK: -Intents
    private static func createGame() -> SetGame {
        SetGame(
            numbers: [1,2,3],
            features1: ["red","blue","green"],
            features2: ["diamond","rectangle","capsule"],
            features3: ["solid","striped","empty"],
            display: 12
        )
    }
    
    //MARK: -Public Methods
    func color(for card: SetGame.Card) -> Color {
        switch card.feature1 {
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        default: return .black
        }
    }

    func cardBackgroundColor(for card: SetGame.Card) -> Color {
        if card.isMatched {
            return .green.opacity(0.4)
        } else if card.isMisMatched {
            return .red.opacity(0.3)
        } else if card.isSelected {
            return .teal.opacity(0.4)
        } else {
            return .white
        }
    }

    
    @ViewBuilder
    func shape(for card: SetGame.Card) -> some View {
        switch card.feature2 {
        case "diamond": applyShading(to: Diamond(), shading: card.feature3).aspectRatio(2, contentMode: .fit)
        case "rectangle": applyShading(to: Rectangle(), shading: card.feature3).aspectRatio(2, contentMode: .fit)
        case "capsule": applyShading(to: Capsule(), shading: card.feature3).aspectRatio(2, contentMode: .fit)
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
    
    func select(_ card: SetGame.Card) {
        game.handleCardSelection(card: card)
    }
    
    func addThree() {
        game.addCards()
    }
    
    func startNewGame() {
        self.game = SetGameViewModel.createGame() 
    }
    
}


