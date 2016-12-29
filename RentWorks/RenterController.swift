//
//  RenterController.swift
//  RentWorks
//
//  Created by Michael Perry on 12/8/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import FirebaseStorage
import CoreData
import Firebase

class RenterController: UserController {
    
    // MARK: - Renter functions
    
    static func deleteRenterPropertyMatchInFirebase(propertyID: String, renterID: String) {
        FirebaseController.likesRef.child(propertyID).child(renterID).removeValue()
    }
    
    static func deleteRenterInFirebase(renterID: String) {
        FirebaseController.likesRef.child(renterID).removeValue()
        FirebaseController.rentersRef.child(renterID).removeValue()
    }
    
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
                PropertyController.getFirstPropertyID(completion: { (propertyID) -> Void in
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
    

    
    static func getFirstRenterID(completion: @escaping (_ renterID: String?) -> Void) {
        FirebaseController.rentersRef.queryOrderedByKey().queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let child = snapshot.children.nextObject() as? FIRDataSnapshot else { log("renter nil"); completion(nil); return }
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
        guard let propertyID = property.propertyID, let startAt = property.startAt else { completion(); return }
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
                        PropertyController.updateCurrentPropertyInFirebase(id: propertyID, attributeToUpdate: UserController.kStartAt, newValue: lastRenter.id!)
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
        let filterSettingsDict = LandlordController.getLandlordsFiltersDictionary()
        
        // get property details
        let bedroomCount = property.bedroomCount
        let bathroomCount = property.bathroomCount
        let monthlyPayment = property.monthlyPayment
        let petsAllowed = property.petFriendly
        let smokingallowed = property.smokingAllowed
        
        // let desiredPropertyFeatures = filterSettingsDict[filterKeys.kPropertyFeatures.rawValue] as? String,
        guard let zipcode = property.zipCode, let city = property.city, let state = property.state else {
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
        
        let desiredLocation = zipcode == "" ? "\(city), \(state)" : zipcode
        
        // needs work: the distances and renters won't neccessarily match up. Make more deterministic
        LocationManager.getDistancesArrayFor(entities: filteredByHasBeenViewedBy, usingLocation: desiredLocation, completion: { distanceDict in
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
                    _ = ProfileImage(userID: renterID, imageData: imageData as NSData, user: renter, property: nil, imageURL: imageURL)
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
}
