//
//  SearchGameView.swift
//  GameTime
//
//  Created by Zach Eriksen on 10/12/20.
//

import SwiftUI
import Neon
import SUIObject
import Combine
//import Combino

struct SearchGameView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var bag = Set<AnyCancellable>()
    @State private var games = [Game]()
    
    var body: some View {
        ScrollView {
            VStack {
                SearchBar { text in
                    search(gameNamed: text)
                }
                .padding(8)
                LazyVStack {
                    ForEach(games, id: \.self) { game in
                        GameListView(game: game)
                            .padding(8)
                    }
                }
                Spacer()
            }
        }
    }
    
    private func search(gameNamed name: String) {
        games = []
        TwitchAPI.searchGames(named: name)
            .map { value in
                value.array.map { value in
                    Object {
                        $0.add(variable: "name", value: value.name)
                        $0.add(variable: "gameId", value: value.id)
                        $0.add(variable: "coverId", value: value.cover)
                    }
                }
            }
            .sink(receiveCompletion: {
                print($0)
            }) { (values) in
                print(values)
                values.forEach { value in
                    guard let id: Int = value.gameId.value() else {
                        return
                    }
                    let searchedGame = Game(context: viewContext)
                    searchedGame.timestamp = Date()
                    searchedGame.gameId = id.description
                    searchedGame.coverId =  value.coverId.value(as: Int.self)?.description
                    searchedGame.title = value.name.value()
                    
                    games.append(searchedGame)
                }
            }
            .store(in: &bag)
    }
    
    private func addGame(gameId: String,
                         coverId: String? = nil,
                         withTitle title: String? = nil) {
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
}



struct AddGameView_Previews: PreviewProvider {
    static var previews: some View {
        SearchGameView()
            .preferredColorScheme(.dark)
    }
}
