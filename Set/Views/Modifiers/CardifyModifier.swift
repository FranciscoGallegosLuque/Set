//
//  Cardify.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 23/05/2025.
//

import SwiftUI

/// A view modifier that returns a "card" version of the contents passed in.
struct Cardify: ViewModifier {
    var selectionColor: Color
   
    func body(content: Content) -> some View {
        ZStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let cornerRadius = min(width, height) * Constants.cornerRadius
                let lineWidth = min(width, height) * Constants.lineWidth
                let base: RoundedRectangle = RoundedRectangle(cornerRadius: cornerRadius)
                base.strokeBorder(lineWidth: lineWidth)
                    .background(base.fill(selectionColor))
                    .overlay(content)
                
            }
        }
    }
    
    private struct Constants {
       static let cornerRadius: CGFloat = 0.1
       static let lineWidth: CGFloat = 0.02
   }
}

extension View {
    func cardify(selectionColor: Color) -> some View {
        return self.modifier(Cardify(selectionColor: selectionColor))
    }
}
