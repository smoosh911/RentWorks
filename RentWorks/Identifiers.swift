//
//  Segues.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class Identifiers {
    enum Segues: String {
        case editPropertyDetailsVC = "segueEditPropertyDetails"
        case addPropertyVC = "segueAddProperty"
        case MoreCardsVC = "segueShowNoMoreCardsVC"
        case MainSwipingVC = "toMainSwipingVC"
        case noInternetVC = "segueToNoInternetVC"
        case propertyMatchesVC = "segueToPropertyMatchesVC"
        case mainVC = "segueToMainVC"
    }
    
    enum StoryboardIDs: String {
        case noInternetVC = "noInternetVC"
    }
    
    enum TableViewCells: String {
        case PropertyCell = "propertyCell"
    }
    
    enum CollectionViewCells: String {
        case PropertyImageCell = "propertyImageCell"
    }
    
    enum UserDefaults: String {
        case landlordMatchCount = "landlordMatchCount"
        case renterMatchCount = "renterMatchCount"
        case propertyMatchCount = "propertyMatchCount"
    }
}
