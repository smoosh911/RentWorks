//  UserController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import CoreData
import FirebaseStorage
import Firebase

class UserController {
    
    // MARK: - User creation properties and functions
    
    static var temporaryUserCreationDictionary: [String: Any] = [String: Any]()
    
    static var userCreationPhotos: [UIImage] = [UIImage]() {
        didSet {
            if userCreationPhotos.count == 1 {
                photoSelectedDelegate?.photoWasSelected()
            }
        }
    }
    
    static var canPage = false
    
    static var userCreationType = ""
    
    static var currentUserID: String?
    
    static var currentUserType: String?
    
    static var propertyCount: Int = 0
    
    static var fetchCount = 0
    
    static var propertyFetchCount = 0
    
    // needs work: there should be a different renterfetchcount for each property instead of sharing it
    static var renterFetchCount = 0
    
//    static var previousStartAt = ""
    
//    static var currentUserHasBeenViewedByIDs: [String] = []
    
    static var currentRenter: Renter?
    
    static var currentLandlord: Landlord?
    
    static weak var photoSelectedDelegate: PhotoSelectedDelegate?
    
    static func addAttributeToUserDictionary(attribute: [String: Any]) {
        guard let key = attribute.keys.first, let value = attribute.values.first else { return }
        temporaryUserCreationDictionary[key] = value
    }
    
    // This function should be used when there is not a managed object matching their Facebook ID to see if they have already created an account. If so, it will pull their information and save it into Core Data so this doesn't have to be done every launch.
    
    static func fetchLoggedInUserFromFirebase(completion: @escaping (User?) -> Void) {
        
        FirebaseController.checkForExistingUserInformation { (hasAccount, userType) in
            
            guard let currentUserID = currentUserID else { completion(nil); return }
            if userType == "renter" {
                UserController.userCreationType = UserController.UserCreationType.renter.rawValue
                RenterController.fetchRenterFromFirebaseFor(renterID: currentUserID, completion: { (renter) in
                    self.currentRenter = renter
                    self.currentUserType = "renter"
                    completion(renter)
                })
            } else if userType == "landlord" {
                UserController.userCreationType = UserController.UserCreationType.landlord.rawValue
                LandlordController.fetchLandlordFromFirebaseFor(landlordID: currentUserID, completion: { (landlord) in
                    self.currentLandlord = landlord
                    self.currentUserType = "landlord"
                    completion(landlord)
                })
            } else {
                completion(nil)
                log("Error: \(userType)")
                //                print("Error: \(userType)")
            }
        }
    }
    
    // MARK: - Persistence
    
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
    
    // MARK: - User/Property keys and enums
    
    static let kUserType = "userType"
    static let kAddress = "address"
    static let kZipCode = "zipCode"
    static let kCity = "city"
    static let kState = "state"
    static let kCountry = "country"
    static let kBedroomCount = "bedroomCount"
    static let kBathroomCount = "bathroomCount"
    static let kPetsAllowed = "petsAllowed"
    static let kSmokingAllowed = "smokingAllowed"
    static let kMonthlyPayment = "monthlyPayment"
    static let kAvailableDate = "availableDate"
    static let kPropertyType = "propertyType"
    static let kPropertyDescription = "propertyDescription"
    static let kStarRating = "starRating"
    static let kID = "id"
    static let kLandlordID = "landlordID"
    static let kPropertyID = "propertyID"
    
    static let kWasherDryer = "washerDryer"
    static let kGarage = "garage"
    static let kDishwasher = "dishwasher"
    static let kBackyard = "backyard"
    static let kPool = "pool"
    static let kGym = "gym"
    
    static let kImageURLS = "images"
    
    static let kFirstName = "first_name"
    static let kLastName = "last_name"
    static let kWantsCreditRating = "wants_credit_rating"
    static let kCreditRating = "creditRating"
    static let kEmail = "email"
    static let kMaritalStatus = "maritalStatus"
    static let kAdultCount = "adultCount"
    static let kChildCount = "childCount"
    static let kBio = "bio"
//    static let kHasViewed = "hasViewed"
    static let kHasBeenViewedBy = "hasBeenViewedBy"
    static let kOccupationHistory = "work"
    static let kCurrentOccupation = "currentOccupation"
    
    static let kWithinRangeMiles = "within_range_miles"
    
    static let kStartAt = "startAt"
    
    enum RenterDetails: String {
        case kBio = "bio"
        case kMaritalStatus = "maritalStatus"
        case kPetsAllowed = "petsAllowed"
        case kSmokingAllowed = "smokingAllowed"
        static let allValues: [RenterDetails] = [kBio, kMaritalStatus, kPetsAllowed, kSmokingAllowed]
    }
    
    enum RenterFilters: String {
        case kAvailableDate = "availableDate"
        case kBathroomCount = "bathroomCount"
        case kBedroomCount = "bedroomCount"
        case kMonthlyPayment = "monthlyPayment"
        case kPetsAllowed = "petsAllowed"
        case kSmokingAllowed = "smokingAllowed"
        case kZipCode = "zipCode"
        case kCity = "city"
        case kState = "state"
        case kCurrentOccupation = "currentOccupation"
        case kWithinRangeMiles = "within_range_miles"
        static let allValues: [RenterFilters] = [kAvailableDate, kBathroomCount, kBedroomCount, kMonthlyPayment, kPetsAllowed, kSmokingAllowed, kZipCode, kCity, kState, kCurrentOccupation, kWithinRangeMiles]
    }
    
    enum LandlordFilters: String {
        case kWantsCreditRating = "wants_credit_rating"
        case kWithinRangeMiles = "within_range_miles"
        static let allValues: [LandlordFilters] = [kWantsCreditRating, kWithinRangeMiles]
    }
    
    enum PropertyDetailValues: String {
        case kPropertyDescription = "propertyDescription"
        case kAddress = "address"
        case kAvailableDate = "availableDate"
        case kBathroomCount = "bathroomCount"
        case kBedroomCount = "bedroomCount"
        case kMonthlyPayment = "monthlyPayment"
        case kPetsAllowed = "petsAllowed"
        case kSmokingAllowed = "smokingAllowed"
        case kStarRating = "starRating"
        case kZipCode = "zipCode"
        case kCity = "city"
        case kState = "state"
        case kCountry = "country"
        case kWasherDryer = "washerDryer"
        case kGarage = "garage"
        case kDishwasher = "dishwasher"
        case kBackyard = "backyard"
        case kPool = "pool"
        case kGym = "gym"
        static let allValues: [PropertyDetailValues] = [kPropertyDescription, kAddress, kAvailableDate, kBathroomCount, kBedroomCount, kMonthlyPayment, kPetsAllowed, kSmokingAllowed, kStarRating, kZipCode, kCity, kState, kCountry,kWasherDryer, kGarage, kDishwasher, kBackyard, kPool, kGym]
    }
    
    enum PropertyType: String {
        case studio = "Studio"
        case oneBedroom = "One Bedroom"
        case twoBedrooms = "Two Bedrooms"
        case threePlusBedrooms = "Three-Plus Bedrooms"
    }
    
    enum CreditRating: String {
        case a = "A+"
        case b = "A"
        case c = "B"
        case d = "Other"
    }
    
    enum MaritalStatus: String {
        case married = "Married"
        case single = "Single"
    }
    
    enum UserCreationType: String {
        case landlord = "landlord"
        case renter = "renter"
    }
}

protocol PhotoSelectedDelegate: class {
    func photoWasSelected()
}
