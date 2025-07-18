//
//  SetGameView.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 05/05/2025.
//

import SwiftUI

/// A View that show the Set Game.
struct SetGameView: View {
    // MARK: - State & Init
    
    /// The home screen View view model.
    @ObservedObject var viewModel: SetGameViewModel
    @Namespace private var pilesNamespace
    
    
    // MARK: - Cards
    @State private var visuallyDealt: [Card.ID] = []
    private var deckCards: [Card] { viewModel.deckCards }
    private var removedCards: [Card] { viewModel.removedCards }
    private var undealtCards: [Card] { viewModel.cards.filter { !isDealt($0) } }
    
    
    // MARK: - Body
    var body: some View {
        VStack {
            gameTitle
            availableSetMessage
            gameStateContent
            cardsPiles
            controlButtons
        }
        .padding()
        .onAppear {
            for card in viewModel.tableCards {
                visuallyDealt.append(card.id)
            }
        }
    }
    
    // MARK: - Main Subviews
    /// The game title.
    var gameTitle: some View {
        Text("Set Game")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding(.top)
    }
    
    /// A message indicating whether there is an available set to be chosen in the table.
    var availableSetMessage: some View {
        Text("Available Set? \(viewModel.availableSet ? "Yes" : "No")")
    }
    
    /// A conditional View that shows whether an end message if the player wins or the card grid.
    @ViewBuilder
    private var gameStateContent: some View {
        if viewModel.gameEnded {
            gameEndedMessage
        } else {
            cardGrid
        }
    }
    
    /// A grid of cards.
    var cardGrid: some View {
        AspectVGrid(viewModel.grid, aspectRatio: Constants.Layout.cardAspectRatio) { slot in
            if let cardID = slot.cardID {
                if let card = viewModel.cards.first(where: { $0.id == cardID }) {
                    if isDealt(card) {
                        let zIndex = computeZIndex(card)
                        CardView(cardViewModel: CardViewModel(tableCards: viewModel.tableCards.count),
                                 card: card)
                            .matchedGeometryEffect(id: card.id, in: pilesNamespace)
                            .transition(.asymmetric(insertion: .identity, removal: .identity))
                            .padding(Constants.Layout.cardSpacing)
                            .onTapGesture {
                                selectCard(card)
                            }
                            .zIndex(zIndex)
                    } else { Color.clear }
                }
            } else { Color.clear }
        }
    }
    
    /// A message shown when user selects all sets and wins.
    var gameEndedMessage: some View {
        VStack {
            Spacer()
            Text("You won!")
                .font(.largeTitle)
            Spacer()
        }
    }
    
    /// A View showing the two piles of cards (deck and discard pile).
    var cardsPiles: some View {
        HStack {
            Spacer()
            discardPile
            Spacer()
            deckPile
            Spacer()
        }
        .padding()
    }
    
    /// A stack of buttons to start a new game and deal new cards if requested.
    var controlButtons: some View {
        HStack(spacing: Constants.Buttons.spacing) {
            newGameButton
            shuffleButton
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
    
    // MARK: - Piles
    /// A pile with the already matched cards.
    var discardPile: some View {
        ZStack {
            ForEach(removedCards) { card in
                    CardView(cardViewModel: CardViewModel(tableCards: viewModel.tableCards.count),
                             card: card)
                        .matchedGeometryEffect(id: card.id, in: pilesNamespace)
                        .transition(.asymmetric(insertion: .identity, removal: .identity))
                        .offset(randomOffset(for: card))
                }
            }
            .frame(
                width: Constants.Layout.deckWidth,
                height: Constants.Layout.deckWidth / Constants.Layout.cardAspectRatio
            )
        }
    
    /// A pile with the deck of cards piled unevenly.
    var deckPile: some View {
        ZStack {
            ForEach(deckCards) { card in
                CardView(cardViewModel: CardViewModel(tableCards: viewModel.tableCards.count),
                         card: card)
                    .matchedGeometryEffect(id: card.id, in: pilesNamespace)
                    .transition(.asymmetric(insertion: .identity, removal: .identity))
                    .offset(randomOffset(for: card))
            }
        }
        .frame(
            width: Constants.Layout.deckWidth,
            height: Constants.Layout.deckWidth / Constants.Layout.cardAspectRatio
        )
        .onTapGesture {
            animateDealingOfCards()
        }
    }

    // MARK: - Buttons
    /// A button that starts a new game, with random cards.
    var newGameButton: some View {
        Button("New Game") {
            startNewGame()
        }
    }
    
    
    /// A button that shuffles the visible cards.
    var shuffleButton: some View {
        Button("Shuffle") {
            withAnimation {
                viewModel.shuffleCards()
            }
        }
    }
    
    // MARK: - User Actions
    
    /// Animates the dealing of new cards.
    func animateDealingOfCards() {
        withAnimation {
            viewModel.dealCards()
        }
        let newCards = viewModel.newTableCards
        var delay: TimeInterval = 0
        for index in newCards.indices {
            withAnimation(Constants.Animations.dealAnimation.delay(delay)) {
                visuallyDealt.append(newCards[index].id)
            }
            delay += Constants.Animations.dealInterval
        }
    }
    
    
    /// Handles the animation of the user's intent of starting a new game.
    func startNewGame() {
        viewModel.moveCardsToDeck()
        visuallyDealt = []
        animateDealingOfCards()
    }
    
    /// Handles the animation of the user's intent of selecting a card.
    /// - Parameter card: The card selected.
    func selectCard(_ card: Card) {
        viewModel.select(card)
        
        if viewModel.isSetComplete {
            withAnimation {
                viewModel.updatePossibleSet()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    if !viewModel.matchedCards.isEmpty {
                        viewModel.removeCards()
                    } else {
                        viewModel.misMatchedCards.forEach { viewModel.deSelect($0) }
                    }
                }
            }
        }
    }


    
    // MARK: - Helpers
    /// Computes the ZIndex of a given card based on if it is dealt or not.
    /// - Parameter card: The card to be displayed.
    /// - Returns: The zIndex of the given card.
    func computeZIndex(_ card: Card) -> Double {
        visuallyDealt.suffix(viewModel.game.setSize).contains(card.id) ? Constants.ZIndex.top : Constants.ZIndex.base
    }
    
    /// Computes a random offset for a card displayed on a pile.
    /// - Parameter card: The card to be displayed.
    /// - Returns: The offset of the given card, both in x and y.
    func randomOffset(for card: Card) -> CGSize {
        let seed = card.id.hashValue
        let modX = Constants.Offset.seedModX
        let modY = Constants.Offset.seedModY
        let centerBias = Constants.Offset.centerBias
        let scale = Constants.Offset.scale
        
        let x = Double(seed % modX) / Double(modX) - centerBias
        let y = Double((seed / modX) % modY) / Double(modY) - centerBias
        
        return CGSize(width: x * scale, height: y * scale)
    }
    
    
    /// Determines whether the card is visually dealt or not.
    /// - Parameter card: The card to be check.
    /// - Returns: `true` if the card is visually dealt; otherwise, `false`.
    private func isDealt(_ card: Card) -> Bool {
        visuallyDealt.contains(card.id)
    }
    
    // MARK: - Constants
    private struct Constants {
        struct Layout {
            static let cardAspectRatio: CGFloat = 2 / 3
            static let cardSpacing: CGFloat = 4
            static let deckWidth: CGFloat = 50
        }

        struct ZIndex {
            static let top: Double = 1
            static let base: Double = 0
        }

        struct Offset {
            static let seedModX = 1000
            static let seedModY = 1000
            static let scale: CGFloat = 1.0
            static let centerBias = 0.5
        }

        struct Animations {
            static let dealAnimation: Animation = .easeInOut(duration: 0.6)
            static let dealInterval: Double = 0.1
        }

        struct Buttons {
            static let spacing: CGFloat = 60
        }
    }
}

#Preview {
    SetGameView(viewModel: SetGameViewModel())
}
