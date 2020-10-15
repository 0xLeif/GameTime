//
//  CoverImageLoader.swift
//  GameTime
//
//  Created by Zach Eriksen on 10/9/20.
//

import SwiftUI
import Combine

class CoverImageLoader: ObservableObject {
    @State private var task: AnyCancellable?
    @Published var coverImageURL: URL?
    
    init() { }
    
    deinit {
        task?.cancel()
    }
    
    func load(coverId: String?) {
        guard let id = coverId else {
            print("Cover ID: nil")
            return
        }
        
        guard coverImageURL == nil else {
            print("coverImageURL != nil")
            return
        }
        
        print("Cover ID: \(id)")
        
        /// ACK: https://stackoverflow.com/questions/62264708/execute-combine-future-in-background-thread-is-not-working
        /// To sink correctly we must subscribe on the `DispatchQueue.global()`
        /// `.subscribe(on: DispatchQueue.global())`
        task = TwitchAPI.cover(forId: id)
            .subscribe(on: DispatchQueue.global())
            .sink(receiveCompletion: { _ in }) { object in
                guard let urlString = object.array.first?.url.stringValue()?.dropFirst(2).description,
                      let url = URL(string: "https://\(urlString)") else {
                    return
                }
                DispatchQueue.main.async {
                    self.coverImageURL = url
                }
            }
        
    }
}
