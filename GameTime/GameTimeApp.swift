//
//  GameTimeApp.swift
//  GameTime
//
//  Created by Zach Eriksen on 9/24/20.
//

import SwiftUI
import Combine

@main
struct GameTimeApp: App {
    @State private var task: AnyCancellable?
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .navigationTitle("GameTime")
            }
            .onAppear {
                task = TwitchAPI.auth().sink(.success { print("Auth: \($0)") })
            }
        }
    }
}

let neonColor = Color.pink
let unitPoints: [UnitPoint] = [
    .topLeading, .top, .topTrailing,
    .leading, .center, .trailing,
    .bottomLeading, .bottom, .bottomTrailing
]
