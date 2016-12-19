//
//  LandlordController.swift
//  RentWorks
//
//  Created by Michael Perry on 12/8/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import Firebase
import CoreData

class LandlordController: UserController {
    
    // MARK: - Landlord functions
    
    static func getLandlordWithID(landlordID: String, completion: @escaping (_ landlord: Landlord?) -> Void) {
        FirebaseController.landlordsRef.queryOrderedByKey().queryEqual(toValue: landlordID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allLandlordsDict = snapshot.valueInExportFormat() as? [String: [String: Any]] else { return }
            let landlords = allLandlordsDict.flatMap({Landlord(dictionary: $0.value)})
            guard let landlord = landlords.first else { completion(nil); return }
            completion(landlord)
        })
    }
    
    static func saveLandlordProfileImagesToCoreDataAndFirebase(forLandlord landlord: Landlord, completion: @escaping () -> Void) {
        var count = 0
        
        FacebookRequestController.requestImageForCurrentUserWith(height: 1080, width: 1080) { (image) in
            guard let image = image, let lanlordID = landlord.id else { return }
            userCreationPhotos.append(image)
            
            let group = DispatchGroup()
            
            for image in userCreationPhotos {
                group.enter()
                count += 1
                FirebaseController.store(profileImage: image, forUserID: lanlordID, with: count, completion: { (metadata, error, imageData) in
                    guard let imageData = imageData, let imageURL = metadata?.downloadURL()?.absoluteString else {
                        if let error = error { print(error.localizedDescription) }
                        group.leave()
                        return
                    }
                    print("Successfully uploaded image")
                    _ = ProfileImage(userID: lanlordID, imageData: imageData as NSData, user: landlord, property: nil, imageURL: imageURL)
                    group.leave()
                })
            }
            group.notify(queue: DispatchQueue.main) {
                completion()
            }
        }
    }
    
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
                PropertyController.createPropertyInCoreDataFor(landlord: landlord, completion: { (property) in
                    guard let property = property else { print("Error creating property"); return }
                    PropertyController.savePropertyImagesToCoreDataAndFirebase(images: userCreationPhotos, landlord: landlord, forProperty: property, completion: {_ in
                        PropertyController.createPropertyInFirebase(property: property) { success in
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
                RenterController.getFirstRenterID(completion: { (renterID) in
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
            RenterController.getFirstRenterID(completion: { (renterID) in
                guard let landlordDictionary = snapshot.value as? [String: Any] else { log("couldn't create landlord"); completion(nil); return }
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
                        PropertyController.downloadAndAddImagesFor(property: property, completion: { (_) in
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

}
