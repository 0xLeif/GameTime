//
//  ContentView.swift
//  GameTime
//
//  Created by Zach Eriksen on 9/24/20.
//

import SwiftUI
import CoreData
import SUIObject
import Combine
import Combino

struct ContentView: View {
    @State var bag = Set<AnyCancellable>()
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Game.timestamp, ascending: true)],
        animation: .default)
    private var games: FetchedResults<Game>
    
    var body: some View {
        List {
            ForEach(games) { game in
                GameListView(game: game)
            }
            .onDelete(perform: deleteGames)
        }
        .toolbar {
            #if os(iOS)
            EditButton()
            #endif
        }
        .onAppear {
            TwitchAPI.auth()
                .sink(.success { isAuthenticated in
                    if isAuthenticated {
                        TwitchAPI.games()
                            .sink {
                                [
                                    .success { (object) in
                                        object.array
                                            .map({ $0.name })
                                            .compactMap({ $0.stringValue() })
                                            .forEach { addGame(gameId: "", withTitle: $0) }
                                    },
                                    
                                    .failure { error in
                                        print("ERROR: \(error)")
                                    }
                                ]
                            }
                            .store(in: &bag)
                    }
                })
                .store(in: &bag)
        }
    }
    
    private func addGame(gameId: String,
                         coverId: String? = nil,
                         withTitle title: String? = nil) {
        guard !games.contains(where: { $0.title == title }) else {
            print("Uh oh! We already have an game with a title: \"\(title ?? "")\"")
            return
        }
        
        withAnimation {
            let newGame = Game(context: viewContext)
            newGame.timestamp = Date()
            newGame.gameId = gameId
            newGame.coverId = coverId
            newGame.title = title
            
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
