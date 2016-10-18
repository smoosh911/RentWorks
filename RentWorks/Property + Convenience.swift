//
//  Property + Convenience.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import CoreData

extension Property {
    
    @discardableResult convenience init?(availableDate: NSDate, bathroomCount: Double, bedroomCount: Int, monthlyPayment: Int, petFriendly: Bool, smokingAllowed: Bool, rentalHistoryRating: Double, address: String, zipCode: String, profileImages: NSOrderedSet, context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        
        self.availableDate = availableDate
        self.bathroomCount = bathroomCount
        self.bedroomCount = Int64(bedroomCount)
        self.monthlyPayment = Int64(monthlyPayment)
        self.petFriendly = petFriendly
        self.smokingAllowed = smokingAllowed
        self.rentalHistoryRating = rentalHistoryRating
        self.address = address
        self.zipCode = zipCode
        self.profileImages = profileImages
    }
    
}
