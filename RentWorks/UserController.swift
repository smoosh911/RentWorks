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
    
    static var temporaryUserCreationDictionary = [String: Any]()
    
    static var userCreationPhotos = [UIImage]() {
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
                self.fetchRenterFromFirebaseFor(renterID: currentUserID, completion: { (renter) in
                    self.currentRenter = renter
                    self.currentUserType = "renter"
                    completion(renter)
                })
            } else if userType == "landlord" {
                UserController.userCreationType = UserController.UserCreationType.landlord.rawValue
                self.fetchLandlordFromFirebaseFor(landlordID: currentUserID, completion: { (landlord) in
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
    
    // MARK: - Landlord functions
    
    static func getLandlordsFiltersDictionary() -> [String: Any] {
        var filterDict = [String: Any]()
        guard let landlord = UserController.currentLandlord?.dictionaryRepresentation else {
            log("ERROR: renter is nil")
            return filterDict
        }
        
        for filter in UserController.LandlordFilters.allValues {
            let filterString = filter.rawValue
            filterDict[filterString] = landlord[filterString]
        }
        
        return filterDict
    }
    
    static func eraseAllHasBeenViewedByForLandlordFromRenters(landlordID: String, completion: @escaping () -> Void) {
        FirebaseController.rentersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allRentersDict = snapshot.value as? [String: [String: Any]] else { return }
            
            let rentersArray = allRentersDict.flatMap({Renter(dictionary: $0.value)})
            
            for renter in rentersArray {
                FirebaseController.rentersRef.child(renter.id!).child(UserController.kHasBeenViewedBy).child(landlordID).removeValue()
            }
            completion()
        })
    }

//    static func updateStartAtForLandlordInFirebase(landlordID: String, newStartAt: String) {
//        FirebaseController.landlordsRef.child(landlordID).child(UserController.kStartAt).setValue(newStartAt)
//    }
    
    static func createLandlordAndPropertyForCurrentUser(completion: @escaping (() -> Void)) {
        createLandlordForCurrentUser { (landlord) in
            guard let landlord = landlord else {
                log("Landlord nil")
                //                print("Landlord returned from completion closure is nil");
                return
            }
            createLandlordInFirebase(landlord: landlord, completion: {
                createPropertyInCoreDataFor(landlord: landlord, completion: { (property) in
                    guard let property = property else { print("Error creating property"); return }
                    savePropertyImagesToCoreDataAndFirebase(images: userCreationPhotos, landlord: landlord, forProperty: property, completion: {_ in
                        createPropertyInFirebase(property: property) { success in
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
    
    static func updateCurrentLandlordInFirebase(id: String, attributeToUpdate: String, newValue: Any) {
        FirebaseController.landlordsRef.child(id).child(attributeToUpdate).setValue(newValue)
    }
    
    static func createLandlordForCurrentUser(completion: @escaping ((_ landlord: Landlord?) -> Void) = { _ in }) {
        AuthenticationController.checkFirebaseLoginStatus { (loggedIn) in
            FacebookRequestController.requestCurrentUsers(information: [.first_name, .last_name, .email], completion: { (facebookDictionary) in
//                _ = facebookDictionary?.flatMap({temporaryUserCreationDictionary[$0.0] = $0.1})
//                var landlordDict = temporaryUserCreationDictionary
//                landlordDict.removeValue(forKey: "availableDate")
//                landlordDict.removeValue(forKey: "propertyFeatures")
                let id = facebookDictionary?[kID] as? String
                getFirstRenterID(completion: { (renterID) in
//                    temporaryUserCreationDictionary[UserController.kStartAt] = renterID
                    guard let landlord = Landlord(dictionary: facebookDictionary!, id: id) else { print("Landlord could not be initialized from dictionary"); completion(nil); return }
                    UserController.currentLandlord = landlord
                    completion(landlord)
                })
            })
        }
    }
    
    static func fetchLandlordFromFirebaseFor(landlordID: String, insertInto context: NSManagedObjectContext? = CoreDataStack.context, completion: @escaping (Landlord?) -> Void) {
        
        FirebaseController.landlordsRef.child(landlordID).observeSingleEvent(of: .value, with: { (snapshot) in
            getFirstRenterID(completion: { (renterID) in
                guard var landlordDictionary = snapshot.value as? [String: Any] else { log("couldn't create landlord"); completion(nil); return }
//                landlordDictionary[UserController.kStartAt] = renterID
                guard let landlord = Landlord(dictionary: landlordDictionary, id: landlordID, context: context) else { log("couldn't create landlord"); completion(nil); return }
                
                FirebaseController.propertiesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    // At this point, it pull all properties
                    guard let propertyDictionary = snapshot.value as? [String: [String: Any]] else { return }
                    
                    let allProperties = propertyDictionary.flatMap({Property(dictionary: $0.value, context: context)})
                    let landlordProperties = allProperties.filter({$0.landlordID == landlordID})
                    let group = DispatchGroup()
                    
                    for property in landlordProperties {
                        group.enter()
                        downloadAndAddImagesFor(property: property, completion: { (_) in
                            group.leave()
                        })
                        
                    }
                    group.notify(queue: DispatchQueue.main, execute: {
                        for property in landlordProperties { property.landlord = landlord }
                        
                        completion(landlord)
                    })
                })
            })
        })
    }
    
    static func createLandlordInFirebase(landlord: Landlord, completion: @escaping () -> Void) {
        guard let id = landlord.id, let dict = landlord.dictionaryRepresentation else { completion(); return }
        
        let landlordRef = FirebaseController.landlordsRef.child(id)
        landlordRef.setValue(dict) { (error, reference) in
            if let error = error {
                print(error.localizedDescription)
                completion()
            } else {
                completion()
            }
        }
    }
    
    // MARK: - Property Functions
    
    // needs work: user getfirstRenter func
    static func resetStartAtForPropertyInFirebase(property: Property) {
        guard let propertyID = property.propertyID else { return }
        FirebaseController.rentersRef.queryOrderedByKey().queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let child = snapshot.children.nextObject() as? FIRDataSnapshot else { log("renter nil"); return }
            let key = child.key
            FirebaseController.propertiesRef.child(propertyID).child(UserController.kStartAt).setValue(key)
            property.startAt = key
        })
    }
    
    // needs work: user getfirstRenter func
    static func resetStartAtForAllPropertiesInFirebase() {
        guard let landlord = currentLandlord, let landlordID = landlord.id else { return }
        FirebaseController.propertiesRef.queryOrdered(byChild: UserController.kLandlordID).queryEqual(toValue: landlordID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let children = snapshot.children.allObjects as? [FIRDataSnapshot] else { log("properties nil"); return }
            FirebaseController.rentersRef.queryOrderedByKey().queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let renterChild = snapshot.children.nextObject() as? FIRDataSnapshot else { log("renter nil"); return }
                let key = renterChild.key
                for child in children {
                    let propertyID = child.key
                    let properties = FirebaseController.properties
                    if let property = properties.filter({$0.propertyID == propertyID}).first {
                        FirebaseController.propertiesRef.child(propertyID).child(UserController.kStartAt).setValue(key)
                        property.startAt = key
                    }
                }
            })
        })
    }
    
    static func deletePropertyInFirebase(propertyID: String) {
        FirebaseController.propertiesRef.child(propertyID).removeValue()
    }
    
    static func getLastPropertyIDInFirebase(completion: @escaping (_ lastPropertyID: String) -> Void) {
        FirebaseController.propertiesRef.queryOrderedByKey().queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let child = snapshot.children.nextObject() as? FIRDataSnapshot else { log("landlord nil"); return }
            let key = child.key
            completion(key)
        })
    }
    
    static func fetchPropertiesForLandlord(landlordID: String, completion: @escaping (_ success: Bool) -> Void) {
        FirebaseController.propertiesRef.queryOrdered(byChild: UserController.kLandlordID).queryEqual(toValue: landlordID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allPropertiesDict = snapshot.value as? [String: [String: Any]] else { completion(false); return }
            
            let landlordProperties = allPropertiesDict.flatMap({Property(dictionary: $0.value)})
            
            let backgroundQ = DispatchQueue.global(qos: .background)
            let group = DispatchGroup()
            
            for propertyDict in allPropertiesDict {
                group.enter()
                backgroundQ.async(group: group, execute: {
                    let dict = propertyDict.value
                    guard let propertyID = dict[UserController.kPropertyID] as? String, let imageURLArray = dict[UserController.kImageURLS] as? [String], let property = landlordProperties.filter({$0.propertyID == propertyID}).first else { group.leave(); return }
                    
                    let subGroup = DispatchGroup()
                    
                    for imageURL in imageURLArray {
                        subGroup.enter()
                        FirebaseController.downloadProfileImageFor(property: property, withURL: imageURL, completion: {
                            subGroup.leave()
                        })
                    }
                    
                    subGroup.notify(queue: DispatchQueue.main, execute: {
                        group.leave()
                    })
                })
            }
            
            group.notify(queue: DispatchQueue.main, execute: {
                FirebaseController.properties = landlordProperties
                completion(true)
            })
        })
    }
    
    // refactor to not iterate over all propertydict
    static func fetchImagesForProperties(propertiesDict: [String: [String: Any]], coreDataProperties: [Property], completion: @escaping () -> Void) {
        
        let backgroundQ = DispatchQueue.global(qos: .background)
        let group = DispatchGroup()
        
        for propertyDict in propertiesDict {
            group.enter()
            backgroundQ.async(group: group, execute: {
                let dict = propertyDict.value
                guard let propertyID = dict[UserController.kPropertyID] as? String, let imageURLArray = dict[UserController.kImageURLS] as? [String], let property = coreDataProperties.filter({$0.propertyID == propertyID}).first else { group.leave(); return }
                
                let subGroup = DispatchGroup()
                
                for imageURL in imageURLArray {
                    subGroup.enter()
                    FirebaseController.downloadProfileImageFor(property: property, withURL: imageURL, completion: {
                        print("property image downloaded")
                        subGroup.leave()
                    })
                }
                
                subGroup.notify(queue: DispatchQueue.main, execute: {
                    group.leave()
                })
            })
        }
        group.notify(queue: DispatchQueue.main, execute: {
            FirebaseController.properties = coreDataProperties
            completion()
        })
    }
    
    static func fetchOneImageForPropertiesCards(propertiesDict: [String: [String: Any]], coreDataProperties: [Property], completion: @escaping () -> Void) {
        
        let backgroundQ = DispatchQueue.global(qos: .background)
        let group = DispatchGroup()
        
        for propertyDict in propertiesDict {
            group.enter()
            backgroundQ.async(group: group, execute: {
                let dict = propertyDict.value
                guard let propertyID = dict[UserController.kPropertyID] as? String, let imageURLArray = dict[UserController.kImageURLS] as? [String], let property = coreDataProperties.filter({$0.propertyID == propertyID}).first else { group.leave(); return }
                
                let subGroup = DispatchGroup()
                
                    subGroup.enter()
                    FirebaseController.downloadProfileImageFor(property: property, withURL: imageURLArray.first!, completion: {
                        print("property image downloaded")
                        subGroup.leave()
                    })
                
                subGroup.notify(queue: DispatchQueue.main, execute: {
                    group.leave()
                })
            })
        }
        group.notify(queue: DispatchQueue.main, execute: {
            FirebaseController.properties = coreDataProperties
            completion()
        })
    }
    
    // needs work: try and compile these two fetchProperty functions together
    // and this function is messy
    // don't grab directly from currentRenter.startAt
    static func fetchProperties(numberOfProperties: UInt, completion: @escaping () -> Void) {
        if UserController.propertyFetchCount == 1 { // if fecth count is one then you are at the end of the database
            completion()
            log("ERROR: out of properties")
            return
        }
        guard let renter = currentRenter, let startAt = renter.startAt else {
            completion()
            log("ERROR: couldn't retrieve either renter or startat")
            return
        }
        log(startAt)
        FirebaseController.propertiesRef.queryOrderedByKey().queryStarting(atValue: startAt).queryLimited(toFirst: numberOfProperties).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allPropertiesDict = snapshot.value as? [String: [String: Any]] else { completion(); return }

            UserController.propertyFetchCount = allPropertiesDict.count
            var landlordProperties = allPropertiesDict.flatMap({Property(dictionary: $0.value)})
            landlordProperties.sort {$0.propertyID! < $1.propertyID!}
            let lastProperty = landlordProperties.removeLast()
            // needs work: only get once and store
            var filteredProperties: [Property] = []
            if UserController.propertyFetchCount < 2 {
                filteredProperties = getFilteredProperties(properties: [lastProperty])
            } else {
                filteredProperties = getFilteredProperties(properties: landlordProperties)
                if filteredProperties.count < 2 {
                    updateCurrentRenterInFirebase(id: currentUserID!, attributeToUpdate: UserController.kStartAt, newValue: lastProperty.propertyID!)
                    currentRenter!.startAt = lastProperty.propertyID!
                }
            }
            if filteredProperties.isEmpty {
                fetchProperties(numberOfProperties: numberOfProperties, completion: { 
                    completion()
                })
            } else {
                fetchOneImageForPropertiesCards(propertiesDict: allPropertiesDict, coreDataProperties: filteredProperties, completion: {
                    completion()
                })
            }
        })
    }
    
    static func getFilteredProperties(properties: [Property]) -> [Property] {
        let filterSettingsDict = UserController.getRenterFiltersDictionary()
        
        guard let desiredBathroomCount = filterSettingsDict[RenterFilters.kBathroomCount.rawValue] as? Double,
            let desiredBedroomCount = filterSettingsDict[RenterFilters.kBedroomCount.rawValue] as? Int,
            let desiredPayment = filterSettingsDict[RenterFilters.kMonthlyPayment.rawValue] as? Int,
            let desiredPetsAllowed = filterSettingsDict[RenterFilters.kPetsAllowed.rawValue] as? Bool,
            let desiredSmokingAllowed = filterSettingsDict[RenterFilters.kSmokingAllowed.rawValue] as? Bool,
            //            let desiredPropertyFeatures = filterSettingsDict[filterKeys.kPropertyFeatures.rawValue] as? String,
            let desiredZipcode = filterSettingsDict[RenterFilters.kZipCode.rawValue] as? String,
            let renterID = currentUserID else {
                return [Property]()
        }
        
        let filtered = properties.filter({ $0.bathroomCount == desiredBathroomCount && $0.bedroomCount == Int64(desiredBedroomCount) && $0.monthlyPayment <= Int64(desiredPayment) && $0.petFriendly == desiredPetsAllowed && $0.smokingAllowed == desiredSmokingAllowed && $0.zipCode == desiredZipcode})
        
        var finalFiltered: [Property] = []
        for property in filtered {
            if let hasBeenViewedByObjects = property.hasBeenViewedBy?.flatMap({$0 as? HasBeenViewedBy}) {
                let hasBeenViewedByIDs = hasBeenViewedByObjects.map{$0.viewerID} as! [String]
                if !hasBeenViewedByIDs.contains(renterID) {
                    finalFiltered.append(property)
                }
            }
        }
        
        return finalFiltered
    }
    
//    static func fetchProperties(numberOfProperties: UInt) {
//        resetStartAtForRenterInFirebase(renterID: currentUserID!)
//        FirebaseController.propertiesRef.queryOrderedByKey().queryStarting(atValue: currentRenter!.startAt!).queryLimited(toFirst: numberOfProperties).observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let allPropertiesDict = snapshot.value as? [String: [String: Any]] else { return }
//            
//            let landlordProperties = allPropertiesDict.flatMap({Property(dictionary: $0.value)})
//            
//            let filteredProperties = getFilteredProperties(properties: landlordProperties)
//            
//            
//            fetchImagesForProperties(propertiesDict: allPropertiesDict, coreDataProperties: filteredProperties, completion: { 
//                
//            })
    
            // FirebaseController.properties = landlordProperties
            
//            let backgroundQ = DispatchQueue.global(qos: .background)
//            let group = DispatchGroup()
//            
//            for propertyDict in allPropertiesDict {
//                group.enter()
//                backgroundQ.async(group: group, execute: {
//                    let dict = propertyDict.value
//                    guard let propertyID = dict[UserController.kPropertyID] as? String, let imageURLArray = dict[UserController.kImageURLS] as? [String], let property = landlordProperties.filter({$0.propertyID == propertyID}).first, let renterID = UserController.currentUserID else { group.leave(); return }
//                    updateStartAtForRenterInFirebase(renterID: renterID, newStartAt: propertyID)
//                    let subGroup = DispatchGroup()
//                    
//                    for imageURL in imageURLArray {
//                        subGroup.enter()
//                        FirebaseController.downloadProfileImageFor(property: property, withURL: imageURL, completion: {
//                            subGroup.leave()
//                        })
//                    }
//                    
//                    subGroup.notify(queue: DispatchQueue.main, execute: {
//                        group.leave()
//                    })
//                })
//            }
//            
//            group.notify(queue: DispatchQueue.main, execute: {
//                FirebaseController.properties = landlordProperties
//            })
//        })
//    }
    
    /* Fetch by hasBeenViewedBy. We may need this later */
//    static func fetchProperties(numberOfProperties: UInt) {
//        FirebaseController.propertiesRef.queryOrdered(byChild: "\(UserController.kHasBeenViewedBy)/\(UserController.currentUserID!)").queryEqual(toValue: nil).queryLimited(toFirst: numberOfProperties).observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let allPropertiesDict = snapshot.value as? [String: [String: Any]] else { return }
//            
//            let landlordProperties = allPropertiesDict.flatMap({Property(dictionary: $0.value)})
//            
//            // FirebaseController.properties = landlordProperties
//            
//            let backgroundQ = DispatchQueue.global(qos: .background)
//            let group = DispatchGroup()
//            
//            for propertyDict in allPropertiesDict {
//                group.enter()
//                backgroundQ.async(group: group, execute: {
//                    let dict = propertyDict.value
//                    guard let propertyID = dict[UserController.kPropertyID] as? String, let imageURLArray = dict[UserController.kImageURLS] as? [String], let property = landlordProperties.filter({$0.propertyID == propertyID}).first, let renterID = UserController.currentUserID else { group.leave(); return }
//                    updateStartAtForRenterInFirebase(renterID: renterID, newStartAt: propertyID)
//                    let subGroup = DispatchGroup()
//                    
//                    for imageURL in imageURLArray {
//                        subGroup.enter()
//                        FirebaseController.downloadProfileImageFor(property: property, withURL: imageURL, completion: {
//                            subGroup.leave()
//                        })
//                    }
//                    
//                    subGroup.notify(queue: DispatchQueue.main, execute: {
//                        group.leave()
//                    })
//                })
//            }
//            
//            group.notify(queue: DispatchQueue.main, execute: {
//                FirebaseController.properties = landlordProperties
//            })
//        })
//    }
    
    static func getPropertyCount() {
        
        FirebaseController.propertiesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allPropertiesDict = snapshot.value as? [String: [String: [String: Any]]] else { return }
            
            let landlordProperties = allPropertiesDict.flatMap({$0.value})
            
            propertyCount = landlordProperties.count
        })
    }

    static func createPropertyInCoreDataFor(landlord: Landlord, completion: @escaping (_ property: Property?) -> Void) {
        guard let landlordID = landlord.id else { completion(nil); return }
        let prop = Property(dictionary: temporaryUserCreationDictionary, landlordID: landlordID)
        guard let property = prop else { NSLog("Property could not be initialized from dictionary"); completion(nil); return }
        property.landlord = landlord
//        saveToPersistentStore()
        completion(property)
    }
    
    static func createPropertyInFirebase(property: Property, completion: @escaping (_ success: Bool) -> Void) {
        guard let propertyID = property.propertyID, let dict = property.dictionaryRepresentation else { completion(false); return }
        
        let propertyRef = FirebaseController.propertiesRef.child(propertyID)
        propertyRef.setValue(dict) { (error, reference) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else {
                completion(true)
            }
        }
        
//        FirebaseController.likesRef.child(propertyID).child("0").setValue(true)
        
    }
    
    static func savePropertyImagesToCoreDataAndFirebase(images: [UIImage], landlord: Landlord, forProperty property: Property, completion: @escaping (_ imageURL: String) -> Void) {
        var count = 0
        
        guard let landlordID = landlord.id else { return }
        let group = DispatchGroup()
        var uploadedImageURL = ""
        for image in images {
            count += 1
            group.enter()
            FirebaseController.store(profileImage: image, forUserID: landlordID, and: property, with: count, completion: { (metadata, error, imageData) in
                if let error = error {
                    print(error.localizedDescription)
                    completion(uploadedImageURL)
                    return
                } else {
                    
                    print("Successfully uploaded image")
                    
                    guard let imageData = imageData, let imageURL = metadata?.downloadURL()?.absoluteString else { completion(uploadedImageURL); return }
                    // Print imageURL in console
                    
                    _ = ProfileImage(userID: landlordID, imageData: imageData as NSData, renter: nil, property: property, imageURL: imageURL)
//                    saveToPersistentStore()
                    uploadedImageURL = imageURL
                    group.leave()
                }
            })
        }
        group.notify(queue: DispatchQueue.main) {
            completion(uploadedImageURL)
        }
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
                
                _ = ProfileImage(userID: propertyID, imageData: imageData as NSData, renter: nil, property: property, imageURL: imageURL)
                
//                UserController.saveToPersistentStore()
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(true)
        }
    }
    
    static func updateCurrentPropertyInFirebase(id: String, attributeToUpdate: String, newValue: Any) {
        FirebaseController.propertiesRef.child(id).child(attributeToUpdate).setValue(newValue)
    }
    
    static func deletePropertyImageURLsInFirebase(id: String) {
        FirebaseController.propertiesRef.child(id).child(kImageURLS).removeValue()
    }
    
    static func getPropertyDetailsDictionary(property: Property) -> [String: Any] {
        var propertyDic = [String: Any]()
        
        guard let propertyDicRep = property.dictionaryRepresentation else {
            log("ERROR: property is nil")
            return propertyDic
        }
        
        for detail in UserController.PropertyDetailValues.allValues {
            let detailString = detail.rawValue
            propertyDic[detailString] = propertyDicRep[detailString]
        }
        
        return propertyDic
    }
    
    // needs work: this method should check if there is something in the renters before it goes to the internet
    static func getPropertyWithIDWithOneImage(propertyID: String, completion: @escaping (_ renter: Property?) -> Void) {
        FirebaseController.propertiesRef.queryOrderedByKey().queryEqual(toValue: propertyID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allPropertiesDict = snapshot.valueInExportFormat() as? [String: [String: Any]] else { return }
            let properties = allPropertiesDict.flatMap({Property(dictionary: $0.value)})
            let backgroundQ = DispatchQueue.global(qos: .background)
            let group = DispatchGroup()
            
            for propertyDict in allPropertiesDict {
                group.enter()
                backgroundQ.async(group: group, execute: {
                    let dict = propertyDict.value
                    guard let imageURLDict = (dict[UserController.kImageURLS] as? [String: String])?.values, let property = properties.first else { group.leave(); return }
                    let imageURLArray = Array(imageURLDict)
                    guard let imageToDownload = imageURLArray.first else { group.leave(); return }
                    FirebaseController.downloadProfileImageFor(property: property, withURL: imageToDownload, completion: {
                        group.leave()
                    })
                })
            }
            
            group.notify(queue: DispatchQueue.main, execute: {
                completion(properties.first)
            })
        })
    }
    
    // not currently in use but usefull if you need to get all images for a property
    static func getPropertyWithID(propertyID: String, completion: @escaping (_ renter: Property?) -> Void) {
        FirebaseController.propertiesRef.queryOrderedByKey().queryEqual(toValue: propertyID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allPropertiesDict = snapshot.valueInExportFormat() as? [String: [String: Any]] else { return }
            let properties = allPropertiesDict.flatMap({Property(dictionary: $0.value)})
            let backgroundQ = DispatchQueue.global(qos: .background)
            let group = DispatchGroup()
            
            for propertyDict in allPropertiesDict {
                backgroundQ.async(group: group, execute: {
                    let dict = propertyDict.value
                    guard let imageURLDict = (dict[UserController.kImageURLS] as? [String: String])?.values, let property = properties.first else { group.leave(); return }
                    let imageURLArray = Array(imageURLDict)
                    for imageURL in imageURLArray {
                        group.enter()
                        FirebaseController.downloadProfileImageFor(property: property, withURL: imageURL, completion: {
                            group.leave()
                        })
                    }
                })
            }
            
            group.notify(queue: DispatchQueue.main, execute: {
                completion(properties.first)
            })
        })
    }
    
    static func addHasBeenViewedByRenterToPropertyInFirebase(propertyID: String, renterID: String) {
        FirebaseController.propertiesRef.child(propertyID).child(UserController.kHasBeenViewedBy).child(renterID).setValue(true)
    }
    
    // MARK: - Renter functions
    
    static func resetStartAtForRenterInFirebase(renterID: String) {
        FirebaseController.propertiesRef.queryOrderedByKey().queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let child = snapshot.children.nextObject() as? FIRDataSnapshot else { log("landlord nil"); return }
            let key = child.key
            FirebaseController.rentersRef.child(renterID).child(UserController.kStartAt).setValue(key)
            currentRenter!.startAt = key
        })
    }
    
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
                    UserController.currentRenter = renter
                    completion()
                })
            })
        }
    }
    
    static func createRenterInCoreDataForCurrentUser(completion: @escaping ((_ renter: Renter?) -> Void) = { _ in }) {
        AuthenticationController.checkFirebaseLoginStatus { (loggedIn) in
            FacebookRequestController.requestCurrentUsers(information: [.first_name, .last_name, .email, .user_work_history], completion: { (facebookDictionary) in
                _ = facebookDictionary?.flatMap({temporaryUserCreationDictionary[$0.0] = $0.1})
                getFirstPropertyID(completion: { (propertyID) -> Void in
                    temporaryUserCreationDictionary[UserController.kStartAt] = propertyID
                    guard let renter = Renter(dictionary: temporaryUserCreationDictionary) else { log("Renter could not be initialized from dictionary"); completion(nil); return }
                    completion(renter)
                })
            })
        }
    }
    
    static func createRenterInFirebase(renter: Renter, completion: @escaping () -> Void) {
        guard let dict = renter.dictionaryRepresentation, let renterID = renter.id else { completion(); return }
        
        let propertyRef = FirebaseController.rentersRef.child(renterID)
        propertyRef.setValue(dict) { (error, reference) in
            if let error = error {
                print(error.localizedDescription)
                completion()
            } else {
                completion()
            }
        }
    }
    
    static func getFirstPropertyID(completion: @escaping (_ propertyID: String) -> Void) {
        FirebaseController.propertiesRef.queryOrderedByKey().queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let child = snapshot.children.nextObject() as? FIRDataSnapshot else { log("property nil"); return }
            let key = child.key
            
            completion(key)
        })
    }
    
    static func getFirstRenterID(completion: @escaping (_ renterID: String) -> Void) {
        FirebaseController.rentersRef.queryOrderedByKey().queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let child = snapshot.children.nextObject() as? FIRDataSnapshot else { log("renter nil"); return }
            let key = child.key
            
            completion(key)
        })
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
    
//    static func fetchPropertiesfd(numberOfProperties: UInt, completion: @escaping () -> Void) {
//        if UserController.propertyFetchCount == 1 { // if fecth count is one then you are at the end of the database
//            completion()
//            return
//        }
//        FirebaseController.propertiesRef.queryOrderedByKey().queryStarting(atValue: currentRenter!.startAt!).queryLimited(toFirst: numberOfProperties).observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let allPropertiesDict = snapshot.value as? [String: [String: Any]] else { completion(); return }
//            
//            UserController.propertyFetchCount = allPropertiesDict.count
//            var landlordProperties = allPropertiesDict.flatMap({Property(dictionary: $0.value)})
//            landlordProperties.sort {$0.propertyID! < $1.propertyID!}
//            let lastProperty = landlordProperties.removeLast()
//            // needs work: only get once and store
//            var filteredProperties: [Property] = []
//            if UserController.propertyFetchCount < 2 {
//                filteredProperties = getFilteredProperties(properties: [lastProperty])
//            } else {
//                updateCurrentRenterInFirebase(id: currentUserID!, attributeToUpdate: UserController.kStartAt, newValue: lastProperty.propertyID!)
//                currentRenter!.startAt = lastProperty.propertyID!
//                filteredProperties = getFilteredProperties(properties: landlordProperties)
//            }
//            if !filteredProperties.isEmpty {
//                fetchImagesForProperties(propertiesDict: allPropertiesDict, coreDataProperties: filteredProperties, completion: {
//                    completion()
//                })
//            } else {
//                completion()
//            }
//        })
//    }
    
    static func fetchOneImageForRentersCards(rentersDict: [String: [String: Any]], coreDataRenters: [Renter], completion: @escaping () -> Void) {
        let backgroundQ = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        let mainQ = DispatchQueue.main
        let group = DispatchGroup()
        
        for renterDict in rentersDict {
            group.enter()
            backgroundQ.async(group: group, execute: {
                let dict = renterDict.value
                guard let renterID = dict[UserController.kID] as? String, let imageDict = dict[UserController.kImageURLS] as? [String: String], let renter = coreDataRenters.filter({$0.id == "\(renterID)"}).first else { print("no core data renter for \(dict[UserController.kID])"); group.leave(); return }
                let imageURLArray = Array(imageDict.values)
                guard let imageToDownload = imageURLArray.first else { group.leave(); return }
                FirebaseController.downloadAndAddImagesFor(renter: renter, insertInto: nil, profileImageURLs: [imageToDownload], completion: { (success) in
                    log("renter image downloaded")
                    mainQ.async {
                        group.leave()
                    }
                })
            })
        }
        
        group.notify(queue: DispatchQueue.main, execute: {
            FirebaseController.renters = coreDataRenters
            completion()
        })
    }

//    static func fetchRenters(numberOfRenters: UInt, completion: @escaping () -> Void) {
//        if UserController.renterFetchCount == 1 { // if fecth count is one then you are at the end of the database
//            completion()
//            return
//        }
//        
//        log(currentLandlord!.startAt!)
//        FirebaseController.rentersRef.queryOrdered(byChild: UserController.kID).queryStarting(atValue: currentLandlord!.startAt!).queryLimited(toFirst: numberOfRenters).observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let allRentersDict = snapshot.valueInExportFormat() as? [String: [String: Any]], let landlordID = currentUserID else { completion(); return }
//            UserController.renterFetchCount = allRentersDict.count
//            var rentersArray = allRentersDict.flatMap({Renter(dictionary: $0.value)})
//            rentersArray.sort {
//                $0.id! < $1.id!
//            }
//            let lastRenter = rentersArray.removeLast()
//            var filteredRenters: [Renter] = []
//            if UserController.renterFetchCount < 2 {
//                filteredRenters = getFilteredRenters(renters: [lastRenter])
//            } else {
//                updateCurrentLandlordInFirebase(id: landlordID, attributeToUpdate: UserController.kStartAt, newValue: lastRenter.id!)
//                currentLandlord!.startAt = lastRenter.id!
//                filteredRenters = getFilteredRenters(renters: rentersArray)
//            }
//            if filteredRenters.isEmpty {
//                fetchRenters(numberOfRenters: numberOfRenters, completion: {
//                    completion()
//                })
//            } else {
//                fetchOneImageForRentersCards(rentersDict: allRentersDict, coreDataRenters: filteredRenters, completion: {
//                    completion()
//                })
//            }
//        })
//    }
    
    static func fetchRentersForProperty(numberOfRenters: UInt, property: Property, completion: @escaping () -> Void) {
        guard let landlord = currentLandlord, let landlordID = landlord.id, let propertyID = property.propertyID, let startAt = property.startAt else { completion(); return }
        if UserController.renterFetchCount == 1 { // if fecth count is one then you are at the end of the database
            log("WARNING: reached end of renter list on firebase")
            completion()
            return
        }
        
        log(startAt)
        FirebaseController.rentersRef.queryOrdered(byChild: UserController.kID).queryStarting(atValue: startAt).queryLimited(toFirst: numberOfRenters).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allRentersDict = snapshot.valueInExportFormat() as? [String: [String: Any]] else { completion(); return }
            UserController.renterFetchCount = allRentersDict.count
            var rentersArray = allRentersDict.flatMap({Renter(dictionary: $0.value)})
            rentersArray.sort {
                $0.id! < $1.id!
            }
            let lastRenter = rentersArray.removeLast()
            var filteredRenters: [Renter] = []
            let group = DispatchGroup()
            group.enter()
            if UserController.renterFetchCount < 2 {
                getFilteredRentersForProperty(renters: [lastRenter], property: property, completion: { filtered in
                    filteredRenters = filtered
                    group.leave()
                })
            } else {
                getFilteredRentersForProperty(renters: rentersArray, property: property, completion: { filtered in
                    filteredRenters = filtered
                    if filteredRenters.count == 0 {
                        updateCurrentPropertyInFirebase(id: propertyID, attributeToUpdate: UserController.kStartAt, newValue: lastRenter.id!)
                        property.startAt = lastRenter.id!
                    }
                    group.leave()
                })
            }
            group.notify(queue: .main, execute: { 
                if filteredRenters.isEmpty {
                    fetchRentersForProperty(numberOfRenters: numberOfRenters, property: property, completion: {
                        completion()
                    })
                } else {
                    fetchOneImageForRentersCards(rentersDict: allRentersDict, coreDataRenters: filteredRenters, completion: {
                        completion()
                    })
                }
            })
        })
    }
    
//    static func getFilteredRenters(renters: [Renter]) -> [Renter] {
//        let filterSettingsDict = UserController.getLandlordsFiltersDictionary()
//        
//        guard let creditDesired = filterSettingsDict[LandlordFilters.kWantsCreditRating.rawValue] as? String,
//            let landlordID = currentUserID else {
//                return [Renter]()
//        }
//        
//        let filtered = renters.filter({ $0.creditRating == creditDesired || creditDesired == "Any"})
//        
//        // get renters they haven't viewed
//        var finalFiltered: [Renter] = []
//        for renter in filtered {
//            if let hasBeenViewedByObjects = renter.hasBeenViewedBy?.flatMap({$0 as? HasBeenViewedBy}) {
//                let hasBeenViewedByIDs = hasBeenViewedByObjects.map{$0.viewerID} as! [String]
//                if !hasBeenViewedByIDs.contains(landlordID) {
//                    finalFiltered.append(renter)
//                }
//            }
//        }
//        
//        return finalFiltered
//    }
    
    static func getFilteredRentersForProperty(renters: [Renter], property: Property, completion: @escaping (_ renterArray: [Renter]) -> Void) {
        let filterSettingsDict = UserController.getLandlordsFiltersDictionary()
        
        // get property details
        let bedroomCount = property.bedroomCount
        let bathroomCount = property.bathroomCount
        let monthlyPayment = property.monthlyPayment
        let petsAllowed = property.petFriendly
        let smokingallowed = property.smokingAllowed
        
        // let desiredPropertyFeatures = filterSettingsDict[filterKeys.kPropertyFeatures.rawValue] as? String,
        guard let zipcode = property.zipCode else {
            log("couldn't retrieve property details")
            completion([Renter]())
            return
        }
        
        // get landlord details
        guard let creditDesired = filterSettingsDict[LandlordFilters.kWantsCreditRating.rawValue] as? String,
            let withinRangeMiles = filterSettingsDict[LandlordFilters.kWithinRangeMiles.rawValue] as? Int16,
            let landlordID = currentUserID else {
            log("couldn't retrieve landlord details")
            completion([Renter]())
            return
        }
        
        // filter landlord details
        let filteredWithLandlordDetails = renters.filter({ $0.creditRating! <= creditDesired || creditDesired == "Any"})
        
        // filter property details
        let filteredWithPropertyDetails = filteredWithLandlordDetails.filter({ $0.wantedBedroomCount == bedroomCount && $0.wantedBathroomCount == bathroomCount && $0.wantedPayment >= monthlyPayment && $0.wantsPetFriendly == petsAllowed && $0.wantsSmoking == smokingallowed })
        
        // get renters they haven't viewed
        var filteredByHasBeenViewedBy: [Renter] = []
        for renter in filteredWithPropertyDetails {
            if let hasBeenViewedByObjects = renter.hasBeenViewedBy?.flatMap({$0 as? HasBeenViewedBy}) {
                let hasBeenViewedByIDs = hasBeenViewedByObjects.map{$0.viewerID} as! [String]
                if !hasBeenViewedByIDs.contains(landlordID) {
                    filteredByHasBeenViewedBy.append(renter)
                }
            }
        }
        
        var finalFiltered: [Renter] = []
        // needs work: the distances and renters won't neccessarily match up. Make more deterministic
        LocationManager.getDistancesArrayFor(entities: filteredByHasBeenViewedBy, usingZipcode: zipcode, completion: { distanceDict in
            for distance in distanceDict {
                guard let renter = filteredByHasBeenViewedBy.filter({$0.email! == distance.key}).first else { log("ERROR: no renters who matched distance dictionary key"); completion(finalFiltered); return }
                let withinRange = distance.value < Int(withinRangeMiles) // needs work: this should be a setting in the landlords setting page
                if withinRange {
                    finalFiltered.append(renter)
                }
            }
            completion(finalFiltered)
        })
    }
    
    /* OLD fetch rents where it gets by hasbeenviewedby. Might be useful  */
//    static func fetchRenters(numberOfRenters: UInt, completion: @escaping () -> Void) {
//        FirebaseController.rentersRef.queryOrdered(byChild: "\(UserController.kHasBeenViewedBy)/\(UserController.currentUserID!)").queryEqual(toValue: nil).queryLimited(toFirst: numberOfRenters).observeSingleEvent(of: .value, with: { (snapshot) in
//            guard let allRentersDict = snapshot.valueInExportFormat() as? [String: [String: Any]] else { completion(); return }
//            let rentersArray = allRentersDict.flatMap({Renter(dictionary: $0.value)})
//            
//            let backgroundQ = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
//            let mainQ = DispatchQueue.main
//            let group = DispatchGroup()
//            
//            for renterDict in allRentersDict {
//                group.enter()
//                backgroundQ.async(group: group, execute: {
//                    let dict = renterDict.value
//                    guard let renterID = dict[UserController.kID] as? String, let imageDict = dict[UserController.kImageURLS] as? [String: String], let renter = rentersArray.filter({$0.id == "\(renterID)"}).first else { group.leave(); return }
//                    let imageURLArray = Array(imageDict.values)
//                    FirebaseController.downloadAndAddImagesFor(renter: renter, insertInto: nil, profileImageURLs: imageURLArray, completion: { (success) in
//                        print("renter image downloaded")
//                        mainQ.async {
//                            group.leave()
//                        }
//                    })
//                })
//            }
//            
//            group.notify(queue: DispatchQueue.main, execute: {
//                FirebaseController.renters = rentersArray
//                completion()
//            })
//        })
//    }
    
    // needs work: group with other method
    static func fetchAllRentersAndWait(completion: @escaping () -> Void) {
        FirebaseController.rentersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allRentersDict = snapshot.value as? [String: [String: Any]] else { return }
            
            let rentersArray = allRentersDict.flatMap({Renter(dictionary: $0.value)})
            
            let backgroundQ = DispatchQueue.global(qos: .background)
            let group = DispatchGroup()
            
            for propertyDict in allRentersDict {
                group.enter()
                backgroundQ.async(group: group, execute: {
                    let dict = propertyDict.value
                    guard let renterID = dict[UserController.kID] as? String, let imageURLArray = dict[UserController.kImageURLS] as? [String], let renter = rentersArray.filter({$0.id == renterID}).first else { group.leave(); return }
                    
                    FirebaseController.downloadAndAddImagesFor(renter: renter, insertInto: nil, profileImageURLs: imageURLArray, completion: { (success) in
                        group.leave()
                    })
                })
            }
            
            group.notify(queue: DispatchQueue.main, execute: {
                FirebaseController.renters = rentersArray
                completion()
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
                    guard let imageData = imageData, let imageURL = metadata?.downloadURL()?.absoluteString else {
                        if let error = error { print(error.localizedDescription) }
                        group.leave()
                        return
                    }
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
    
    static func updateCurrentRenterInFirebase(id: String, attributeToUpdate: String, newValue: Any) {
        FirebaseController.rentersRef.child(id).child(attributeToUpdate).setValue(newValue)
    }
    
    static func getRenterFiltersDictionary() -> [String: Any] {
        var filterDict = [String: Any]()
        guard let renter = UserController.currentRenter?.dictionaryRepresentation else {
            log("ERROR: renter is nil")
            return filterDict
        }
        
        for filter in UserController.RenterFilters.allValues {
            let filterString = filter.rawValue
            filterDict[filterString] = renter[filterString]
        }
        
        return filterDict
    }
    
    static func addHasBeenViewedByLandlordToRenterInFirebase(renterID: String, landlordID: String) {
        FirebaseController.rentersRef.child(renterID).child(UserController.kHasBeenViewedBy).child(landlordID).setValue(true)
    }
    
    static func eraseAllHasBeenViewedByForRenterFromProperties(renterID: String, completion: @escaping () -> Void) {
        FirebaseController.propertiesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allPropertiesDict = snapshot.value as? [String: [String: Any]] else { return }
            
            let properties = allPropertiesDict.flatMap({Property(dictionary: $0.value)})
            
            for property in properties {
                FirebaseController.propertiesRef.child(property.propertyID!).child(UserController.kHasBeenViewedBy).child(renterID).removeValue()
            }
            completion()
        })
    }
    
    // needs work: this method should check if there is something in the renters before it goes to the internet
    static func getRenterWithIDWithOneImage(renterID: String, completion: @escaping (_ renter: Renter?) -> Void) {
        if let renterWithID = FirebaseController.renters.filter({$0.id! == renterID}).first {
            log("renter with id: \(renterID) retrieved")
            completion(renterWithID)
        } else {
            FirebaseController.rentersRef.queryOrderedByKey().queryEqual(toValue: renterID).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let rentersDict = snapshot.valueInExportFormat() as? [String: [String: Any]] else { return }
                let rentersArray = rentersDict.flatMap({Renter(dictionary: $0.value)})
                let backgroundQ = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                let mainQ = DispatchQueue.main
                let group = DispatchGroup()
                for renterDict in rentersDict {
                    group.enter()
                    backgroundQ.async(group: group, execute: {
                        let dict = renterDict.value
                        guard let renterID = dict[UserController.kID] as? String, let imageDict = dict[UserController.kImageURLS] as? [String: String], let renter = rentersArray.filter({$0.id == "\(renterID)"}).first else { group.leave(); return }
                        let imageURLArray = Array(imageDict.values)
                        guard let imageToDownload = imageURLArray.first else { group.leave(); return }
                        FirebaseController.downloadAndAddImagesFor(renter: renter, insertInto: nil, profileImageURLs: [imageToDownload], completion: { (success) in
                            log("renter image downloaded")
                            mainQ.async {
                                group.leave()
                            }
                        })
                    })
                }
                group.notify(queue: DispatchQueue.main, execute: {
                    completion(rentersArray.first)
                })
            })
        }
    }
    
    // not in use but usefull if we want to get all pictures for a user
    static func getRenterWithID(renterID: String, completion: @escaping (_ renter: Renter?) -> Void) {
        if let renterWithID = FirebaseController.renters.filter({$0.id! == renterID}).first {
            log("renter with id: \(renterID) retrieved")
            completion(renterWithID)
        } else {
            FirebaseController.rentersRef.queryOrderedByKey().queryEqual(toValue: renterID).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let rentersDict = snapshot.valueInExportFormat() as? [String: [String: Any]] else { return }
                let rentersArray = rentersDict.flatMap({Renter(dictionary: $0.value)})
                let backgroundQ = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                let mainQ = DispatchQueue.main
                let group = DispatchGroup()
                for renterDict in rentersDict {
                    backgroundQ.async(group: group, execute: {
                        let dict = renterDict.value
                        guard let renterID = dict[UserController.kID] as? String, let imageDict = dict[UserController.kImageURLS] as? [String: String], let renter = rentersArray.filter({$0.id == "\(renterID)"}).first else { group.leave(); return }
                        let imageURLArray = Array(imageDict.values)
                        for imageURL in imageURLArray {
                            group.enter()
                            FirebaseController.downloadAndAddImagesFor(renter: renter, insertInto: nil, profileImageURLs: [imageURL], completion: { (success) in
                                log("renter image downloaded")
                                mainQ.async {
                                    group.leave()
                                }
                            })
                        }
                    })
                }
                group.notify(queue: DispatchQueue.main, execute: {
                    completion(rentersArray.first)
                })
            })
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
    static let kLandlordID = "landlordID"
    static let kPropertyID = "propertyID"
    
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
    
    enum RenterFilters: String {
        case kBathroomCount = "bathroomCount"
        case kBedroomCount = "bedroomCount"
        case kMonthlyPayment = "monthlyPayment"
        case kPetsAllowed = "petsAllowed"
        case kPropertyFeatures = "propertyFeatures"
        case kSmokingAllowed = "smokingAllowed"
        case kZipCode = "zipCode"
        case kCurrentOccupation = "currentOccupation"
        case kWithinRangeMiles = "within_range_miles"
        static let allValues = [kBathroomCount, kBedroomCount, kMonthlyPayment, kPetsAllowed, kPropertyFeatures, kSmokingAllowed, kZipCode, kCurrentOccupation, kWithinRangeMiles]
    }
    
    enum LandlordFilters: String {
        case kWantsCreditRating = "wants_credit_rating"
        case kWithinRangeMiles = "within_range_miles"
        static let allValues = [kWantsCreditRating, kWithinRangeMiles]
    }
    
    enum PropertyDetailValues: String {
        case kAddress = "address"
        case kAvailableDate = "availableDate"
        case kBathroomCount = "bathroomCount"
        case kBedroomCount = "bedroomCount"
        case kMonthlyPayment = "monthlyPayment"
        case kPetsAllowed = "petsAllowed"
        case kPropertyFeatures = "propertyFeatures"
        case kSmokingAllowed = "smokingAllowed"
        case kStarRating = "starRating"
        case kZipCode = "zipCode"
        static let allValues = [kAddress, kAvailableDate, kBathroomCount, kBedroomCount, kMonthlyPayment, kPetsAllowed, kPropertyFeatures, kSmokingAllowed, kStarRating, kZipCode]
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
        case backyard = "Backyard"
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
