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
    
    var users: [TestUser] = []
    
    init() {
        
        AuthenticationController.attemptToSignInToFirebase {
            
            FirebaseController.fetchAllFirebaseUsers { (testUsers) in
                guard let testUsers = testUsers else { return }
                self.users = testUsers
            }
        }
    }
    
    
    func createFirebaseUser(user: TestUser) {
        let userRef =  FirebaseController.allUsersRef.child(user.id)
        userRef.setValue(user.dictionaryRepresentation)
        
        
        
        
        MatchController.observeMatchesFor(user: user)
        // May need to change the endpoint and/or the key for the dictionaryRepresentation.
        
    }
    
    static func createMockUsers() {
        
        for i in 1...15 {
            let userRef =  FirebaseController.allUsersRef.child("\(i)")
            let dict = ["name": "testUser", "email": "testUser@test.com"]
            userRef.setValue(dict)
        }
    }
    
    static func checkForExistingUserInformation(user: TestUser, completion: @escaping (_ exists: Bool) -> Void) {
        FirebaseController.allUsersRef.child("\(user.id)").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let informationDictionary = snapshot.value as? [String: Any] else { completion(false); return }
            
            print(informationDictionary)
            completion(true)
            
        })
    }
    
    static func uploadAndStoreMockPhotos() {
        
        for i in 1...15 {
            guard let image = UIImage(named: "\(i)") else { print("could not find image"); return }
            storei(profileImage: image, forUser: "\(i)", completion: { (_, error) in
                if error != nil { print(error?.localizedDescription); return }
            })
        }
    }
    
    static func storei(profileImage: UIImage, forUser userID: String, completion: @escaping (FIRStorageMetadata?, Error?) -> Void) {
        
        let profileImageRef = profileImagesRef.child(userID)
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
        
        profileImageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) in
            if error != nil { print(error?.localizedDescription) }
            guard let data = data, let image = UIImage(data: data) else { completion(nil); return }
            completion(image)
        }
    }
    
//    static func downloadProfileImageFor(id: String, completion: @escaping (UIImage?) -> Void) {
//        
//        let profileImageRef = profileImagesRef.child("\(id).jpg")
//        
//        profileImageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) in
//            if error != nil { print(error?.localizedDescription) }
//            guard let data = data, let image = UIImage(data: data) else { completion(nil); return }
//            completion(image)
//        }
//    }
    
    
    
    // WARNING: - At its current state, this function will pull ALL the users, including their profilepictures. This is not a final function, but only to test.
    static func fetchAllFirebaseUsers(completion: @escaping ([TestUser]?) -> Void)  {
        allUsersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allUsersDictionary = snapshot.value as? [String: [String: Any]] else { completion(nil); return }
            
            let testUsers = allUsersDictionary.flatMap({TestUser(dictionary: $0.value, id: $0.key)})
            
            completion(testUsers)
        })
    }
    
}
