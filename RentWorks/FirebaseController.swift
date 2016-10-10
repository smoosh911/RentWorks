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
import FirebaseStorage

class FirebaseController {
    
    static let sharedController = FirebaseController()
    
    static let ref = FIRDatabase.database().reference()
    static let allUsersRef = ref.child("users")
    static let matchesRef = ref.child("matches")
    
    static let storageRef = FIRStorage.storage().reference()
    static let profileImagesRef = storageRef.child("profileImages")
    
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
    
    static func store(profileImage: UIImage, forUser user: TestUser, completion: @escaping (FIRStorageMetadata?, Error?) -> Void) {
        
        let profileImageRef = profileImagesRef.child(user.id)
        guard let imageData = UIImageJPEGRepresentation(profileImage, 1.0) else { return }
        
        let uploadTask = profileImageRef.put(imageData, metadata: nil, completion: completion)
        
        uploadTask.resume()
        
        uploadTask.observe(.progress) { (snapshot) in
            if let progress = snapshot.progress {
                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                print("Upload percentage: \(percentComplete)%")
            }
        }
        
        uploadTask.observe(.failure) { (snapshot) in
            guard let storageError = snapshot.error else { return }
            print(storageError.localizedDescription)
        }
    }
    
    static func downloadProfileImage(forUser user: TestUser, completion: @escaping (UIImage?) -> Void) {
        
        let profileImageRef = profileImagesRef.child(user.id)

        profileImageRef.downloadURL { (url, error) in
            guard error != nil, let urlString = url?.absoluteString else { print(error?.localizedDescription); completion(nil); return }
            
            ImageController.imageFor(url: urlString, completion: completion)
        }
        
    }
    
}
