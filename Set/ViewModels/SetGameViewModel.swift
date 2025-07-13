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
    @Published var game: SetGame = SetGameViewModel.makeGame(GameConfig.classic)
    var grid: [Slot] = []
    
//    var grid: [Slot] {
//        get {
//            cards.compactMap {
//                switch $0.deckStatus {
//                case .table:
//                    Slot(card: $0)
//                case .removed:
//                    if wereMatchedCardsReplaced {
//                        nil
//                    } else {
//                        Slot(card: nil)
//                    }
//                case .deck:
//                    nil
//                }
//            }
//        }
//        set {
//
//        }
//    }
    
    init() {
        for tableCard in tableCards {
            self.grid.append(Slot(cardID: tableCard.id, wasEmpty: false))
        }
    }
    
    //MARK: -Computed Properties
    var cards: [Card] { game.cards }
    var deckCards: [Card] { game.deckCards }
    var removedCards: [Card] { game.removedCards }
    var tableCards: [Card] { game.tableCards }
    var matchedCards: [Card] { game.matchedCards }
    var gameEnded: Bool { game.gameEnded }
    var score: Int { game.score }
    var availableSet: Bool { game.hasAvailableSet }
     
    //MARK: -Factory
    
    /// Creates a new SetGame instance with a given theme and initial number of cards on table.
    /// - Parameters:
    ///   - theme: The theme that defines the features and set size for the game.
    ///   - tableAmount: The number of cards to be initially placed on the table.
    /// - Returns: A fully initialized `SetGame` instance
    private static func makeGame(_ gameSettings: GameSettings) -> SetGame {
        SetGame(gameSettings)
    }
    
    //MARK: -Public Methods
    
    /// Defines the UI Color for a given card content and borders.
    /// - Parameter card: The card to be interpreted.
    /// - Returns: The UI Color associated with the "color" feature of the card.
    func color(for card: Card) -> Color {
        let cardColor = card.cardFeatures["color"]
        switch cardColor {
        case "purple": return .purple
        case "red": return .red
        case "green": return .green
        default: return .black
        }
    }

    
    /// Defines the UI Color used to show selection status for card.
    /// - Parameter card: The card to be interpreted.
    /// - Returns: The UI Color associated with the selection status of the card.
    func selectionColor(for card: Card) -> Color {
        switch card.selectionStatus {
        case .matched: return .green.opacity(Constants.selectionColorOpacity)
        case .misMatched: return .red.opacity(Constants.selectionColorOpacity)
        case .selected: return .teal.opacity(Constants.selectionColorOpacity)
        case .notSelected: return Color(UIColor.systemGroupedBackground)
        }
    }
    
    /// Defines the symbol View used as shape in the card.
    /// - Parameter card: The card to be interpreted.
    /// - Returns: A View of the corresponding shape (diamond, squiggle or pill) with shading and color.
    @ViewBuilder
    func symbolView(for card: Card) -> some View {
        if let cardShape = card.cardFeatures["shape"], let cardShading = card.cardFeatures["shading"] {
            switch cardShape {
            case "diamond": applyShading(to: Diamond(), shading: cardShading)
            case "squiggle": applyShading(to: Squiggle(), shading: cardShading)
            case "capsule": applyShading(to: Capsule(), shading: cardShading)
            default: Text("Error")
            }
        }
    }
    
    
    //MARK: -Private Methods
    /// Returns a given shaded version of a given shape.
    /// - Parameters:
    ///   - shape: The shape View to be shaded (diamond, squiggle or pill).
    ///   - shading: The shading to be applied to the shape.
    /// - Returns: A View of a shaded version of the given shape.
    @ViewBuilder
    private func applyShading(to shape: some Shape, shading: String) -> some View {
        switch shading {
        case "solid": shape
        case "striped": makeStriped(shape)
        case "empty": shape.stroke(lineWidth: Constants.shapeLineWidth)
        default: shape
        }
    }
    
    /// Returns a striped version of a given shape.
    /// - Parameter shape: The shape View to be shaded (diamond, squiggle or pill).
    /// - Returns: A View of a striped version of the given shape.
    private func makeStriped(_ shape: some Shape) -> some View {
        ZStack {
            let stripes = stripeSettings()
            StripedOverlay(
                numberOfLines: stripes.count,
                stripeWidth: stripes.width)
                    .clipShape(shape)
            shape
                .stroke(lineWidth: Constants.shapeLineWidth)
        }
    }
    
    /// Returns the amount and width of stripes of a striped shape
    /// based on the actual amount of cards on the table.
    private func stripeSettings() -> (count: Int, width: CGFloat){
        if tableCards.count < Stripe.cardsThreshold {
            return Stripe.bold
        } else {
            let scale = UIScreen.main.scale
            return (Stripe.bold.count,
                    max(Stripe.bold.width, 1 / scale)
            )
        }
    }
    
    private func updateGrid() {
        
        for index in grid.indices {
            if let cardID = grid[index].cardID {
                if let card = cards.first(where: { $0.id == cardID }) {
                    if card.deckStatus == .removed {
                        let newSlot: Slot = Slot(cardID: nil, wasEmpty: true)
                        grid[index] = newSlot
                    }
                }
            }
        }
    }
    

    
    //MARK: -Intents
    
    /// Indicates the Model the user's intent of selecting a card.
    func select(_ card: Card) {
//        if !matchedCards.isEmpty  { wereMatchedCardsReplaced = false }
        game.handleCardSelection(card: card)
        
        updateGrid()
        print(grid)
    }
    
    /// Indicates the Model the user's intent of dealing new cards.
    func dealCards() {
        print(grid)
        game.addCards()
        var newTableCards: [Card] = []
        newTableCards = tableCards.filter { tableCard in
            !grid.contains(where: { $0.cardID == tableCard.id })
        }
        print("new table cards: \(newTableCards)")
        
//        let addedCardsSlice = tableCards.suffix(game.setSize)
//        var addedCards = Array(addedCardsSlice)
//        print(grid)
//        print(grid.count)
        for index in grid.indices {
            if grid[index].cardID == nil {
                let newSlot: Slot = Slot(cardID: newTableCards.removeFirst().id, wasEmpty: true)
                grid[index] = newSlot
            }
        }
        
    }
    
    /// Indicates the Model the user's intent of starting a new game.
    func startNewGame() {
        self.game = Self.makeGame(GameConfig.classic)
        grid = []
        for tableCard in tableCards {
            self.grid.append(Slot(cardID: tableCard.id, wasEmpty: false))
        }
    }
    
    struct Slot: Identifiable, CustomDebugStringConvertible {
        
        let id: UUID = UUID()
        let cardID: Card.ID?
        let wasEmpty: Bool
        
        var debugDescription: String {
            if cardID != nil {
                "card: \(String(describing: cardID))"
            } else {
                "card: empty"
            }
            
        }
        
    }
    
//    var grid: [SetGameViewModel.Slot] = []
//    
//    for tableCard in viewModel.tableCards {
//        var slot = SetGameViewModel.Slot(isShowingCard: true)
//        grid.append(slot)
//    }
    
}

//MARK: -Constants
private struct Constants {
    static let initialNumberOfCards: Int = 12 // The initial number of cards displayed in the table.
    static let numberOfCardsAdded: Int = 3
    static let selectionColorOpacity: CGFloat = 0.2
    static let shapeLineWidth: CGFloat = 1
}

private struct Stripe {
    
    static let cardsThreshold: Int = 25 // When this table cards' threshold is reached, stripes setting adapt to fit better on screen.
    static let bold: (count: Int, width: CGFloat) = (count: 20, width: 0.5) // Stripes setting for few table cards on screen.
    static let fine: (count: Int, width: CGFloat) = (count: 30, width: 0.2) // Stripes setting for many table cards on screen.
}


