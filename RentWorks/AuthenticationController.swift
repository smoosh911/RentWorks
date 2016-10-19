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
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print(error?.localizedDescription)
                completion(false)
            }
            // Warning: Incomplete Implementation
            print(user)
            completion(true)
        })
    }
    
    func createNewLandlordAccount() {
        
    }
    
    
    static func checkFirebaseLoginStatus(completion: @escaping (_ status: Bool) -> Void) {
        if FIRAuth.auth()?.currentUser == nil {
            completion(false)
        } else {
            completion(true)
        }
    }
    
    static func getCurrentUser(completion: ((_ success: Bool) -> Void)? = nil) {
        checkFirebaseLoginStatus { (loggedIn) in
            if loggedIn {
                FacebookRequestController.requestCurrentUsers(information: [.name, .email, .user_birthday], completion: { (dict) in
                    guard let dict = dict, let currentUser = TestUser(facebookDictionary: dict) else { return }
                    FirebaseController.checkForExistingUserInformation(user: currentUser, completion: { (hasAccount, hasPhoto) in
                        FirebaseController.handleUserInformationScenariosFor(user: currentUser, hasAccount: hasAccount, hasPhoto: hasPhoto, completion: {
                            if hasPhoto {
                                self.currentUser = currentUser
                                MatchController.observeLikesFor(user: currentUser)
                                if let completion = completion {
                                    completion(true)
                                }
                                
                            }
                            
                        })
                    })
                })
            } else {
                AuthenticationController.attemptToSignInToFirebase(completion: { (success) in
                    if success {
                        getCurrentUser(completion: completion)
                    }
                })
                NSLog("Not logged into Firebase. Unable to pull current user's information.")
                completion?(false)
            }
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
