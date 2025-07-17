//
//  SetGameViewModel.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 05/05/2025.
//

import Foundation
import SwiftUI


class SetGameViewModel: ObservableObject {
    
    //MARK: -Published Properties
    @Published var game: SetGame = SetGame(GameConfig.classic)
    @Published var grid: [Slot] = []
    var isSetComplete: Bool {
        selectedCards.count == game.setSize
    }
    
    // MARK: - State Tracking
    private(set) var removedCardIDsInOrder: [Card.ID] = []
    var newTableCards: [Card] = []
    
    //MARK: - Init
    init() {
        createNewGrid()
    }
    
    //MARK: - Computed Properties
    var cards: [Card] { game.cards }
    var deckCards: [Card] { game.deckCards }
    var tableCards: [Card] { game.tableCards }
    var selectedCards: [Card] { game.selectedCards }
    var matchedCards: [Card] { game.matchedCards }
    var misMatchedCards: [Card] { game.misMatchedCards }
    var removedCards: [Card] {
        removedCardIDsInOrder.compactMap { id in
            cards.first(where: { $0.id == id })
        }
    }
    private var undealtTableCards: [Card] {
        tableCards.filter { card in
            !grid.contains(where: { $0.cardID == card.id })
        }
    }
    
    var gameEnded: Bool { game.gameEnded }
    var availableSet: Bool { game.hasAvailableSet }
    
    //MARK: -Factory
    /// Creates a new SetGame instance with a given theme and initial number of cards on table.
    /// - Parameters:
    ///   - theme: The theme that defines the features and set size for the game.
    ///   - tableAmount: The number of cards to be initially placed on the table.
    /// - Returns: A fully initialized `SetGame` instance
//    private static func restartGame() {
//        game.restartGame()
//    }
    
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
        case .matched: return .green.opacity(Constants.Card.selectionColorOpacity)
        case .misMatched: return .red.opacity(Constants.Card.selectionColorOpacity)
        case .selected: return .teal.opacity(Constants.Card.selectionColorOpacity)
        case .notSelected: return Color(UIColor.systemBackground)
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
        case "empty": shape.stroke(lineWidth: Constants.Card.shapeLineWidth)
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
                .stroke(lineWidth: Constants.Card.shapeLineWidth)
        }
    }
    
    /// Returns the amount and width of stripes of a striped shape
    /// based on the actual amount of cards on the table.
    private func stripeSettings() -> (count: Int, width: CGFloat){
        if tableCards.count < Constants.Stripe.cardsThreshold {
            return Constants.Stripe.bold
        } else {
            let scale = UIScreen.main.scale
            return (Constants.Stripe.bold.count,
                    max(Constants.Stripe.bold.width, 1 / scale)
            )
        }
    }
    
    /// Creates a new grid with the table cards.
    private func createNewGrid() {
        if !grid.isEmpty { grid = [] }
        for tableCard in tableCards {
            self.grid.append(Slot(cardID: tableCard.id))
        }
    }
    
    /// Creates a new empty grid.
    private func createNewEmptyGrid() {
        grid = []
        for _ in tableCards {
            self.grid.append(Slot(cardID: nil))
        }
    }
    
    /// Removes cards from grid's slots in case they were matched and removed.
    private func removeCardsFromSlots() {
        for index in grid.indices {
            guard let cardID = grid[index].cardID,
                  let card = cards.first(where: { $0.id == cardID }),
                  card.deckStatus == .removed else { continue }
            grid[index] = Slot(cardID: nil)
        }
    }
    
    
    /// Adds cards to grid's empty slots.
    /// - Parameter newCards: The cards to be added to the grid.
    private func fillEmptySlots(with newCards: inout [Card]) {
        if grid.contains(where: {$0.cardID == nil}) {
            for index in grid.indices {
                if grid[index].cardID == nil {
                    if newCards.isEmpty { break }
                    let newSlot: Slot = Slot(cardID: newCards.removeFirst().id)
                    grid[index] = newSlot
                }
            }
        } else {
            for newTableCard in newTableCards {
                grid.append(Slot(cardID: newTableCard.id))
            }
        }
    }
    
    /// Updates the removed cards.
    /// - Parameter allRemovedCards: The actual removed cards, including old ones and newly added.
    func updateRemovedCards(with allRemovedCards: [Card]) {
        let known = Set(removedCardIDsInOrder)
        let newlyRemoved = allRemovedCards.filter { !known.contains($0.id) }
        removedCardIDsInOrder.append(contentsOf: newlyRemoved.map { $0.id })
    }
    
    //MARK: -Intents
    /// Manages grid updates and indicates the Model the user's intent of selecting a card.
    func select(_ card: Card) {
        game.select(card: card)
    }
    
    func updatePossibleSet() {
        game.updateSelectionStatuses(cards: selectedCards)
    }
    
    func deSelect(_ card: Card) {
        game.deSelect(card: card)
    }
    
    func removeCards() {
        game.removeCards()
        updateRemovedCards(with: game.removedCards)
        removeCardsFromSlots()
    }
    
    func dealCards() {
        switch (tableCards.isEmpty, matchedCards.isEmpty) {
        case (true, _):
            startInitialDeal()
            
        case (false, true):
            dealAdditionalCards()
            
        case (false, false):
            replaceMatchedCards()
        }
    }
    
    private func startInitialDeal() {
        game.dealCards()
        createNewEmptyGrid()
        newTableCards = tableCards
        placeCardsOnGrid(from: newTableCards)
    }

    private func dealAdditionalCards() {
        game.addCards()
        newTableCards = undealtTableCards
        placeCardsOnGrid(from: newTableCards)
    }

    private func replaceMatchedCards() {
        game.replaceCards()
        updateRemovedCards(with: game.removedCards)
        removeCardsFromSlots()
        newTableCards = undealtTableCards
        placeCardsOnGrid(from: newTableCards)
    }

    private func placeCardsOnGrid(from cards: [Card]) {
        var copy = cards
        fillEmptySlots(with: &copy)
    }

    func moveCardsToDeck() {
        game.moveCardsToDeck()
        removedCardIDsInOrder = []
    }

    /// Shuffles the Model's table cards and synchronises the View's grid to the changes.
    func shuffleCards() {
        grid = grid.shuffled()
    }
    
    /// A space in a grid that may be empty or contain an object.
    struct Slot: Identifiable, CustomDebugStringConvertible {
        let id: UUID = UUID()
        let cardID: Card.ID?
        
        var debugDescription: String {
            if cardID != nil {
                "card: \(String(describing: cardID))"
            } else {
                "card: empty"
            }
        }
    }
}

//MARK: -Constants
private struct Constants {
    struct Card {
        static let shapeLineWidth: CGFloat = 1
        static let selectionColorOpacity: CGFloat = 0.2
    }

    struct Stripe {
        static let cardsThreshold: Int = 25 // When this table cards' threshold is reached, stripes setting adapt to fit better on screen.
        static let bold: (count: Int, width: CGFloat) = (count: 20, width: 0.5) // Stripes setting for few table cards on screen.
        static let fine: (count: Int, width: CGFloat) = (count: 30, width: 0.2) // Stripes setting for many table cards on screen.
    }
}


