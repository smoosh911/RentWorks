//
//  UserController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import CoreData

class UserController {
    
    // MARK: - User creation properties and functions
    
    static var temporaryUserCreationDictionary = [String: Any]()
    
    static var userCreationPhotos = [UIImage]()
    
    static var currentRenter: Renter?
    
    static var currentLandlord: Landlord?
    
    
    static func addAttributeToUserDictionary(attribute: [String: Any]) {
        guard let key = attribute.keys.first, let value = attribute.values.first else { return }
        temporaryUserCreationDictionary[key] = value
    }
    
    // MARK: - Landlord functions
    
    static func getCurrentLandlordFromCoreData() {
        let request: NSFetchRequest<Landlord> = Landlord.fetchRequest()
        
        
        guard let landlords = try? CoreDataStack.context.fetch(request) else { return }
        FacebookRequestController.requestCurrentFacebookUserID { (id) in
            guard let id = id else { return }
            let currentLandlordArray = landlords.filter({$0.id == id})
            guard let currentLandlord = currentLandlordArray.first else { return }
            self.currentLandlord = currentLandlord
        }
    }
    static func createLandlordForCurrentUser(completion: @escaping ((_ success: Bool) -> Void) = { _ in }) {
        AuthenticationController.checkFirebaseLoginStatus { (loggedIn) in
            FacebookRequestController.requestCurrentUsers(information: [.first_name, .last_name, .email], completion: { (facebookDictionary) in
                _ = facebookDictionary?.flatMap({temporaryUserCreationDictionary[$0.0] = $0.1})
                guard let landlord = Landlord(dictionary: temporaryUserCreationDictionary) else { NSLog("Landlord could not be initialized from dictionary"); return }
                saveToPersistentStore()
                createLandlordInFirebase(landlord: landlord, completion: {
                    completion(true)
                })
            })
        }
    }
    
    static func createLandlordInFirebase(landlord: Landlord, completion: () -> Void) {
        guard let id = landlord.id else { return }
        let landlordRef = FirebaseController.allUsersRef.child("landlords").child(id)
        landlordRef.setValue(landlord.dictionaryRepresentation)
    }
    
    // MARK: - Property Functions
    
    static func createPropertyFor(landLord: Landlord, completion: @escaping ((_ success: Bool) -> Void) = { _ in }) {
        
        guard let property = Property(dictionary: temporaryUserCreationDictionary) else { NSLog("Property could not be initialized from dictionary"); completion(false); return }
        property.landlord = landLord
        saveToPersistentStore()
        createPropertyInFirebase(property: property) {
            savePropertyImagesToCoreDataAndFirebase(images: userCreationPhotos, landlord: landLord, forProperty: property, completion: {
                completion(true)
            })
            
        }
        
        
    }
    
    static func createPropertyInFirebase(property: Property, completion: () -> Void) {
        guard let landlord = property.landlord, let landlordID = landlord.id, let propertyID = property.propertyID else { completion(); return }
        
        let propertyRef = FirebaseController.allUsersRef.child("landlords").child(landlordID).child(propertyID)
        propertyRef.setValue(property.dictionaryRepresentation)
        
    }
    
    
    static func savePropertyImagesToCoreDataAndFirebase(images: [UIImage], landlord: Landlord, forProperty property: Property, completion: () -> Void) {
        var count = 0
        
        guard let landlordID = landlord.id else { return }
        images.forEach { (image) in
            count += 1
            FirebaseController.store(profileImage: image, forUserID: landlordID, and: property, with: count, completion: { (metadata, error) in
                guard error == nil else { print(error?.localizedDescription); return }
                print("Successfully uploaded image")
            })
        }
    }
    
    // MARK: - Renter functions
    
    static func getCurrentRenterFromCoreData() {
        let request: NSFetchRequest<Renter> = Renter.fetchRequest()
        
        guard let renters = try? CoreDataStack.context.fetch(request) else { return }
        FacebookRequestController.requestCurrentFacebookUserID { (id) in
            guard let id = id else { return }
            let currentRenterArray = renters.filter({$0.id == id})
            guard let currentRenter = currentRenterArray.first else { return }
            self.currentRenter = currentRenter
        }
    }
    
    static func createRenterForCurrentUser(completion: ((_ success: Bool) -> Void) = { _ in }) {
        
    }
    
    
    
    static func createRenterInFirebase(renter: Renter, completion: () -> Void) {
        guard let id = renter.id else { return }
        FirebaseController.allUsersRef.child("renters").child(id).setValue(renter.dictionaryRepresentation)
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
    static let kPropertyID = "propertyID"
    
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
