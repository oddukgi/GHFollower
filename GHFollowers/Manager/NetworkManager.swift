//
//  NetworkManager.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/06/04.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import UIKit
import SwiftSoup

class NetworkManager {
    
    static let shared   = NetworkManager()
    private let baseURL = "https://api.github.com/users/"

    let cache           = NSCache<NSString, UIImage>()
    var document: Document = Document.init("")
    private var contributions: [Contribution] = []
    var months: [String] = []
    
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
            
            guard error == nil,
                let response = response as? HTTPURLResponse, response.statusCode == 200
                else  {
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
    
    
    // MARK: - get github contribution date
      func getContributionDate(for username: String, completed: @escaping ([Contribution]) -> Void) {
      
        let endpoint = baseURL.replacingOccurrences(of: "api.", with: "") + "\(username)/contributions"
     
          // background thread
          guard let url = URL(string: endpoint) else {
            
              completed([])
              return
          }
       
          let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                
                guard let self = self,
                    error == nil,
                    let response = response as? HTTPURLResponse,response.statusCode == 200,
                    let data = data else {
                        completed([])
                        return
                }
                
            let htmlValue = String(decoding: data, as: UTF8.self)
            
            // parse css query
            self.parse(for: "text",  htmlValue: htmlValue)
            self.parse(for: "rect", htmlValue: htmlValue)
            completed(self.contributions)
                
        }
            
        task.resume()

      }
    
     //Parse CSS selector
    fileprivate func filterAttributes(_ element: Element, for attr1: String, for attr2: String) -> (String, String) {
        
        var date = ""
        var color = ""
        
        if let attributeData = try? element.attr(attr1) {
            date = attributeData
        }
        if let attribute2Data = try? element.attr(attr2) {
            color = attribute2Data
        }
        
        return (date, color)
    }
    
    func parse(for tag: String, htmlValue: String) {
        
      guard let elements: Elements = try? SwiftSoup.parse(htmlValue).select(tag) else { return }

        if !contributions.isEmpty {
            contributions.removeAll()
        }
        
        if !months.isEmpty {
            months.removeAll()
        }

     	for element in elements {
       
            if tag == "text" {
                
                guard try! element.attr("class").contains("month") else { return }
                let text = try? element.text()
                months.append(text!)
            }
            
            if tag == "rect" {
                
                let date = filterAttributes(element,for: "data-date", for: "").0
                let color = filterAttributes(element,for: "", for: "fill" ).1
                
                let data = Contribution(month: "", contributionDate: date, contributionColor: color)
                contributions.append(data)
                
            }
       }
    }
}


