//
//  MatchController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/8/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import FirebaseDatabase
import UIKit

class MatchController {
    
    static weak var delegate: UserMatchingDelegate?
    
    static var isObservingCurrentUserLikeEndpoint = false
    
    static var matchedRenters: [Renter] = []
    
    static var matchedProperties: [Property] = [] {
        didSet {
            print("Matched properties has been set")
            delegate?.currentUserHasMatches()
        }
    }
    
    static var currentUserHasNewMatches = false
    
    static func observeLikesForCurrentRenter() {
        if isObservingCurrentUserLikeEndpoint == false {
            
            isObservingCurrentUserLikeEndpoint = true
            
            guard let currentRenter = UserController.currentRenter, let renterID = currentRenter.id else { return }
            
            let userLikesRef = FirebaseController.likesRef.child(renterID)
            
            userLikesRef.observe(FIRDataEventType.value, with: { (snapshot)in
                currentUserHasNewMatches = true
                delegate?.currentUserHasMatches()
                
                guard let likeDictionary = snapshot.value as? [String: Any] else { isObservingCurrentUserLikeEndpoint = false; return }
                
                
                self.checkForMatchesBetweenCurrentUserAnd(otherUserDictionary: likeDictionary, completion: { (matchingIDArray) in
                    
                    var matches: [Property] = []
                    let group = DispatchGroup()
                    
                    for id in matchingIDArray {
                        group.enter()
                        guard let matchedProperty = FirebaseController.properties.filter({$0.propertyID == id}).first else { group.leave(); return }
                        matches.append(matchedProperty)
                        group.leave()
                    }
                    group.notify(queue: DispatchQueue.main, execute: {
                        
                        matchedProperties = matches
                        if matches.count > 0 { currentUserHasNewMatches = true; delegate?.currentUserHasMatches() }
                    })
                    
                })
            })
        } else {
            print("The app is already observing currentUser's endpoint")
        }
    }
    
    
    static func observeLikesForCurrentLandlord() {
        if isObservingCurrentUserLikeEndpoint == false {
            
            isObservingCurrentUserLikeEndpoint = true
            
            guard let currentLandlord = UserController.currentLandlord, let properties = currentLandlord.property?.array as? [Property] else { return }
            var matches: [Renter] = []
            
            // TODO: - Save these matched users to CoreData and perhaps a more permanent endpoint in Firebase.
            
            let group = DispatchGroup()
            
            for property in properties {
                group.enter()
                guard let propertyID = property.propertyID else { group.leave(); return }
                let userLikesRef = FirebaseController.likesRef.child(propertyID)
                
                userLikesRef.observe(FIRDataEventType.value, with: { (snapshot)in
                    
                    guard let likeDictionary = snapshot.value as? [String: Any] else { group.leave(); isObservingCurrentUserLikeEndpoint = false; return }
                    print(likeDictionary)
                    
                    self.checkForMatchesBetweenCurrentUserAnd(otherUserDictionary: likeDictionary, completion: { (matchingIDArray) in
                        
                        let subgroup = DispatchGroup()
                        
                        for id in matchingIDArray {
                            subgroup.enter()
                            guard let matchedRenter = FirebaseController.renters.filter({$0.id == id}).first else { subgroup.leave(); return }
                            matches.append(matchedRenter)
                            subgroup.leave()
                        }
                        subgroup.notify(queue: DispatchQueue.main, execute: {
                            group.leave()
                        })
                    })
                })
            }
            
            group.notify(queue: DispatchQueue.main, execute: { 
                self.matchedRenters = matches
                if matches.count > 0 { currentUserHasNewMatches = true; delegate?.currentUserHasMatches() }
            })
        } else {
            print("The app is already observing currentUser's endpoint")
        }
        
    }
    
    
    
    // TODO: - For observing like endpoints, take landlord's propertyIDs and observe each one.
    
    static func addCurrentRenter(toLikelistOf likedProperty: Property, completion: (() -> Void)? = nil) {
        guard let landlordID = likedProperty.landlordID, let propertyID = likedProperty.propertyID, let currentRenterID = UserController.currentRenter?.id else { completion?(); return }
        
        let matchedUserRef = FirebaseController.likesRef.child(landlordID).child(propertyID)
        
        matchedUserRef.child(currentRenterID).setValue(true)
        
        completion?()
    }
    
    
    // Change this function/Firebase endpoints later to support adding a specific property?
    static func addCurrentLandlord(toLikelistOf likedRenter: Renter, completion: (() -> Void)? = nil) {
        guard let renterID = likedRenter.id, let firstProperty = UserController.currentLandlord?.property?.firstObject as? Property, let firstPropertyID = firstProperty.propertyID else { completion?(); return }
        
        let matchedUserRef = FirebaseController.likesRef.child(renterID)
        
        matchedUserRef.child(firstPropertyID).setValue(true)
        
        completion?()
    }
    
    static func checkForMatchesBetweenCurrentUserAnd(otherUserDictionary: [String: Any], completion: @escaping (_ matchingIDs: [String]) -> Void) {
        var matchingUsersIDArray: [String] = []
        let group = DispatchGroup()
        
        if UserController.currentUserType == "renter" {
            
            for id in otherUserDictionary.keys {
                group.enter()
                FirebaseController.likesRef.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                    print("Snapshot: \(snapshot.value)")
                    guard let matchDictionary = snapshot.value as? [String: Any], let currentRenter = UserController.currentRenter, let renterID = currentRenter.id else { group.leave(); return }
                    if matchDictionary.keys.contains(renterID) {
                        matchingUsersIDArray.append(id)
                        group.leave()
                    } else {
                        group.leave()
                    }
                })
            }
            
        } else if UserController.currentUserType == "landlord" {
            let subgroup = DispatchGroup()
            guard let properties = UserController.currentLandlord?.property?.array as? [Property] else { print("Cannot fetch properties for the current landlord"); return }
            for property in properties {
                group.enter()
                
                for id in otherUserDictionary.keys {
                    subgroup.enter()
                    guard let propertyID = property.propertyID else { print("No propertyID to observe for"); return }
                    FirebaseController.likesRef.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                        print("Snapshot: \(snapshot.value)")
                        guard let matchDictionary = snapshot.value as? [String: Any] else { subgroup.leave(); return }
                        if matchDictionary.keys.contains(propertyID) {
                            matchingUsersIDArray.append(id)
                            subgroup.leave()
                        } else {
                            subgroup.leave()
                        }
                    })
                }
                
                subgroup.notify(queue: DispatchQueue.main, execute: {
                    group.leave()
                })
            }
            
        }
        group.notify(queue: DispatchQueue.main) {
            completion(matchingUsersIDArray)
        }
    }
}

protocol UserMatchingDelegate: class {
    
    func currentUserHasMatches()
}
