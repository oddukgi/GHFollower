//
//  User.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/06/04.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import Foundation

struct User: Codable {
    let login: String
    let avatarUrl: String
    var name: String?
    var location: String?
    var bio: String?
    let publicRepos: Int
    let publicGists: Int
    let htmlUrl: String
    let following: Int
    let followers: Int
    let createdAt: Date
    
    init(login: String = "", avatarUrl: String = "", name: String = "", location: String = "", bio: String = "",
         publicRepo: Int = 0,publicGist: Int = 0, htmlUrl: String = "" ,following: Int = 0, followers: Int = 0) {
       
        self.login        = login
        self.avatarUrl    = avatarUrl
        self.name        = name
        self.location    = avatarUrl
        self.bio           = bio
        self.publicRepos    = 0
        self.publicGists    = 0
        self.htmlUrl     = ""
        self.following    = 0
        self.followers    = 0
        self.createdAt    = Date()
            
    }
}
