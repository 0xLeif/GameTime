//
//  GameTimeApp.swift
//  GameTime
//
//  Created by Zach Eriksen on 9/24/20.
//

import SwiftUI

@main
struct GameTimeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
