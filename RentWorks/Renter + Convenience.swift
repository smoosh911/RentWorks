//
//  Renter + Convenience.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import CoreData

extension Renter {
    
    convenience init?(address: String, birthday: NSDate = NSDate(), firstName: String, lastName: String, starRating: Double, id: String, creditRating: String, email: String, wantedPropertyFeatures: String, wantsPetFriendly: Bool, wantsSmoking: Bool, wantedBedroomCount: Int64, wantedBathroomCount: Double, wantedPayment: Int64, wantedZipCode: String, maritalStatus: String, bio: String, context: NSManagedObjectContext = CoreDataStack.context) {
        
        self.init(context: context)
        
        
        self.address = address
        self.birthday = birthday
        self.firstName = firstName
        self.lastName = lastName
        self.starRating = starRating
        self.id = id
        self.creditRating = creditRating
        self.email = email
        self.wantedPropertyFeatures = wantedPropertyFeatures
        self.wantsPetFriendly = wantsPetFriendly
        self.wantsSmoking = wantsSmoking
        self.wantedBedroomCount = wantedBedroomCount
        self.wantedBathroomCount = wantedBathroomCount
        self.wantedPayment = wantedPayment
        self.wantedZipCode = wantedZipCode
        self.maritalStatus = maritalStatus
        self.bio = bio
    }
    
}
