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
    
    @discardableResult convenience init?(availableDate: NSDate, bathroomCount: Double, bedroomCount: Int, monthlyPayment: Int, petFriendly: Bool, smokingAllowed: Bool, rentalHistoryRating: Double = 5.0, address: String, zipCode: String, propertyDescription: String = "", propertyID: String, landlord: Landlord, context: NSManagedObjectContext = CoreDataStack.context) {
        
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
        self.propertyDescription = propertyDescription
        self.landlord = landlord
        self.propertyID = propertyID
    }
    
    @discardableResult convenience init?(dictionary: [String: Any], context: NSManagedObjectContext = CoreDataStack.context) {
        
        guard let availableDate = dictionary[UserController.kAvailableDate] as? Date,
            let bathroomCount = dictionary[UserController.kBathroomCount] as? Double,
            let bedroomCount = dictionary[UserController.kBedroomCount] as? Int,
            let monthlyPayment = dictionary[UserController.kMonthlyPayment] as? Int,
            let petFriendly = dictionary[UserController.kPetsAllowed] as? Bool,
            let smokingAllowed = dictionary[UserController.kSmokingAllowed] as? Bool,
            let address = dictionary[UserController.kAddress] as? String,
            let zipCode = dictionary[UserController.kZipCode] as? String,
            let propertyDescription = dictionary[UserController.kPropertyDescription] as? String,
            let propertyID = dictionary[UserController.kPropertyID] as? String else { return nil }
        
        self.init(context: context)
        // TODO: - Change this to not a static value
        let rentalHistoryRating = 5.0
        
        self.availableDate = availableDate as NSDate?
        self.bathroomCount = bathroomCount
        self.bedroomCount = Int64(bedroomCount)
        self.monthlyPayment = Int64(monthlyPayment)
        self.petFriendly = petFriendly
        self.smokingAllowed = smokingAllowed
        self.rentalHistoryRating = rentalHistoryRating
        self.address = address
        self.zipCode = zipCode
        self.propertyDescription = propertyDescription
        self.propertyID = propertyID
    }
}
