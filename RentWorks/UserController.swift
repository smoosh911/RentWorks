//
//  UserController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class UserController {
    
    static var temporaryUserCreationDictionary = [String: Any]()
    
    static var userCreationPhotos = [UIImage]()
    
    static func addAttributeToUserDictionary(attribute: [UserDictionaryKeys: Any]) {
        guard let key = attribute.keys.first, let value = attribute.values.first else { return }
        temporaryUserCreationDictionary[key.rawValue] = value
    }
    
    
    static func createLandlord(completion: ((_ success: Bool) -> Void) = { _ in }) {
        AuthenticationController.checkFirebaseLoginStatus { (loggedIn) in
            FacebookRequestController.requestCurrentUsers(information: [.name, .email], completion: { (facebookDictionary) in
                _ = facebookDictionary?.flatMap({temporaryUserCreationDictionary[$0.0] = $0.1})
                print(temporaryUserCreationDictionary)
                
                
            })
        }
    }
}


extension UserController {
    
    // Renter/property creation enums

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
        case kBio = "bio"
    }
    
    
    enum PropertyType: String {
        case studio = "Studio"
        case oneBedroom = "One Bedroom"
        case twoBedrooms = "Two Bedrooms"
        case threePlusBedrooms = "Three-Plus Bedrooms"
    }
    
    enum PropertyFeatures: String {
        case laundry = "Laundry"
        case garage = "Garage"
        case pool = "Pool"
        case gym = "Gym"
        case dishwasher = "Dishwasher"
    }
    
    enum CreditRating: String {
        case a = "A"
        case b = "B"
        case c = "C"
        case d = "D"
    }
    
    enum MaritalStatus: String {
        case married = "Married"
        case single = "Single"
    }
}
