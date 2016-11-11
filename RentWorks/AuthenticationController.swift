//
//  AuthenticationController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/8/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class AuthenticationController {
    
    static var currentUser: TestUser?
    
    static func attemptToSignInToFirebase(completion: @escaping (_ success: Bool) -> Void) {
        guard let token = FBSDKAccessToken.current() else { return }
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.tokenString)
        checkFirebaseLoginStatus { (loggedIn) in
            if loggedIn == false {
                
                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(false)
                    }
                    // Warning: Incomplete Implementation
                    guard let user = user else { completion(false); return }
                    print(user)
                    completion(true)
                })
            } else {
                completion(true)
            }
        }
    }
    
    
    static func checkFirebaseLoginStatus(completion: @escaping (_ status: Bool) -> Void) {
        if FIRAuth.auth()?.currentUser == nil {
            completion(false)
        } else {
            completion(true)
        }
    }
    
    static func signOutOfFirebase() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch {
            NSLog("Error at time of signing out of Firebase")
        }
    }
}
