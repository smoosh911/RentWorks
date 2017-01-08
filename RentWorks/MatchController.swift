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

protocol MatchControllerDelegate: class {
    func currentUserHasMatchesUpdated()
}

class MatchController {
    
    static weak var delegate: MatchControllerDelegate?
    
    static var isObservingCurrentUserLikeEndpoint = false
    
//    static var matchedRenters: [Renter] = []
    
    static var matchedRentersForProperties: [String: [Renter]] = [:] // the string is the property id
    
    static var matchedProperties: [Property] = []
    
    static var firstMatch = false
    
    static var propertyIDsWithMatches: [String] = [] // the strings are property IDs
    
    static var currentUserHasMatches = false
    
    static var currentUserHasNewMatches = false
    
    static func observeLikesForCurrentRenter() {
        if isObservingCurrentUserLikeEndpoint == false {
            
            isObservingCurrentUserLikeEndpoint = true
            
            guard let currentRenter = UserController.currentRenter, let renterID = currentRenter.id else { return }
            
            let userLikesRef = FirebaseController.likesRef.child(renterID)
            
            userLikesRef.observe(FIRDataEventType.value, with: { (snapshot)in

                guard let likeDictionary = snapshot.value as? [String: Any] else { isObservingCurrentUserLikeEndpoint = false; return }
                
                self.checkForMatchesBetweenCurrentUserAnd(otherUserDictionary: likeDictionary, completion: { (matchingIDArray) in
                    
                    var matches: [Property] = []
                    let group = DispatchGroup()
                    
                    for id in matchingIDArray {
                        group.enter()
                        PropertyController.getPropertyWithIDWithOneImage(propertyID: id, completion: { (propertyResult) in
                            guard let property = propertyResult else { return }
                            matches.append(property)
                            group.leave()
                        })
                    }
                    group.notify(queue: DispatchQueue.main, execute: {
                        
                        if matchedProperties.count > 0 {
                            for match in matches {
                                if !matchedProperties.contains(match) {
                                    matchedProperties.append(match)
                                    currentUserHasMatches = true
                                    delegate?.currentUserHasMatchesUpdated()
                                }
                            }
                        } else {
                            matchedProperties = matches
                            matches = []
                            if matchedProperties.count > 0 {
                                currentUserHasMatches = true
                                delegate?.currentUserHasMatchesUpdated()
                            }
                        }
                        let oldrenterMatchCount = UserDefaults.standard.integer(forKey: Identifiers.UserDefaults.renterMatchCount.rawValue)
                        if oldrenterMatchCount < matchedProperties.count {
                            currentUserHasNewMatches = true
                        } else {
                            currentUserHasNewMatches = false
                        }
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
            defer { matches = [] }
            
            // TODO: - Save these matched users to CoreData and perhaps a more permanent endpoint in Firebase.
            
            
            for property in properties {
                
                guard let propertyID = property.propertyID else { return }
                let userLikesRef = FirebaseController.likesRef.child(propertyID)
                
                userLikesRef.observe(FIRDataEventType.value, with: { (snapshot) in
                    
                    guard let likeDictionary = snapshot.value as? [String: Any] else { isObservingCurrentUserLikeEndpoint = false; return }
                    
                    self.checkForMatchesBetweenCurrentUserAnd(otherUserDictionary: likeDictionary, completion: { (matchingIDArray) in
                        
                        let subgroup = DispatchGroup()
                        
                        for id in matchingIDArray {
                            subgroup.enter()
                            RenterController.getRenterWithIDWithOneImage(renterID: id, completion: { (renterResult) in
                                guard let renter = renterResult else { return }
                                matches.append(renter)
                                
                                subgroup.leave()
                            })
                        }
                        subgroup.notify(queue: DispatchQueue.main, execute: {
                            var currentRentersForProperty = matchedRentersForProperties[propertyID]
                            if currentRentersForProperty == nil {
                                currentRentersForProperty = []
                            }
                            if currentRentersForProperty!.count > 0 {
                                for match in matches {
                                    if !currentRentersForProperty!.contains(match) {
                                        currentRentersForProperty!.append(match)
                                        matchedRentersForProperties[propertyID] = currentRentersForProperty!
                                        currentUserHasNewMatches = true
                                        propertyIDsWithMatches.append(propertyID)
                                        delegate?.currentUserHasMatchesUpdated()
                                    }
                                }
                            } else {
                                currentRentersForProperty! = matches
                                matchedRentersForProperties[propertyID] = currentRentersForProperty!
                                matches = []
                                if currentRentersForProperty!.count > 0 {
                                    currentUserHasMatches = true
                                    delegate?.currentUserHasMatchesUpdated()
                                }
                            }
                            let oldPropertyMatchCount = UserDefaults.standard.integer(forKey: "\(Identifiers.UserDefaults.propertyMatchCount.rawValue)/\(propertyID)")
                            if oldPropertyMatchCount < currentRentersForProperty!.count {
                                currentUserHasNewMatches = true
                                propertyIDsWithMatches.append(propertyID)
                            } else {
                                currentUserHasNewMatches = false
                            }
                        })
                    })
                })
            }
        } else {
            print("The app is already observing currentUser's endpoint")
        }
    }
    
    // TODO: - For observing like endpoints, take landlord's propertyIDs and observe each one.
    
    static func addCurrentRenter(renter: Renter, toLikelistOf likedProperty: Property, completion: (() -> Void)? = nil) {
        guard let propertyID = likedProperty.propertyID, let currentRenterID = renter.id else { completion?(); return }
        
        FirebaseController.likesRef.child(propertyID).child(currentRenterID).setValue(true)
        
        completion?()
    }
    
    // Change this function/Firebase endpoints later to support adding a specific property?
    static func addCurrentProperty(property: Property, toLikelistOf likedRenter: Renter, completion: (() -> Void)? = nil) {
        guard let renterID = likedRenter.id, let propertyID = property.propertyID else { completion?(); return }
        
        FirebaseController.likesRef.child(renterID).child(propertyID).setValue(true)
        
        completion?()
    }
    
    static func checkForMatchesBetweenCurrentUserAnd(otherUserDictionary: [String: Any], completion: @escaping (_ matchingIDs: [String]) -> Void) {
        var matchingUsersIDArray: [String] = []
        let group = DispatchGroup()
        if UserController.currentUserType == "renter" {
            
            for id in otherUserDictionary.keys {
                group.enter()
                FirebaseController.likesRef.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
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
