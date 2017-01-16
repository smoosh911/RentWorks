//
//  Landlord + Convenience.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import CoreData

extension Landlord {
    
    @discardableResult convenience init?(email: String, firstName: String, lastName: String, id: String, starRating: Double = 5.0, context: NSManagedObjectContext? = CoreDataStack.context) {
        
        if let context = context {
            self.init(context: context)
        } else {
            self.init(entity: Landlord.entity(), insertInto: nil)
        }
        
        self.birthday = birthday
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.starRating = starRating
    }
    
    @discardableResult convenience init?(dictionary: [String: Any], id: String? = nil, context: NSManagedObjectContext? = CoreDataStack.context) {
        guard let email = dictionary[UserController.kEmail] as? String,
            let firstName = dictionary[UserController.kFirstName] as? String,
            let lastName = dictionary[UserController.kLastName] as? String
            else { return nil }
        
        if let context = context {
            self.init(context: context)
        } else {
            self.init(entity: Landlord.entity(), insertInto: nil)
        }
        
        var wantsCreditRating: String = "Any"
        if let wantsCreditRatingFromDict = dictionary[UserController.kWantsCreditRating] as? String {
            wantsCreditRating = wantsCreditRatingFromDict
        }
        
        if let withinRangeMiles = dictionary[UserController.kWithinRangeMiles] as? Int {
            self.withinRangeMiles = Int16(withinRangeMiles)
        } else {
            self.withinRangeMiles = 50
        }
        
        if let starRating = dictionary[UserController.kStarRating] as? Double {
            self.starRating = starRating
        } else {
            self.starRating = 0.0
        }
        
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.wantsCreditRating = wantsCreditRating
        self.id = id
    }
}
