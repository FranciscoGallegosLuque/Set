//
//  CardView.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 06/05/2025.
//

import SwiftUI

struct CardView: View {
    var vm: SetGameViewModel
    let card: SetGame.Card

    var body: some View {
        ZStack(content: {
            let base: RoundedRectangle = RoundedRectangle(cornerRadius: 12)
            Group {
                base.foregroundStyle(vm.cardBackgroundColor(for: card))
                base.strokeBorder(lineWidth: 1)
                VStack {
                    ForEach(0..<card.number, id: \.self) { _ in
                        ZStack {
                            vm.shape(for: card)
                        }
                    }
                }
                .padding()
            }
            .foregroundStyle(vm.color(for: card))
        })
    }
}

#Preview {
    CardView(vm: SetGameViewModel(),
             card: SetGame.Card(
                number: 2,
                feature1: "red",
                feature2: "circle",
                feature3: "striped"
        )
    )
}
