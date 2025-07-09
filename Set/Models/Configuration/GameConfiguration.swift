//
//  GameConfiguration.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 09/07/2025.
//

import Foundation


/// The different possible game configurations to initilialize the game.    
struct GameConfig {
    /// The classic Set game configuration, with 3 features (color, shape and shading), 12 initial cards and 3 cards added.
    static let classic = GameSettings(
        theme: Theme(
            features: [
                Theme.Feature(name: "color", possibleValues: ["red","blue","green"]),
                Theme.Feature(name: "shape", possibleValues: ["diamond","squiggle","capsule"]),
                Theme.Feature(name: "shading", possibleValues: ["solid","striped","empty"])
            ]
        ),
        initialNumberOfCards: 12,
        numberOfAddedCards: 3
    )
}




