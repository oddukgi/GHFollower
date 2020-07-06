//
//  ErrorMessage.swift
//  GHFollowers
//
//  Created by Sunmi on 2020/06/05.
//  Copyright © 2020 CreativeSuns. All rights reserved.
//

import Foundation


// rawValue : String
enum GFError: String, Error {
    
    case invalidUsername  = "This username created an invalid request. Please try again."
    case unableToComplete = "Unable to complete your request. Please check your internet connection"
    case invalidResponse  = "Invalid response from the server. Please try again."
    case invalidData      = "The data received from the server was invalid. Please try again."
    case unableToFavorite = "There was an error favoriting this user. Please try again."
    case alreadyInFavorites = "You've already favorited this user. You must REALLY like them!"
    
}
