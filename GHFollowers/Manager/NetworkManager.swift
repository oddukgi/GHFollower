//
//  NetworkManager.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/06/04.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import UIKit

class NetworkManager {
    
    static let shared   = NetworkManager()
    private let baseURL = "https://api.github.com/users/"
    let cache           = NSCache<NSString, UIImage>()
    
    private init() {}
    
    // return : [Follower]
    func getFollowers(for username: String, page: Int, completed: @escaping (Result<[Follower], GFError>) -> Void) {
        let endpoint = baseURL + "\(username)/followers?per_page=100&page=\(page)"
    
        // background thread
        guard let url = URL(string: endpoint) else {
            
            completed(.failure(.invalidUsername))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ = error {
                completed(.failure(.unableToComplete))
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .iso8601
                let followers = try decoder.decode([Follower].self, from: data)
                completed(.success(followers))
            } catch {
                 completed(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
     
    // Why put @escaping? Network condition is bad or good.
    // When network get stuck or crappy, result should go out in hurry
    // @escaping : out leave of function

    func getUserInfo(for username: String,completed: @escaping (Result<User, GFError>) -> Void) {
        let endpoint = baseURL + "\(username)"
        
            // background thread
            guard let url = URL(string: endpoint) else {
                
                completed(.failure(.invalidUsername))
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                
                if let _ = error {
                    completed(.failure(.unableToComplete))
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    completed(.failure(.unableToComplete))
                    return
                }
                
                guard let data = data else {
                    completed(.failure(.invalidData))
                    return
                }
                
                do {
                    let decoder                  = JSONDecoder()
                    decoder.keyDecodingStrategy  = .convertFromSnakeCase
                    decoder.dateDecodingStrategy = .iso8601
                    let user = try decoder.decode(User.self, from: data)
                    completed(.success(user))
                } catch {
                    completed(.failure(.invalidData))
            }
        }
            
        task.resume()
    }

    func downloadImage(from urlString: String, completed: @escaping (UIImage?) -> Void) {
        // set image cache
        let cacheKey = NSString(string: urlString)
        // get UIImage
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
            return
            
        }
        // don't have image and download from url
        guard let url = URL(string: urlString) else {
            completed(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let self = self,
                error == nil,
                let response = response as? HTTPURLResponse,response.statusCode == 200,
                let data = data,
                let image = UIImage(data: data) else {
                completed(nil)
                return
            }
            
            self.cache.setObject(image, forKey: cacheKey)
            completed(image)
            
        }
        
        task.resume()
    }
}


