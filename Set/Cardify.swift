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
   
    /// Returns a View with a 
    func body(content: Content) -> some View {
        ZStack {
            let base: RoundedRectangle = RoundedRectangle(cornerRadius: Constants.cornerRadius)
            base.strokeBorder(lineWidth: Constants.lineWidth)
                .background(base.fill(selectionColor))
                .overlay(content)
        }
    }
    
    private struct Constants {
        static let cornerRadius: CGFloat = 12
        static let lineWidth: CGFloat = 2
    }
}

extension View {
    func cardify(selectionColor: Color) -> some View {
        return self.modifier(Cardify(selectionColor: selectionColor))
    }
}
