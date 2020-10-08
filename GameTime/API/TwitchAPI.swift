//
//  TwitchAPI.swift
//  GameTime
//
//  Created by Zach Eriksen on 9/24/20.
//

import Foundation
import SUIObject
import Combine
import Combino

struct TwitchAPI {
    // MARK: Private Variables
    
    private static let id = ProcessInfo.processInfo.environment["client_id"] ?? "ENTER_CLIENT_ID"
    private static let secret = ProcessInfo.processInfo.environment["client_secret"] ?? "ENTER_CLIENT_SECRET"
    private static let authURL = URL(string: "https://id.twitch.tv/oauth2/token?client_id=\(id)&client_secret=\(secret)&grant_type=client_credentials")!
    private static let apiURL = URL(string: "https://api.igdb.com/v4/")!
    
    private static var accessToken: String?
    private static var lastAuthDate: Date?
    private static var authExpiresIn: Int = 0
    
    private static var bag = Set<AnyCancellable>()
    
    private static var expirationTimeInterval: TimeInterval {
        guard let lastAuth = lastAuthDate else {
            return Date().timeIntervalSince1970
        }
        
        return lastAuth.timeIntervalSince1970 + Double(authExpiresIn)
    }
    
    // MARK: Public Variables
    
    static var isAuthenticated: Bool {
        guard accessToken != nil else {
            return false
        }
        
        guard expirationTimeInterval < Date().timeIntervalSince1970 else {
            return false
        }
        
        return true
    }
    
    // MARK: Public Functions
    
    static func auth() -> Future<Bool, Error> {
        Combino.promise { promise in
            DispatchQueue.main.async {
                Combino.post(url: authURL)
                    .sink {
                        [
                            .success { (data, response) in
                                print("Auth Response Status Code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                                guard let response = response else {
                                    promise(.success(false))
                                    return
                                }
                                
                                let obj = Object(data) {
                                    $0.add(variable: "response", value: response)
                                }
                                
                                guard obj.response.value(as: HTTPURLResponse.self)?.statusCode == 200 else {
                                    promise(.success(false))
                                    return
                                }
                                
                                lastAuthDate = Date()
                                accessToken = obj.access_token.stringValue()
                                
                                promise(.success(true))
                            },
                            .failure { error in
                                promise(.failure(error))
                            }
                        ]
                    }
                    .store(in: &bag)
            }
        }
    }
    
    static func post(route: String, withBody body: String) -> Future<Object, Error> {
        Combino.promise { promise in
            DispatchQueue.main.async {
                Combino.post(request: apiPostRequest(forRoute: route, withBody: body))
                    .sink {
                        [
                            .success { (data, response) in
                                print("POST (route: \(route)): Response Status Code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                                promise(.success(Object(data) { $0.add(variable: "response", value: response ?? -1) }))
                            },
                            .failure { error in
                                promise(.failure(error))
                            }
                        ]
                    }
                    .store(in: &bag)
            }
        }
    }
    static func searchGames(named name: String) -> Future<Object, Error> {
        post(route: "games", withBody: "fields *; search \"\(name)\";")
    }
    
    static func games() -> Future<Object, Error> {
        post(route: "games", withBody: "fields *; limit 100;")
    }
    
    static func cover(forId id: String) -> Future<Object, Error> {
        post(route: "covers", withBody: "fields *; where id = \(id);")
    }
    
    // MARK: Private Functions
    
    static func apiPostRequest(forRoute route: String, withBody body: String) -> URLRequest {
        var requestHeader = URLRequest.init(url: apiURL.appendingPathComponent(route))
        requestHeader.httpBody = body.data(using: .utf8, allowLossyConversion: false)
        requestHeader.httpMethod = "POST"
        requestHeader.setValue(id, forHTTPHeaderField: "Client-ID")
        requestHeader.setValue("Bearer \(accessToken ?? "-1")", forHTTPHeaderField: "Authorization")
        requestHeader.setValue("application/json", forHTTPHeaderField: "Accept")
        return requestHeader
    }
}
