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
    
    static var allMatches: [TestUser] = []
    
    static func observeLikesFor(renter: Renter) {
        if isObservingCurrentUserLikeEndpoint == false {
            isObservingCurrentUserLikeEndpoint = true
            
            guard let renterID = renter.id else { return }
            
            let userLikesRef = FirebaseController.likesRef.child(renterID)
            
            userLikesRef.observe(FIRDataEventType.value, with: { (snapshot)in
                print("Changes observed")
                
                guard let likeDictionary = snapshot.value as? [String: Any] else { isObservingCurrentUserLikeEndpoint = false; return }
                
                
                checkForMatchesBetweenCurrentUserAnd(otherUserDictionary: likeDictionary, completion: { (matchingIDArray) in
                    delegate?.currentUserDidMatchWith(IDsOf: matchingIDArray)
                    // Do some stuff... Haha. Get the user information or something.
                    // May have to wipe the like endpoint when the information is retrieved here so that the alert doesn't always pop up saying they have the same matches.
                })
            })
        } else {
            print("The app is already observing currentUser's endpoint")
        }
    }
    
    
    // TODO: - For observing like endpoints, take landlord's propertyIDs and observe each one.
    
    static func addCurrentRenter(toLikelistOf likedProperty: Property, completion: (() -> Void)? = nil) {
        guard let propertyID = likedProperty.propertyID, let currentRenterID = UserController.currentRenter?.id else { completion?(); return }
        
        let matchedUserRef = FirebaseController.likesRef.child(propertyID)
        
        matchedUserRef.child(currentRenterID).setValue(true)
        
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
            
            
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(matchingUsersIDArray)
        }
    }
}

protocol UserMatchingDelegate: class {
    
    func currentUserDidMatchWith(IDsOf users: [String])
}
