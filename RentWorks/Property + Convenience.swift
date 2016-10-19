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
    
    enum UserDictionaryKeys: String {
        case kAddress = "address"
        case kZipCode = "zipCode"
        case kBedroomCount = "bedroomCount"
        case kBathroomCount = "bathroomCount"
        case kPetsAllowed = "petsAllowed"
        case kSmokingAllowed = "smokingAllowed"
        case kMonthlyPayment = "monthlyPayment"
        case kAvailableDate = "availableDate"
        case kPropertyType = "propertyType"
        case kPropertyFeatures = "propertyFeatures"
        case kPropertyDescription = "propertyDescription"
        
        case kFirstName = "firstName"
        case kLastName = "lastName"
        case kCreditRating = "creditRating"
        case kEmail = "email"
        case kMaritalStatus = "maritalStatus"
        case kAdultCount = "adultCount"
        case kChildCount = "childCount"
    }
    
    
    @discardableResult convenience init?(availableDate: NSDate, bathroomCount: Double, bedroomCount: Int, monthlyPayment: Int, petFriendly: Bool, smokingAllowed: Bool, rentalHistoryRating: Double = 5.0, address: String, zipCode: String, propertyDescription: String, context: NSManagedObjectContext = CoreDataStack.context) {
        
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
    }
    
    @discardableResult convenience init?(dictionary: [String: Any], context: NSManagedObjectContext = CoreDataStack.context) {
        
        guard let availableDate = dictionary[UserDictionaryKeys.kAvailableDate.rawValue] as? Date,
            let bathroomCount = dictionary[UserDictionaryKeys.kBathroomCount.rawValue] as? Double,
            let bedroomCount = dictionary[UserDictionaryKeys.kBedroomCount.rawValue] as? Int,
            let monthlyPayment = dictionary[UserDictionaryKeys.kMonthlyPayment.rawValue] as? Int,
            let petFriendly = dictionary[UserDictionaryKeys.kPetsAllowed.rawValue] as? Bool,
            let smokingAllowed = dictionary[UserDictionaryKeys.kSmokingAllowed.rawValue] as? Bool,
            let address = dictionary[UserDictionaryKeys.kAddress.rawValue] as? String,
            let zipCode = dictionary[UserDictionaryKeys.kZipCode.rawValue] as? String,
            let propertyDescription = dictionary[UserDictionaryKeys.kPropertyDescription.rawValue] as? String else { return nil }
        
        self.init(context: context)
        
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
    }
}
