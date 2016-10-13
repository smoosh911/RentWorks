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
    
    static let ref = FIRDatabase.database().reference()
    static let allUsersRef = ref.child("users")
    static let matchesRef = ref.child("matches")
    
    static let storageRef = FIRStorage.storage().reference()
    static let profileImagesRef = storageRef.child("profileImages")
    
    static weak var delegate: FirebaseUserDelegate?

    static var users: [TestUser] = [] {
        didSet {
            delegate?.firebaseUsersWereUpdated()
        }
    }
    
    // MARK: - User Creation
    
    static func createFirebaseUserFor(currentUser: TestUser, completion: (() -> Void)? = nil) {
        let userRef =  FirebaseController.allUsersRef.child(currentUser.id)
        userRef.setValue(currentUser.dictionaryRepresentation)
        
        FacebookRequestController.requestImageForCurrentUserWith(height: 1080, width: 1080, completion: { (image) in
            guard let image = image else { return }
            FirebaseController.store(profileImage: image, forUser: currentUser, completion: { (metadata, error) in
                guard error != nil else { print(error?.localizedDescription); completion?(); return }
                completion?()
            })
        })
        
        MatchController.observeLikesFor(user: currentUser)
        // May need to change the endpoint and/or the key for the dictionaryRepresentation.
    }
    
    
    
    
    // MARK: - Image storage/downloading
    
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
    
    // MARK: - User Fetching
    
    
    // WARNING: - At its current state, this function will pull ALL the users from Firebase. This is not a final function, but only to test.
    
    static func fetchAllFirebaseUsers(completion: @escaping ([TestUser]?) -> Void)  {
        allUsersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let allUsersDictionary = snapshot.value as? [String: [String: Any]] else { completion(nil); return }
            
            let testUsers = allUsersDictionary.flatMap({TestUser(dictionary: $0.value, id: $0.key)})
            
            completion(testUsers)
        })
    }
    
    // WARNING: - At its current state, this function will pull ALL the users, INCLUDING their profile pictures from Firebase. This is not a final function, but only to test.
    
    static func getAllFirebaseUsersAndTheirProfilePictures(completion: (([TestUser]?) -> Void)? = nil) {
        
        // TODO: - Make an alertController that will tell the user that the cards (users) are loading so that all this stuff below can run.
        AuthenticationController.checkFirebaseLoginStatus { (loggedIn) in
            if loggedIn {
                
                FirebaseController.fetchAllFirebaseUsers { (testUsers) in
                    guard let testUsers = testUsers else { return }
                    let group = DispatchGroup()
                    for user in testUsers {
                        group.enter()
                        FirebaseController.downloadProfileImage(forUser: user, completion: { (image) in
                            guard let image = image else { group.leave(); return }
                            user.profilePic = image
                            group.leave()
                        })
                    }
                    
                    group.notify(queue: DispatchQueue.main, execute: {
                        // Dismiss the alertController here.
                        self.users = testUsers
                        completion?(users)
                    })
                }
            }
        }
    }
    
    static func fetchUsersFor(userIDs: [String], completion: @escaping ([TestUser?]) -> Void) {
        let group = DispatchGroup()
        var usersArray: [TestUser?] = []
        for userID in userIDs {
            group.enter()
            
            let userRef = allUsersRef.child(userID)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let userDictionary = snapshot.value as? [String: Any] else { return }
                let user = TestUser(dictionary: userDictionary, id: userID)
                usersArray.append(user)
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) { 
            completion(usersArray)
        }
    }
    
    static func checkForExistingUserInformation(user: TestUser, completion: @escaping (_ hasAccount: Bool, _ hasPhoto: Bool) -> Void) {
        
        var hasAccount = false
        var hasPhoto = false
        
        let group = DispatchGroup()
        group.enter()
        FirebaseController.allUsersRef.child(user.id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard snapshot.value as? [String: Any] != nil else { group.leave(); return }
            hasAccount = true
            group.leave()
        })
        
        group.enter()
        profileImagesRef.child(user.id).downloadURL { (url, error) in
            
            url != nil && error == nil ? hasPhoto = true : print(error?.localizedDescription)
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(hasAccount, hasPhoto)
        }
    }
    
    
    static func handleUserInformationScenariosFor(user: TestUser, hasAccount: Bool, hasPhoto: Bool, completion: @escaping () -> Void) {
        switch (hasAccount, hasPhoto) {
        case (true, true):
            
            // Pull information?
            completion()
        case (false, false):
            FirebaseController.createFirebaseUserFor(currentUser: user, completion: {
                FacebookRequestController.requestImageForCurrentUserWith(height: 1080, width: 1080, completion: { (image) in
                    guard let image = image else { completion(); return }
                    FirebaseController.store(profileImage: image, forUser: user, completion: { (metadata, error) in
                        guard error != nil else { print(error?.localizedDescription); completion(); return }
                        completion()
                    })
                })
            })
            
            
        case (false, true):
            FirebaseController.createFirebaseUserFor(currentUser: user, completion: {
                completion()
            })
            
            
        case (true, false):
            FacebookRequestController.requestImageForCurrentUserWith(height: 1080, width: 1080, completion: { (image) in
                guard let image = image else { return }
                FirebaseController.store(profileImage: image, forUser: user, completion: { (metadata, error) in
                    guard error != nil else { print(error?.localizedDescription); completion(); return }
                    completion()
                })
            })
        }
    }
    
    // MARK: - Mock data related functions
    
    static func createMockUsers() {
        
        for i in 1...15 {
            let userRef =  FirebaseController.allUsersRef.child("\(i)")
            let dict = ["name": "testUser", "email": "testUser@test.com"]
            userRef.setValue(dict)
        }
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
}

protocol FirebaseUserDelegate: class {
    
    func firebaseUsersWereUpdated()
}
