//
//  SetApp.swift
//  Set
//
//  Created by Francisco Manuel Gallegos Luque on 03/05/2025.
//

import SwiftUI

@main
struct SetApp: App {
    @StateObject var game: SetGameViewModel = SetGameViewModel()
    
    var body: some Scene {
        WindowGroup {
            SetGameView(viewModel: game)
        }
    }
}
