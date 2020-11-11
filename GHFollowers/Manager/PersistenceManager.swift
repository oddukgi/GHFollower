//
//  PersistenceManager.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/06/26.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import Foundation

enum PersistenceActionType {
     case add, remove
}

enum PersistenceManager {
    
    static private let defaults = UserDefaults.standard
    
    enum Keys { static let favorites = "favorites" }
    
    static func updateWith(favorite: Follower, actionType: PersistenceActionType, completed: @escaping(GFError?) -> Void) {
        retrieveFavorites { result in
            switch result {
            case .success(var retrievedFavorites):
                
                switch actionType {
                case .add:
                    guard !retrievedFavorites.contains(favorite) else {
                        completed(.alreadyInFavorites)
                        return
                    }
                    retrievedFavorites.append(favorite)
                case .remove:
                    retrievedFavorites.removeAll{ $0.login == favorite.login }
                }
                
                completed(save(favorites: retrievedFavorites))
                
            case .failure(let error):
                completed(error)

            }
            
        }
    }
    
    static func retrieveFavorites(completed: @escaping(Result<[Follower],GFError>) -> Void) {
        guard let faovoriteData = defaults.object(forKey: Keys.favorites) as? Data else {
            completed(.success([]))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let favorites = try decoder.decode([Follower].self, from: faovoriteData)
            completed(.success(favorites))
        } catch {
            
            print(error.localizedDescription)
            completed(.failure(.unableToFavorite))
        }
    }
    
    
    static func save(favorites: [Follower]) -> GFError? {
       
        do {
            let encoder = JSONEncoder()
            let encoderFavorites = try encoder.encode(favorites)
            // json의 특정키 에 맞는 값 가져오기
            defaults.set(encoderFavorites, forKey: Keys.favorites)
            return nil
        } catch {
            return .unableToFavorite
        }
    }
}
