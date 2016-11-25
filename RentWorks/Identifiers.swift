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
        case ToPropertyDetailsVC = "segueShowPropertyDetails"
        case MoreCardsVC = "segueShowNoMoreCardsVC"
        case MainSwipingVC = "toMainSwipingVC"
        case noInternetVC = "segueToNoInternetVC"
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
    }
}
