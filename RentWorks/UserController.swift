//
//  UserController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import CoreData
import FirebaseStorage

class UserController {
    
    // MARK: - User creation properties and functions
    
    static var temporaryUserCreationDictionary = [String: Any]()
    
    static var userCreationPhotos = [UIImage]()
    
    static var userCreationType = ""
    
    static var currentRenter: Renter?
    
    static var currentLandlord: Landlord?
    
    static var currentUserID: String?
    
    static var currentUserType: String?
    
    static func addAttributeToUserDictionary(attribute: [String: Any]) {
        guard let key = attribute.keys.first, let value = attribute.values.first else { return }
        temporaryUserCreationDictionary[key] = value
    }
    
    
    // This function should be used when there is not a managed object matching their Facebook ID to see if they have already created an account. If so, it will pull their information and save it into Core Data so this doesn't have to be done every launch.
    
    static func fetchLoggedInUserFromFirebase(completion: @escaping (User?) -> Void) {
        
        FirebaseController.checkForExistingUserInformation { (hasAccount, userType) in
            guard let currentUserID = currentUserID else { completion(nil); return }
            if userType == "renter" {
                self.fetchRenterFromFirebaseFor(renterID: currentUserID, completion: { (renter) in
                    self.currentRenter = renter
                    self.currentUserType = "renter"
                    completion(renter)
                })
            } else if userType == "landlord" {
                self.fetchLandlordFromFirebaseFor(landlordID: currentUserID, completion: { (landlord) in
                    self.currentLandlord = landlord
                    self.currentUserType = "landlord"
                    completion(landlord)
                })
            } else {
                completion(nil)
                print("Error: \(userType)")
            }
        }
    }
    
    
    
    // MARK: - Landlord functions
    
    static func createLandlordAndPropertyForCurrentUser(completion: @escaping (() -> Void)) {
        createLandlordForCurrentUser { (landlord) in
            guard let landlord = landlord else { print("Landlord returned from completion closure is nil"); return }
            createLandlordInFirebase(landlord: landlord, completion: {
                createPropertyInCoreDataFor(landLord: landlord, completion: { (property) in
                    guard let property = property else { print("Error creating property"); return }
                    savePropertyImagesToCoreDataAndFirebase(images: userCreationPhotos, landlord: landlord, forProperty: property, completion: {
                        createPropertyInFirebase(property: property) {
                            completion()
                        }
                    })
                })
            })
        }
    }
    
    static func getCurrentLandlordFromCoreData(completion: @escaping (_ landlordExists: Bool) -> Void) {
        let request: NSFetchRequest<Landlord> = Landlord.fetchRequest()
        
        
        guard let landlords = try? CoreDataStack.context.fetch(request) else { completion(false); return }
        
        guard let id = UserController.currentUserID else { completion(false); return }
        let currentLandlordArray = landlords.filter({$0.id == id})
        guard let currentLandlord = currentLandlordArray.first else { completion(false); return }
        self.currentLandlord = currentLandlord
        self.currentUserType = "landlord"
        completion(true)
        
    }
    
    static func createLandlordForCurrentUser(completion: @escaping ((_ landlord: Landlord?) -> Void) = { _ in }) {
        AuthenticationController.checkFirebaseLoginStatus { (loggedIn) in
            FacebookRequestController.requestCurrentUsers(information: [.first_name, .last_name, .email], completion: { (facebookDictionary) in
                _ = facebookDictionary?.flatMap({temporaryUserCreationDictionary[$0.0] = $0.1})
                guard let landlord = Landlord(dictionary: temporaryUserCreationDictionary) else { NSLog("Landlord could not be initialized from dictionary"); completion(nil); return }
                saveToPersistentStore()
                completion(landlord)
            })
        }
    }
    
    static func createLandlordInFirebase(landlord: Landlord, completion: @escaping () -> Void) {
        guard let id = landlord.id, let dict = landlord.dictionaryRepresentation else { completion(); return }
        
        let landlordRef = FirebaseController.landlordsRef.child(id)
        landlordRef.setValue(dict) { (error, reference) in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                completion()
            }
        }
    }
    static func createLandlordMockInFirebase(id: String, dictionary: [String: Any]) {
        FirebaseController.landlordsRef.child(id).setValue(dictionary)
    }
    
    // MARK: - Property Functions
    
    static func createPropertyInCoreDataFor(landLord: Landlord, completion: @escaping (_ property: Property?) -> Void) {
        let prop = Property(dictionary: temporaryUserCreationDictionary)
        guard let property = prop else { NSLog("Property could not be initialized from dictionary"); completion(nil); return }
        property.landlord = landLord
        saveToPersistentStore()
        completion(property)
    }
    
    static func createPropertyInFirebase(property: Property, completion: @escaping () -> Void) {
        guard let landlord = property.landlord,
            let landlordID = landlord.id, let propertyID = property.propertyID, let dict = property.dictionaryRepresentation else { completion(); return }
        
        let propertyRef = FirebaseController.propertiesRef.child(landlordID).child(propertyID)
        propertyRef.setValue(dict) { (error, reference) in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                completion()
            }
        }
    }
    
    static func savePropertyImagesToCoreDataAndFirebase(images: [UIImage], landlord: Landlord, forProperty property: Property, completion: @escaping () -> Void) {
        var count = 0
        
        guard let landlordID = landlord.id else { return }
        let group = DispatchGroup()
        for image in images {
            count += 1
            group.enter()
            FirebaseController.store(profileImage: image, forUserID: landlordID, and: property, with: count, completion: { (metadata, error, imageData) in
                guard error == nil else { print(error?.localizedDescription); completion(); return }
                print("Successfully uploaded image")
                
                guard let imageData = imageData, let imageURL = metadata?.downloadURL()?.absoluteString else { completion(); return }
                // Print imageURL in console
                
                _ = ProfileImage(userID: landlordID, imageData: imageData as NSData, renter: nil, property: property, imageURL: imageURL)
                saveToPersistentStore()
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
    }
    
    static func fetchLandlordFromFirebaseFor(landlordID: String, insertInto context: NSManagedObjectContext? = CoreDataStack.context, completion: @escaping (Landlord?) -> Void) {
        
        FirebaseController.landlordsRef.child(landlordID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let landlordDictionary = snapshot.value as? [String: Any], let landlord = Landlord(dictionary: landlordDictionary, context: context) else { completion(nil); return }
            
            FirebaseController.propertiesRef.child(landlordID).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let propertyDictionary = snapshot.value as? [String: [String: Any]] else { return }
                
                let properties = propertyDictionary.flatMap({Property(dictionary: $0.value, context: context)})
                let group = DispatchGroup()
                
                for property in properties {
                    group.enter()
                    downloadAndAddImagesFor(property: property, completion: { (_) in
                        group.leave()
                    })
                    
                }
                group.notify(queue: DispatchQueue.main, execute: {
                    for property in properties { property.landlord = landlord }
                    
                    completion(landlord)
                })
            })
        })
    }
    
    
    
    
    
    static func downloadAndAddImagesFor(property: Property, completion: @escaping (_ success: Bool) -> Void) {
        guard let propertyProfileImages = property.profileImages?.array as? [ProfileImage] else { return }
        let profileImageURLs = propertyProfileImages.flatMap({$0.imageURL})
        
        let group = DispatchGroup()
        
        for imageURL in profileImageURLs {
            group.enter()
            let imageRef = FIRStorage.storage().reference(forURL: imageURL)
            
            imageRef.data(withMaxSize: 2 * 1024 * 1024) { (imageData, error) in
                guard let imageData = imageData, error == nil, let propertyID = property.propertyID else { group.leave(); completion(false); return }
                
                _ = ProfileImage(userID: propertyID, imageData: imageData as NSData, renter: nil, property: property)
                
                UserController.saveToPersistentStore()
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(true)
        }
    }
    
    
    
    // MARK: - Renter functions
    
    static func getCurrentRenterFromCoreData(completion: @escaping (_ renterExists: Bool) -> Void) {
        let request: NSFetchRequest<Renter> = Renter.fetchRequest()
        
        guard let renters = try? CoreDataStack.context.fetch(request) else { completion(false); return }
        
            guard let id = UserController.currentUserID else { completion(false); return }
            let currentRenterArray = renters.filter({$0.id == id})
            guard let currentRenter = currentRenterArray.first else { completion(false); return }
            self.currentRenter = currentRenter
            self.currentUserType = "renter"
            completion(true)
        
    }
    
    
    static func createRenterForCurrentUser(completion: @escaping () -> Void) {
        self.createRenterInCoreDataForCurrentUser { (renter) in
            guard let renter = renter else { print("Renter returned in completion closure is nil"); return }
            self.saveRenterProfileImagesToCoreDataAndFirebase(forRenter: renter, completion: {
                self.createRenterInFirebase(renter: renter, completion: {
                    completion()
                })
            })
        }
    }
    
    static func createRenterInCoreDataForCurrentUser(completion: @escaping ((_ renter: Renter?) -> Void) = { _ in }) {
        AuthenticationController.checkFirebaseLoginStatus { (loggedIn) in
            FacebookRequestController.requestCurrentUsers(information: [.first_name, .last_name, .email], completion: { (facebookDictionary) in
                _ = facebookDictionary?.flatMap({temporaryUserCreationDictionary[$0.0] = $0.1})
                guard let renter = Renter(dictionary: temporaryUserCreationDictionary) else { NSLog("Renter could not be initialized from dictionary"); completion(nil); return }
                saveToPersistentStore()
                completion(renter)
            })
        }
    }
    
    
    static func createRenterInFirebase(renter: Renter, completion: @escaping () -> Void) {
        guard let dict = renter.dictionaryRepresentation, let renterID = renter.id else { completion(); return }
        
        let propertyRef = FirebaseController.rentersRef.child(renterID)
        propertyRef.setValue(dict) { (error, reference) in
            if error != nil {
                print(error?.localizedDescription)
                completion()
            } else {
                completion()
            }
        }
    }
    
    static func fetchRenterFromFirebaseFor(renterID: String, andInsertInto context: NSManagedObjectContext? = CoreDataStack.context, completion: @escaping (Renter?) -> Void) {
        
        FirebaseController.rentersRef.child(renterID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let renterDictionary = snapshot.value as? [String: Any], let renter = Renter(dictionary: renterDictionary, context: context), let imageURLs = renterDictionary[UserController.kImageURLS] as? [String] else { completion(nil); return }
            
            
            FirebaseController.downloadAndAddImagesFor(renter: renter, insertInto: context, profileImageURLs: imageURLs, completion: { (success) in
                if success {
                    completion(renter)
                } else {
                    completion(renter)
                }
            })
        })
        
    }
    
    
    
    
    static func saveRenterProfileImagesToCoreDataAndFirebase(forRenter renter: Renter, completion: @escaping () -> Void) {
        var count = 0
        
        FacebookRequestController.requestImageForCurrentUserWith(height: 1080, width: 1080) { (image) in
            guard let image = image, let renterID = renter.id else { return }
            userCreationPhotos.append(image)
            
            let group = DispatchGroup()
            
            for image in userCreationPhotos {
                group.enter()
                count += 1
                FirebaseController.store(profileImage: image, forUserID: renterID, with: count, completion: { (metadata, error, imageData) in
                    guard let imageData = imageData, let imageURL = metadata?.downloadURL()?.absoluteString, error == nil else { print(error?.localizedDescription); group.leave(); return }
                    print("Successfully uploaded image")
                    _ = ProfileImage(userID: renterID, imageData: imageData as NSData, renter: renter, property: nil, imageURL: imageURL)
                    group.leave()
                })
            }
            group.notify(queue: DispatchQueue.main) {
                completion()
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
    
    static let kImageURLS = "images"
    
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
