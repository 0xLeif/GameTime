//
//  ContentView.swift
//  GameTime
//
//  Created by Zach Eriksen on 9/24/20.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        TabView {
            TimelineView()
                .tabItem {
                    VStack {
                        Image(systemName: "clock")
                        Text("Timeline")
                    }
                }
            
            MyGamesView()
                .tabItem {
                    VStack {
                        Image(systemName: "list.bullet.below.rectangle")
                        Text("My Games")
                    }
                }
            
            SearchGameView()
                .tabItem {
                    VStack {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    
                }
        }
    }
   
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
