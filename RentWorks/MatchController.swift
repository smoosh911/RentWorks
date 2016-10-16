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
    
    static func observeLikesFor(user: TestUser) {
        if isObservingCurrentUserLikeEndpoint == false {
            let userLikesRef = FirebaseController.likesRef.child(user.id)
            
            print(userLikesRef.url)
            
            userLikesRef.observe(FIRDataEventType.value, with: { (snapshot)in
                print("Changes observed")
                
                guard let likeDictionary = snapshot.value as? [String: Any] else { return }
                
                print(likeDictionary)
                checkForMatchesBetweenCurrentUserAnd(otherUserDictionary: likeDictionary, completion: { (matchingIDArray) in
                    delegate?.currentUserDidMatchWith(IDsOf: matchingIDArray)
                    isObservingCurrentUserLikeEndpoint = true
                    // Do some stuff... Haha. Get the user information or something.
                    // May have to wipe the like endpoint when the information is retrieved here so that the alert doesn't always pop up saying they have the same matches.
                })
            })
        } else {
            print("The app is already observing currentUser's endpoint")
        }
    }
    
    static func add(currentUser: TestUser, toLikelistOf matchedUser: TestUser, completion: (() -> Void)? = nil) {
        let matchedUserRef = FirebaseController.likesRef.child(matchedUser.id)
        
        matchedUserRef.child(currentUser.id).setValue(true)
        
        completion?()
    }
    
    static func checkForMatchesBetweenCurrentUserAnd(otherUserDictionary: [String: Any], completion: @escaping (_ matchingIDs: [String]) -> Void) {
        
        let group = DispatchGroup()
        var matchingUsersIDArray: [String] = []
        for id in otherUserDictionary.keys {
            group.enter()
            FirebaseController.likesRef.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                print("Snapshot: \(snapshot.value)")
                guard let matchDictionary = snapshot.value as? [String: Any], let currentUser = AuthenticationController.currentUser else { group.leave(); return }
                if matchDictionary.keys.contains(currentUser.id) {
                    print("Both have matched")
                    matchingUsersIDArray.append(id)
                    group.leave()
                } else {
                    print("Not matched")
                    group.leave()
                }
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(matchingUsersIDArray)
        }
    }
}

protocol UserMatchingDelegate: class {
    
    func currentUserDidMatchWith(IDsOf users: [String])
}
