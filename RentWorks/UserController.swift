//
//  UserController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class UserController {
    
    static var temporaryUserDictionary: [String: Any] = [:]
    
    
    static func addAttributeToUserDictionary(attribute: [String: Any]) {
        guard let key = attribute.keys.first, let value = attribute.values.first else { return }
        temporaryUserDictionary[key] = value
    }
    
    
    
    
}


extension UserController {
    // Renter/property creation enums
    
    static let kPropertyType = "propertyType"
    static let kPropertyFeatures = "propertyFeatures"
    static let kCreditRating = "creditRating"
    
    enum PropertyType: String {
        case studio = "studio"
        case oneBedroom = "oneBedroom"
        case twoBedrooms = "twoBedrooms"
        case threePlusBedrooms = "threePlusBedrooms"
    }

    enum PropertyFeatures: String {
        case laundry = "laundry"
        case garage = "garage"
        case pool = "pool"
        case gym = "gym"
        case dishwasher = "dishwasher"
    }
    
    enum CreditRating: String {
        case a = "a"
        case b = "b"
        case c = "c"
        case d = "d"
    }
}
