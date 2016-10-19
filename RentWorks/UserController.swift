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
    
    static func addAttributeToUserDictionary(attribute: [String: Any]) {
        guard let key = attribute.keys.first, let value = attribute.values.first else { return }
        temporaryUserCreationDictionary[key] = value
    }
    
    
    static func createLandlord(completion: ((_ success: Bool) -> Void) = { _ in }) {
        AuthenticationController.checkFirebaseLoginStatus { (loggedIn) in
            FacebookRequestController.requestCurrentUsers(information: [.first_name, .last_name, .email], completion: { (facebookDictionary) in
                _ = facebookDictionary?.flatMap({temporaryUserCreationDictionary[$0.0] = $0.1})
                guard let landlord = Landlord(dictionary: temporaryUserCreationDictionary) else { NSLog("Landlord could not be initialized from dictionary"); return }
                saveToPersistentStore()
                createLandlordInFirebase(landlord: landlord, completion: { 
                    
                })
                
                
                
            })
        }
    }
    
    static func createLandlordInFirebase(landlord: Landlord, completion: () -> Void) {
        guard let id = landlord.id else { return }
        FirebaseController.allUsersRef.child("landlords").child(id).setValue(landlord.dictionaryRepresentation)
    }
    
    static func saveToPersistentStore() {
        let moc = CoreDataStack.context
        
        do {
            try moc.save()
        } catch {
            NSLog("Error saving to the managed object context \(error.localizedDescription)")
        }
        
    }
    
    
}


extension UserController {
    
    // User/property keys
    
    
    static let kAddress = "address"
    static let kZipCode = "zipCode"
    static let kBedroomCount = "bedroomCount"
    static let kBathroomCount = "bathroomCount"
    static let kPetsAllowed = "petsAllowed"
    static let kSmokingAllowed = "smokingAllowed"
    static let kMonthlyPayment = "monthlyPayment"
    static let kAvailableDate = "availableDate"
    static let kPropertyType = "propertyType"
    static let kPropertyFeatures = "propertyFeatures"
    static let kPropertyDescription = "propertyDescription"
    static let kStarRating = "starRating"
    static let kID = "id"
    
    static let kFirstName = "first_name"
    static let kLastName = "last_name"
    static let kCreditRating = "creditRating"
    static let kEmail = "email"
    static let kMaritalStatus = "maritalStatus"
    static let kAdultCount = "adultCount"
    static let kChildCount = "childCount"
    static let kBio = "bio"
    
    
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
