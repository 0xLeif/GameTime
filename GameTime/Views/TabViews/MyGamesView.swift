//
//  MyGamesView.swift
//  GameTime
//
//  Created by Zach Eriksen on 10/12/20.
//

import SwiftUI

struct MyGamesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Game.timestamp, ascending: true)],
        animation: .default)
    private var games: FetchedResults<Game>
    
    var body: some View {
        List {
            ForEach(games) { game in
                GameListView(game: game)
                    .padding([.top, .bottom])
            }
            .onDelete(perform: deleteGames)
        }
        .toolbar {
            HStack {
                EditButton()
                Spacer()
                Button("Clear") {
                    deleteGames(offsets: IndexSet(games.indices))
                }
            }
        }
        
//        .onAppear {
//            if TwitchAPI.isAuthenticated {
//                fetchGames()
//            } else {
//                Combino.do(withDelay: 5)
//                    .sink(
//                        .success {
//                            if TwitchAPI.isAuthenticated {
//                                fetchGames()
//                            }
//                        }
//                    )
//            }
//
//        }
    }
    
    
    
    private func deleteGames(offsets: IndexSet) {
        withAnimation {
            offsets.map { games[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let gameFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct MyGamesView_Previews: PreviewProvider {
    static var previews: some View {
        MyGamesView()
    }
}
