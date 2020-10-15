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
import Neon

struct GameListView: View {
    @StateObject private var coverImageLoader = CoverImageLoader()
    @State var authFailureRetryTask: AnyCancellable?
    let game: Game
    
    var randomUnitPoint: UnitPoint = unitPoints.randomElement() ?? .center
    
    var body: some View {
        VStack(spacing: 32) {
            HStack(spacing: 16) {
                Text(game.title ?? "-1")
                    .foregroundColor(.white)
                    .modifier(NeonRounded(color: neonColor,
                                          lineWidth: 4,
                                          shadowRadius: 8))
                    .background(neonColor.cornerRadius(8))
                    .shadow(radius: 4)
                
                Spacer()
                
                
                Group {
                    if let image = coverImageLoader.coverImageURL {
                        AsyncImage(url: image) {
                            ProgressView()
                        }
                    } else {
                        Image(systemName: "gamecontroller")
                    }
                }
                .frame(width: 64, height: 64, alignment: .center)
                .foregroundColor(.white)
                .font(.largeTitle)
                .modifier(NeonRounded(color: neonColor))
                .background(
                    AngularGradient(gradient: Gradient(colors: [
                        neonColor,
                        .purple,
                        neonColor,
                        .orange,
                        .purple,
                        neonColor
                    ]),
                    center: .center,
                    angle: .degrees(0))
                    .blur(radius: 1.0)
                )
                
            }
            
            HStack {
                Spacer()
                VStack {
                    HStack {
                        Text("Game ID:")
                            .foregroundColor(.white)
                        Text(game.gameId ?? "-1")
                            .foregroundColor(.white)
                    }
                    
                    game.coverId.map { coverId in
                        HStack {
                            Text("Cover ID:")
                                .foregroundColor(.white)
                            Text(coverId)
                                .foregroundColor(.white)
                        }
                    }
                }
                .modifier(NeonRectangle(color: .orange,
                                        lineWidth: 4,
                                        shadowRadius: 8))
                .background(neonColor)
            }
        }
        .padding()
        .modifier(NeonRounded(color: neonColor))
        .background(
            AngularGradient(gradient: Gradient(colors: [
                .pink,
                .purple,
                .pink,
                .orange,
                .purple,
                .pink
            ]),
            center: randomUnitPoint,
            angle: .degrees(275))
            .blur(radius: 1.0)
        )
        .onAppear {
            loadCoverImage()
        }
    }
    
    func loadCoverImage() {
        guard coverImageLoader.coverImageURL == nil else {
            return
        }
        
        guard TwitchAPI.isAuthenticated else {
            authFailureRetryTask = Combino.do(withDelay: 5)
                .sink(
                    .success {
                        if TwitchAPI.isAuthenticated {
                            coverImageLoader.load(coverId: game.coverId)
                        }
                    }
                )
            return
        }
        
        coverImageLoader.load(coverId: game.coverId)
        
        return
    }
    
}
