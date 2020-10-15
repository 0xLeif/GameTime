//
//  AddGameView.swift
//  GameTime
//
//  Created by Zach Eriksen on 10/12/20.
//

import SwiftUI
import Neon

struct SearchGameView: View {
    var body: some View {
        VStack {
            SearchBar()
                .padding(8)
            Spacer()
        }
    }
}



struct AddGameView_Previews: PreviewProvider {
    static var previews: some View {
        SearchGameView()
            .preferredColorScheme(.dark)
    }
}
