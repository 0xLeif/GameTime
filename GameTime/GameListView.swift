//
//  GameListView.swift
//  GameTime
//
//  Created by Zach Eriksen on 9/25/20.
//

import SwiftUI
import SUIObject
import Combino
import Combine

struct GameListView: View {
    let game: Game
    
    var body: some View {
        Text(game.title ?? "-1")
    }
}
