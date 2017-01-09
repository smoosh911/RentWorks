//
//  PropertyController.swift
//  RentWorks
//
//  Created by Michael Perry on 12/8/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import CoreData
import Firebase

class PropertyController: UserController {
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
    
    static func deletePropertyRenterMatchInFirebase(propertyID: String, renterID: String) {
        FirebaseController.likesRef.child(renterID).child(propertyID).removeValue()
    }
    
    static func deletePropertyInFirebase(propertyID: String) {
        FirebaseController.likesRef.child(propertyID).removeValue()
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
            let warning = "WARNING: out of properties"
            log(warning)
            return
        }
        guard let renter = currentRenter, let startAt = renter.startAt else {
            completion()
            let errorMessage = "ERROR: couldn't retrieve either renter or startat"
            log(errorMessage)
            return
        }
        log(startAt)
        FirebaseController.propertiesRef.queryOrderedByKey().queryStarting(atValue: startAt).queryLimited(toFirst: numberOfProperties).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allPropertiesDict = snapshot.value as? [String: [String: Any]] else { completion(); return }
            
            var landlordProperties = allPropertiesDict.flatMap({Property(dictionary: $0.value)})
            UserController.propertyFetchCount = landlordProperties.count
            landlordProperties.sort {$0.propertyID! < $1.propertyID!}
            let lastProperty = landlordProperties.removeLast()
            // needs work: only get once and store
            var filteredProperties: [Property] = []
            let group = DispatchGroup()
            group.enter()
            if UserController.propertyFetchCount < 2 {
                getFilteredProperties(properties: [lastProperty], completion: { properties in
                    filteredProperties = properties
                    group.leave()
                })
            } else {
                getFilteredProperties(properties: landlordProperties, completion: { properties in
                    filteredProperties = properties
                    if filteredProperties.count < 2 {
                        RenterController.updateCurrentRenterInFirebase(id: currentUserID!, attributeToUpdate: UserController.kStartAt, newValue: lastProperty.propertyID!)
                        currentRenter!.startAt = lastProperty.propertyID!
                    }
                    group.leave()
                })
            }
            group.notify(queue: .main, execute: {
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
        })
    }
    
    static func getFilteredProperties(properties: [Property], completion: @escaping (_ properties: [Property]) -> Void) {
        let filterSettingsDict = RenterController.getRenterFiltersDictionary()
        
        guard let desiredBathroomCount = filterSettingsDict[RenterFilters.kBathroomCount.rawValue] as? Double,
            let desiredBedroomCount = filterSettingsDict[RenterFilters.kBedroomCount.rawValue] as? Int,
            let desiredPayment = filterSettingsDict[RenterFilters.kMonthlyPayment.rawValue] as? Int,
            let desiredPetsAllowed = filterSettingsDict[RenterFilters.kPetsAllowed.rawValue] as? Bool,
            let desiredSmokingAllowed = filterSettingsDict[RenterFilters.kSmokingAllowed.rawValue] as? Bool,
            //            let desiredPropertyFeatures = filterSettingsDict[filterKeys.kPropertyFeatures.rawValue] as? String,
            let desiredZipcode = filterSettingsDict[RenterFilters.kZipCode.rawValue] as? String,
            let desiredCity = filterSettingsDict[RenterFilters.kCity.rawValue] as? String,
            let desiredState = filterSettingsDict[RenterFilters.kState.rawValue] as? String,
            let withinRangeMiles = filterSettingsDict[RenterFilters.kWithinRangeMiles.rawValue] as? Int16,
            let renterID = currentUserID else {
                completion([Property]())
                return
        }
        
        let today = Date()
        
        let filtered = properties.filter({ $0.bathroomCount == desiredBathroomCount && $0.bedroomCount == Int64(desiredBedroomCount) && $0.monthlyPayment <= Int64(desiredPayment) && $0.petFriendly == desiredPetsAllowed && $0.smokingAllowed == desiredSmokingAllowed && ($0.availableDate! as Date) < today })
        
        var filteredByHasBeenViewedBy: [Property] = []
        for property in filtered {
            if let hasBeenViewedByObjects = property.hasBeenViewedBy?.flatMap({$0 as? HasBeenViewedBy}) {
                let hasBeenViewedByIDs = hasBeenViewedByObjects.map{$0.viewerID} as! [String]
                if !hasBeenViewedByIDs.contains(renterID) {
                    filteredByHasBeenViewedBy.append(property)
                }
            }
        }
        
        var finalFiltered: [Property] = []
        
        let desiredLocation = desiredZipcode == "" ? "\(desiredCity), \(desiredState)" : desiredZipcode

        // needs work: the distances and renters won't neccessarily match up. Make more deterministic
        LocationManager.getDistancesArrayFor(entities: filteredByHasBeenViewedBy, usingLocation: desiredLocation) { (distanceDict) in
            for distance in distanceDict {
                guard let property = filteredByHasBeenViewedBy.filter({$0.propertyID == distance.key}).first else { log("ERROR: no renters who matched distance dictionary key"); completion(finalFiltered); return }
                let withinRange = distance.value <= Int(withinRangeMiles) // needs work: this should be a setting in the landlords setting page
                if withinRange {
                    finalFiltered.append(property)
                }
            }
            completion(finalFiltered)
        }
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
    
    static func getFirstPropertyID(completion: @escaping (_ propertyID: String) -> Void) {
        FirebaseController.propertiesRef.queryOrderedByKey().queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let child = snapshot.children.nextObject() as? FIRDataSnapshot else { log("property nil"); return }
            let key = child.key
            
            completion(key)
        })
    }
    
    static func getPropertyCount() {
        
        FirebaseController.propertiesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allPropertiesDict = snapshot.value as? [String: [String: [String: Any]]] else { return }
            
            let landlordProperties = allPropertiesDict.flatMap({$0.value})
            
            propertyCount = landlordProperties.count
        })
    }
    
    static func createPropertyInCoreDataFor(landlord: Landlord, completion: @escaping (_ property: Property?) -> Void) {
        guard let landlordID = landlord.id else { log(ErrorManager.LandlordErrors.retrievalError); completion(nil); return }
        let prop = Property(dictionary: temporaryUserCreationDictionary, landlordID: landlordID)
        guard let property = prop else { log(ErrorManager.PropertyErrors.creationError); completion(nil); return }
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
                    
                    _ = ProfileImage(userID: landlordID, imageData: imageData as NSData, user: nil, property: property, imageURL: imageURL)
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
                
                _ = ProfileImage(userID: propertyID, imageData: imageData as NSData, user: nil, property: property, imageURL: imageURL)
                
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
        var propertyDic: [String: Any] = [String: Any]()
        
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
                    guard let imageURLDict = (dict[UserController.kImageURLS] as? [String: String])?.values, let property = properties.first else {
                        group.leave()
                        return
                    }
                    let imageURLArray = Array(imageURLDict)
                    guard let imageToDownload = imageURLArray.first else {
                        group.leave()
                        return
                    }
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
}
