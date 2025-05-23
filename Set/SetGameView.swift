//
//  SetGameView.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 05/05/2025.
//

import SwiftUI

/// A View that show the Set Game.
struct SetGameView: View {
    
    /// The ViewModel var
    @ObservedObject var viewModel: SetGameViewModel

    
    var body: some View {
        VStack {
            title
            cards
            controlButtons
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    var title: some View {
        Text("Set Game")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding(.top)
    }
    
    /// A stack of buttons to start a new game and deal new cards if requested.
    var controlButtons: some View {
        HStack(spacing: 60) {
            newGameButton
            dealCardsButton
                .disabled(viewModel.deckCards.count == 0)
        }
        .buttonStyle(.borderedProminent)
    }
    
    /// A button that starts a new game, with random cards.
    var newGameButton: some View {
        Button("New Game") {
            viewModel.startNewGame()
        }
    }
    
    /// A button that deals 3 cards when requested.
    ///
    /// Whenever 3 non-matching cards are selected, deals 3 more cards. If 3 matching cards are selected, replaces the matching cards with 3 new cards.
    var dealCardsButton: some View {
        Button("Deal cards") {
            viewModel.addThree()
        }
    }
    
    
    var cards: some View {
        AspectVGrid(viewModel.tableCards, aspectRatio: Constants.aspectRatio) { card in
            CardView(viewModel: viewModel, card: card)
                .padding(Constants.cardsSpacing)
                .onTapGesture {
                    viewModel.select(card)
                }
        }
    }
    
    private struct Constants {
        static let cardsSpacing: CGFloat = 4
        static let aspectRatio: CGFloat = 2/3
    }
}


#Preview {
    SetGameView(viewModel: SetGameViewModel())
}
