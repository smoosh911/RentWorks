//
//  FirebaseController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/8/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class FirebaseController {
    
    static let sharedController = FirebaseController()
    
    static let ref = FIRDatabase.database().reference()
    static let allUsersRef = ref.child("users")
    static let matchesRef = ref.child("matches")
    
    func createFirebaseUser(user: TestUser) {
        
        FirebaseController.allUsersRef.setValue([user.id: user.dictionaryRepresentation])
        FirebaseController.matchesRef.setValue([user.id: ["none"]])
        
        MatchController.observeMatchesFor(user: user)
        // May need to change the endpoint and/or the key for the dictionaryRepresentation.
        
    }
    
    static func checkForExistingUserInformation(user: TestUser, completion: @escaping (_ exists: Bool) -> Void) {
        FirebaseController.allUsersRef.child("\(user.id)").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let informationDictionary = snapshot.value as? [String: Any] else { completion(false); return }
            
            print(informationDictionary)
            completion(true)

        })
        
    }
}
