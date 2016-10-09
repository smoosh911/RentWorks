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
    
    static func attemptToSignInToFirebase(completion: @escaping () -> Void) {
        guard let token = FBSDKAccessToken.current() else { return }
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.tokenString)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
            // Warning: Incomplete Implementation
            print(user)
            completion()
        })
    }
    
    
    
    static func signOutOfFirebase() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch {
            NSLog("Error at time of signing out of Firebase")
        }
    }
}
