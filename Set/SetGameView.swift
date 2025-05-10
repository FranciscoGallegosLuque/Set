//
//  SetGameView.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 05/05/2025.
//

import SwiftUI

struct SetGameView: View {
    
    @ObservedObject var vm: SetGameViewModel
    
    private let aspectRatio: CGFloat = 2/3
    
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
    
    var controlButtons: some View {
        HStack(spacing: 60) {
            Button("New Game") {
                vm.startNewGame()
            }
            .buttonStyle(.borderedProminent)
            Button("Deal cards") {
                vm.addThree()
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.deckCards.count == 0)
        }
    }
    
    var cards: some View {
        AspectVGrid(vm.tableCards, aspectRatio: aspectRatio) { card in
            CardView(vm: vm, card: card)
                .padding(4)
                .onTapGesture {
                    vm.select(card)
                }
        }
    }
}


#Preview {
    SetGameView(vm: SetGameViewModel())
}
