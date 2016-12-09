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
    
    @discardableResult convenience init?(availableDate: NSDate, bathroomCount: Double, bedroomCount: Int, monthlyPayment: Int, petFriendly: Bool, smokingAllowed: Bool, rentalHistoryRating: Double = 5.0, address: String, zipCode: String, propertyDescription: String = "No description yet!", propertyID: String, landlord: Landlord, context: NSManagedObjectContext? = CoreDataStack.context) {
        
        if let context = context {
            self.init(context: context)
        } else {
            self.init(entity: Property.entity(), insertInto: nil)
        }
        
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
    
    @discardableResult convenience init?(dictionary: [String: Any], landlordID: String? = nil, context: NSManagedObjectContext? = CoreDataStack.context) {
        
        guard let availableDate = dictionary[UserController.kAvailableDate] as? Double,
            let bathroomCount = dictionary[UserController.kBathroomCount] as? Double,
            let bedroomCount = dictionary[UserController.kBedroomCount] as? Double,
            let monthlyPayment = dictionary[UserController.kMonthlyPayment] as? Int,
            let petFriendly = dictionary[UserController.kPetsAllowed] as? Bool,
            let smokingAllowed = dictionary[UserController.kSmokingAllowed] as? Bool,
            let address = dictionary[UserController.kAddress] as? String,
            let zipCode = dictionary[UserController.kZipCode] as? String
            else { return nil }
        
        if let context = context {
            self.init(context: context)
        } else {
            self.init(entity: Property.entity(), insertInto: nil)
        }
        
        // TODO: - Change this to not a static value
        
        // needs work: this function is being repeated in code, refactor to static method
        if let hasBeenViewedBy = dictionary[UserController.kHasBeenViewedBy] as? [String: Bool] {
            let hasBeenViewedByIDs = Array(hasBeenViewedBy.keys)
            
            for id in hasBeenViewedByIDs {
                HasBeenViewedBy(hasBeenViewedByID: id, propertyOrRenter: self)
            }
        }
        
        // needs work: this function is being repeated in code, refactor to static method
        if let startAtVal = dictionary[UserController.kStartAt] as? String {
            self.startAt = startAtVal
        } else {
            RenterController.getFirstRenterID(completion: { (propertyID) in
                self.startAt = propertyID
            })
        }
        
        // needs work: should also grab landlord
        if let landlordID = dictionary[UserController.kLandlordID] as? String ?? landlordID {
            self.landlordID = landlordID
        }
        
        self.availableDate = NSDate(timeIntervalSince1970: availableDate)
        self.bathroomCount = bathroomCount
        self.bedroomCount = Int64(bedroomCount)
        self.monthlyPayment = Int64(monthlyPayment)
        self.petFriendly = petFriendly
        self.smokingAllowed = smokingAllowed
        self.rentalHistoryRating = dictionary[UserController.kStarRating] as? Double ?? 0.0
        self.address = address
        self.zipCode = zipCode
        self.propertyDescription = dictionary[UserController.kPropertyDescription] as? String ?? "No description yet!"
        guard let propertyID = dictionary[UserController.kPropertyID] as? String else { self.propertyID = UUID().uuidString; return}
        self.propertyID = propertyID
    }
    
    @discardableResult convenience init?(landlordID: String, landlord: Landlord, context: NSManagedObjectContext? = CoreDataStack.context) {
        
        self.init(entity: Property.entity(), insertInto: context)
        
        self.landlord = landlord
        self.availableDate = NSDate()
        self.bathroomCount = 1
        self.bedroomCount = 1
        self.monthlyPayment = 1500
        self.petFriendly = false
        self.smokingAllowed = false
        self.rentalHistoryRating = 0.0
        self.address = ""
        self.zipCode = ""
        self.landlordID = landlordID
        self.propertyDescription = "No description yet!"
        self.propertyID = UUID().uuidString
    }
}
