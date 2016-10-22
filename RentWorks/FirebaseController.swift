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
import CoreData

class FirebaseController {
    
    static let ref = FIRDatabase.database().reference()
    static let allUsersRef = ref.child("users")
    static let landlordsRef = ref.child("landlords")
    static let rentersRef = ref.child("renters")
    static let propertiesRef = ref.child("properties")
    static let likesRef = ref.child("likes")
    
    static let storageRef = FIRStorage.storage().reference()
    static let profileImagesRef = storageRef.child("profileImages")
    
    static weak var delegate: FirebaseUserDelegate?
    
    static var users: [TestUser] = [] {
        didSet {
            delegate?.firebaseUsersWereUpdated()
        }
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
    
    static func downloadAndAddImagesFor(property: Property, completion: @escaping (_ success: Bool) -> Void) {
        guard let propertyProfileImages = property.profileImages?.array as? [ProfileImage] else { return }
        let profileImageURLs = propertyProfileImages.flatMap({$0.imageURL})
        
        let group = DispatchGroup()
        
        for imageURL in profileImageURLs {
            group.enter()
            let imageRef = FIRStorage.storage().reference(forURL: imageURL)
            
            imageRef.data(withMaxSize: 2 * 1024 * 1024) { (imageData, error) in
                guard let imageData = imageData, error == nil, let propertyID = property.propertyID else { group.leave(); completion(false); return }
                
                _ = ProfileImage(userID: propertyID, imageData: imageData as NSData, renter: nil, property: property, context: property.managedObjectContext)
                
                if property.managedObjectContext != nil {
                    UserController.saveToPersistentStore()
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(true)
        }
    }
    
    static func downloadAndAddImagesFor(renter: Renter, insertInto context: NSManagedObjectContext?, profileImageURLs: [String], completion: @escaping (_ success: Bool) -> Void) {
        
        let group = DispatchGroup()
        
        for imageURL in profileImageURLs {
            group.enter()
            let imageRef = FIRStorage.storage().reference(forURL: imageURL)
            
            imageRef.data(withMaxSize: 2 * 1024 * 1024) { (imageData, error) in
                guard let imageData = imageData, error == nil, let renterID = renter.id else { group.leave(); completion(false); return }
                
                _ = ProfileImage(userID: renterID, imageData: imageData as NSData, renter: renter, property: nil)
                
                if context != nil {
                    UserController.saveToPersistentStore()
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(true)
        }
    }
    
    
    
    static func downloadProfileImage(forUser user: User, and property: Property?, completion: @escaping (_ success: Bool) -> Void) {
        
        var profileImageRef = profileImagesRef
        
        
        if let renter = user as? Renter {
            guard let userID = user.id else { completion(false); return }
            profileImageRef = profileImageRef.child(userID)
            profileImageRef.data(withMaxSize: 2 * 1024 * 1024) { (imageData, error) in
                
                guard let imageData = imageData, error == nil else { completion(false); return }
                
                _ = ProfileImage(userID: userID, imageData: imageData as NSData, renter: renter, property: nil)
                UserController.saveToPersistentStore()
            }
        } else if let propertyID = property?.propertyID, let landlordID = property?.landlord?.id, user as? Renter == nil {
            
            profileImageRef = profileImageRef.child(landlordID).child(propertyID)
            
            profileImageRef.data(withMaxSize: 2 * 1024 * 1024) { (imageData, error) in
                
                guard let imageData = imageData, error == nil else { completion(false); return }
                
                _ = ProfileImage(userID: landlordID, imageData: imageData as NSData, renter: nil, property: property)
                UserController.saveToPersistentStore()
            }
            completion(true)
        }
    }
    
    static func downloadAndAddProfileImages(forUsers users: [User], andProperties properties: [Property]?, completion: (() -> Void)? = nil) {
        
        let group = DispatchGroup()
        
        for user in users {
            group.enter()
            downloadProfileImage(forUser: user, and: nil, completion: { (success) in
                
                
                //                user.profilePic = image
                group.leave()
            })
        }
        
        
        group.notify(queue: DispatchQueue.main) {
            completion?()
        }
        
    }
    
    static func downloadProfileImageFor(id: String, completion: @escaping (UIImage?) -> Void) {
        
        let profileImageRef = profileImagesRef.child("\(id).jpg")
        
        profileImageRef.data(withMaxSize: 1 * 1024 * 1024) { (data, error) in
            if error != nil { print(error?.localizedDescription) }
            guard let data = data, let image = UIImage(data: data) else { completion(nil); return }
            completion(image)
        }
    }
    
    //     MARK: - User Fetching
    
    
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
                        //                        FirebaseController.downloadProfileImage(forUser: user, and: nil, completion: { (image) in
                        //                            guard let image = image else { group.leave(); return }
                        //                            user.profilePic = image
                        //                            group.leave()
                        //                        })
                    }
                    
                    group.notify(queue: DispatchQueue.main, execute: {
                        // Dismiss the alertController here.
                        self.users = testUsers.filter({$0 != AuthenticationController.currentUser})
                        completion?(users)
                        
                    })
                }
            } else {
                AuthenticationController.attemptToSignInToFirebase(completion: { (success) in
                    if success {
                        getAllFirebaseUsersAndTheirProfilePictures(completion: nil)
                    }
                })
                print("Not logged in")
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
    
    static func checkForExistingUserInformation(completion: @escaping (_ hasAccount: Bool, _ ofType: String) -> Void) {
        
        guard FBSDKAccessToken.current() != nil else { completion(false, "not logged into Facebook"); return }
        
        FacebookRequestController.requestCurrentUsers(information: [.id]) { (dictionary) in
            guard let dictionary = dictionary, let id = dictionary[UserController.kID] as? String else { completion(false, "no Facebook ID returned"); return }
            
            FirebaseController.landlordsRef.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard snapshot.value as? [String: Any] != nil else { return }
                
                completion(true, "landlord")
                
                
            })
            
            FirebaseController.rentersRef.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard snapshot.value as? [String: Any] != nil else { return }
                
                completion(true, "renter")
            })
            
        }
    }
    
    static func handleUserInformationScenarios(completion: @escaping (_ success: Bool) -> Void) {
        
        let group = DispatchGroup()
        group.enter()
        UserController.getCurrentLandlordFromCoreData(completion: { (landlordExists) in
            if landlordExists {
                // Go to swiping screen?
                group.leave()
                completion(true)
            }
        })
        
        group.enter()
        UserController.getCurrentRenterFromCoreData(completion: { (renterExists) in
            if renterExists {
                group.leave()
                completion(true)
                // Go to swiping screen?
            }
        })
        
        group.notify(queue: DispatchQueue.main) { 
            
            UserController.fetchLoggedInUserFromFirebase(completion: { (user) in
                guard user != nil else { completion(false); return }
                
                completion(true)
                
            })
            
        }
        
    }
    
    
    
    //    static func handleUserInformationScenariosFor(user: TestUser, hasAccount: Bool, hasPhoto: Bool, completion: @escaping () -> Void) {
    //        switch (hasAccount, hasPhoto) {
    //        case (true, true):
    //            completion()
    //        case (false, false):
    //            FirebaseController.createFirebaseUserFor(currentUser: user, completion: {
    //                FacebookRequestController.requestImageForCurrentUserWith(height: 1080, width: 1080, completion: { (image) in
    //                    guard let image = image else { completion(); return }
    //                    user.profilePic = image
    //                    FirebaseController.store(profileImage: image, forUser: user, completion: { (metadata, error) in
    //                        guard error != nil else { print(error?.localizedDescription); completion(); return }
    //                        completion()
    //                    })
    //                })
    //            })
    //
    //
    //        case (false, true):
    //            FirebaseController.createFirebaseUserFor(currentUser: user, completion: {
    //                completion()
    //            })
    //
    //
    //        case (true, false):
    //            FacebookRequestController.requestImageForCurrentUserWith(height: 1080, width: 1080, completion: { (image) in
    //                guard let image = image else { return }
    //                user.profilePic = image
    //                FirebaseController.store(profileImage: image, forUser: user, completion: { (metadata, error) in
    //                    guard error != nil else { print(error?.localizedDescription); completion(); return }
    //                    completion()
    //                })
    //            })
    //        }
    //    }
    
    // MARK: - Mock data related functions
    
    static func createMockUsers() {
        
        for i in 1...15 {
            let userRef =  FirebaseController.allUsersRef.child("\(i)")
            let dict = ["name": "testUser", "email": "testUser@test.com"]
            userRef.setValue(dict)
        }
    }
    
    static func createAddressesForMockUsers() {
        for i in 1...15 {
            let addressRef =  FirebaseController.allUsersRef.child("\(i)").child("address")
            addressRef.setValue("1234 S Testing Road, MockTown, UT, 84321")
        }
    }
    
    //    static func uploadAndStoreMockPhotos() {
    //
    //        for i in 1...15 {
    //            guard let image = UIImage(named: "\(i)") else { print("could not find image"); return }
    //            storeMock(profileImage: image, forUser: "\(i)", completion: { (_, error) in
    //                if error != nil { print(error?.localizedDescription); return }
    //            })
    //        }
    //    }
    
    static func store(profileImage: UIImage, forUserID userID: String, and property: Property?, with count: Int?, completion: @escaping (FIRStorageMetadata?, Error?, Data?) -> Void) {
        
        var profileImageRef = profileImagesRef.child(userID)
        var countString: String?
        
        if count != nil { countString = "\(count!)" }
        if let property = property, let propertyID = property.propertyID, let countString = countString {
            profileImageRef = profileImageRef.child(propertyID).child(countString)
        }
        
        checkAndResizeImageToBeAMaximumOf(megabytes: 1, image: profileImage, withCompressionQuality: 1.0) { (imageData) in
            guard let imageData = imageData else { return }
            
            let metadata = FIRStorageMetadata()
            
            let uploadTask = profileImageRef.put(imageData, metadata: metadata, completion: { (metaData, error) in
                completion(metaData, error, imageData)
            })
            
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
    
    static func checkAndResizeImageToBeAMaximumOf(megabytes: Int, image: UIImage?, withCompressionQuality compressionQuality: CGFloat, temporaryData: Data? = nil, completion: (Data?) -> Void) {
        
        let megabyteCount = megabytes * 1024 * 1024
        if let temporaryData = temporaryData, let image = image {
            
            print(temporaryData.count)
            
            if temporaryData.count > megabyteCount {
                let newTempData = UIImageJPEGRepresentation(image, compressionQuality)
                checkAndResizeImageToBeAMaximumOf(megabytes: megabytes, image: image, withCompressionQuality: compressionQuality - 0.05, temporaryData: newTempData, completion: completion)
            } else {
                completion(temporaryData)
            }
        } else {
            guard let image = image, let imageData = UIImageJPEGRepresentation(image, compressionQuality) else { completion(temporaryData); return }
            
            checkAndResizeImageToBeAMaximumOf(megabytes: megabytes, image: image, withCompressionQuality: compressionQuality, temporaryData: imageData, completion: completion)
        }
    }
    
    
    static func store(profileImage: UIImage, forUserID userID: String, with count: Int?, completion: @escaping (FIRStorageMetadata?, Error?, Data?) -> Void) {
        
        var countString: String?
        var profileImageRef = profileImagesRef.child(userID)
        if count != nil { countString = "\(count!)" }
        
        if let countString = countString {
            profileImageRef = profileImageRef.child(countString)
        }
        
        checkAndResizeImageToBeAMaximumOf(megabytes: 1, image: profileImage, withCompressionQuality: 1.0) { (imageData) in
            guard let imageData = imageData else { return }
            
            let uploadTask = profileImageRef.put(imageData, metadata: nil, completion: { (metadata, error) in
                completion(metadata, error, imageData)
            })
            
            uploadTask.resume()
            
            uploadTask.observe(.progress) { (snapshot) in
                if let progress = snapshot.progress {
                    let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                    print("Upload percentage: \(percentComplete)%")
                }
            }
            
            uploadTask.observe(.failure) { (snapshot) in
                guard let storageError = snapshot.error else { return }
                print("Error uploading imageData to FirebaseStorage for userID: \(userID)\n\(storageError.localizedDescription)")
            }
        }
    }
}

protocol FirebaseUserDelegate: class {
    func firebaseUsersWereUpdated()
}
