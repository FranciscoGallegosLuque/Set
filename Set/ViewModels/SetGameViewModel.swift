//
//  SetGameViewModel.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 05/05/2025.
//

import Foundation
import SwiftUI

class SetGameViewModel: ObservableObject {
    //MARK: -Constants
    private struct Constants {
        static let defaultTableAmount: Int = 6
        static let selectionColorOpacity: CGFloat = 0.2
        static let shapeLineWidth: CGFloat = 1
    }
    
    private struct Stripe {
        static let cardsThreshold: Int = 25
        static let bold: (count: Int, width: CGFloat) = (count: 20, width: 0.5)
        static let fine: (count: Int, width: CGFloat) = (count: 30, width: 0.2)
    }
    
    //MARK: -Properties
    @Published var game: SetGame = createGame()
    
    private static let mainTheme: Theme = Theme(
        features: [
            Theme.Feature(name: "color", possibleValues: ["red","blue","green"]),
            Theme.Feature(name: "shape", possibleValues: ["diamond","squiggle","capsule"]),
            Theme.Feature(name: "shading", possibleValues: ["solid","striped","empty"]),
        ]
    )
    
    //MARK: -Computed Properties
    var cards: [Card] { game.cards }
    var deckCards: [Card] { game.deckCards }
    var tableCards: [Card] { game.tableCards }
    var matchedCards: [Card] { game.matchedCards }
    var gameEnded: Bool { game.gameEnded }
    var score: Int { game.score }
    var availableSet: Bool { game.availableSet }
     
    //MARK: -Factory
    private static func createGame() -> SetGame {
        SetGame(
            theme: mainTheme,
            tableAmount: Constants.defaultTableAmount,
        )
    }
    
    //MARK: -Public Methods
    func color(for card: Card) -> Color {
        let cardColor = card.cardFeatures["color"]
        switch cardColor {
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        default: return .black
        }
    }

    
    func cardBackgroundColor(for card: Card) -> Color {
        switch card.selectionStatus {
        case .matched: return .green.opacity(Constants.selectionColorOpacity)
        case .misMatched: return .red.opacity(Constants.selectionColorOpacity)
        case .selected: return .teal.opacity(Constants.selectionColorOpacity)
        case .notSelected: return Color(UIColor.systemGroupedBackground)
        }
    }

    @ViewBuilder
    func shape(for card: Card) -> some View {
        let cardColor = color(for: card)
        if let cardShape = card.cardFeatures["shape"], let cardShading = card.cardFeatures["shading"] {
            switch cardShape {
            case "diamond": applyShading(to: Diamond(), shading: cardShading, color: cardColor)
            case "squiggle": applyShading(to: Squiggle(), shading: cardShading, color: cardColor)
            case "capsule": applyShading(to: Capsule(), shading: cardShading, color: cardColor)
            default: Text("Error")
            }
        }
    }
    
    
    //MARK: -Private Methods
    @ViewBuilder
    private func applyShading(to shape: some Shape, shading: String, color: Color) -> some View {
        switch shading {
        case "solid": shape
        case "striped":
            ZStack {
                StripedOverlay(
                    numberOfLines: stripesCalculator().count,
                    stripeWidth: stripesCalculator().width)
                        .clipShape(shape)
                shape.stroke(color, lineWidth: Constants.shapeLineWidth)
            }
 
        case "empty": shape.stroke(lineWidth: Constants.shapeLineWidth)
        default: shape
        }
    }
    
    private func stripesCalculator() -> (count: Int, width: CGFloat){

        if tableCards.count < Stripe.cardsThreshold {
            return Stripe.bold
        } else {
            let scale = UIScreen.main.scale
            return (Stripe.bold.count,
                    max(Stripe.bold.width, 1 / scale)
            )
        }
        
    }
    
    //MARK: -Intents
    
    func select(_ card: Card) {
        game.handleCardSelection(card: card)
    }
    
    func dealCards() {
        if !matchedCards.isEmpty { game.replaceCards() }
        else { game.addCards() }
    }
    
    func startNewGame() {
        self.game = Self.createGame()
    }
    
}


