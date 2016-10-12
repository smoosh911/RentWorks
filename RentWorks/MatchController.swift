//
//  MatchController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/8/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import FirebaseDatabase

class MatchController {
    
    static weak var delegate: MatchingDelegate?
    
    static func observeLikesFor(user: TestUser) {
        
        FirebaseController.matchesRef.child(user.id).observe(FIRDataEventType.value, with: { (snapshot)in
            print("Changes observed")
            
            guard let likeDictionary = snapshot.value as? [String: Any] else { return }
            
            print(likeDictionary)
            checkForMatchesBetweenCurrentUserAnd(otherUserDictionary: likeDictionary, completion: { (matchingIDArray) in
                delegate?.currentUserDidMatchWith(IDsOf: matchingIDArray)
                
                // Do some stuff... Haha. Get the user information or something.
                // May have to wipe the like endpoint when the information is retrieved here...?
            })
        })
    }
    
    static func add(currentUser: TestUser, toLikelistOf matchedUser: TestUser, completion: (() -> Void)? = nil) {
        let matchedUserRef = FirebaseController.matchesRef.child(matchedUser.id)
        
        matchedUserRef.child(currentUser.id).setValue(true)
        
        completion?()
    }
    
    static func checkForMatchesBetweenCurrentUserAnd(otherUserDictionary: [String: Any], completion: @escaping (_ matchingIDs: [String]) -> Void) {
        
        let group = DispatchGroup()
        var matchingUsersIDArray: [String] = []
        for id in otherUserDictionary.keys {
            group.enter()
            FirebaseController.matchesRef.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
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

protocol MatchingDelegate: class {
    
    func currentUserDidMatchWith(IDsOf users: [String])
}
