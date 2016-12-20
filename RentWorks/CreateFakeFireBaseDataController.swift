//
//  CreateFakeFireBaseDataController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/23/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class CreateFakeFirebaseDataController {
    static func saveMockRenterProfileImagesToCoreDataAndFirebase(forRenterID renterID: String, completion: @escaping (String) -> Void) {
        
        guard let image = UIImage(named: renterID) else { return }
        
        let count = 1
        FirebaseController.store(profileImage: image, forUserID: renterID, with: count, completion: { (metadata, error, imageData) in
            guard let imageURL = metadata?.downloadURL()?.absoluteString else {
                if let error = error { print(error.localizedDescription) }
                return
            }
            FirebaseController.likesRef.child(renterID).child("0").setValue(true)
            print("Successfully uploaded image")
            completion(imageURL)
        })
    }
    // MARK: - Mock data related functions
    
//    static func createMockRenters() {
//        
//        for i in 1...10 {
//            let userRef =  FirebaseController.rentersRef.child("\(i)")
//            
//            
//            
//            CreateFakeFirebaseDataController.saveMockRenterProfileImagesToCoreDataAndFirebase(forRenterID: "\(i)", completion: { (imageURL) in
//                let dict: [String: Any] = [UserController.kEmail: "test@testing.com",
//                                           UserController.kZipCode: "84321",
//                                           UserController.kPropertyFeatures: "Gym",
//                                           UserController.kCreditRating: "A",
//                                           UserController.kPetsAllowed: true,
//                                           UserController.kSmokingAllowed: false,
//                                           UserController.kFirstName: "test",
//                                           UserController.kLastName: "account",
//                                           UserController.kMonthlyPayment: 1234,
//                                           UserController.kID: "\(i)",
//                    UserController.kBedroomCount: 2,
//                    UserController.kBathroomCount: 1.5,
//                    UserController.kAddress: "1234 Testing Road, TestTown, UT",
//                    UserController.kBio: "No bio available",
//                    UserController.kImageURLS: [imageURL]]
//                
//                userRef.setValue(dict)
//            })
//            
//            
//        }
//    }
//    
//    static func createMockLandlordsAndProperties() {
//        
//        for i in 11...20 {
//            let landlordRef = FirebaseController.landlordsRef.child("\(i)")
//            
//            let landlordDict = [UserController.kFirstName: "test", UserController.kLastName: "landlord", UserController.kEmail: "test@rentworks.com"]
//            
//            landlordRef.setValue(landlordDict)
//            
//            let propertyID = UUID().uuidString
//            
//            guard let landlord = Landlord(email: "test@rentworks.com", firstName: "test", lastName: "landlord", id: "\(i)") else { return }
//            
//            CreateFakeFirebaseDataController.saveMockPropertyProfileImagesToCoreDataAndFirebase(for: propertyID, landlord: landlord, completion: { (imageURL) in
//                
//                
//                
//                let propertyDict: [String: Any] = [UserController.kAddress: "1234 Testing Road, TestTown, UT",
//                                                   UserController.kZipCode: "84321",
//                                                   UserController.kAvailableDate: NSDate().timeIntervalSince1970,
//                                                   UserController.kBathroomCount: 1.0,
//                                                   UserController.kBedroomCount: 1,
//                                                   UserController.kMonthlyPayment: 1,
//                                                   UserController.kPetsAllowed: true,
//                                                   UserController.kSmokingAllowed: false,
//                                                   UserController.kPropertyDescription: "No description available",
//                                                   UserController.kStarRating: 5,
//                                                   UserController.kPropertyID: propertyID,
//                                                   UserController.kImageURLS: [imageURL],
//                                                   UserController.kLandlordID: "\(i)"]
//                
//                let propertyRef = FirebaseController.propertiesRef.child(propertyID)
//                FirebaseController.likesRef.child(propertyID).child("0").setValue(true)
//                propertyRef.setValue(propertyDict)
//                
//            })
//            
//        }
//    }
    
    
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
//            FirebaseController.store(profileImage: image, forUser: "\(i)", completion: { (_, error) in
//                if error != nil { print(error?.localizedDescription); return }
//            })
//        }
//    }
    
//    static func saveMockPropertyProfileImagesToCoreDataAndFirebase(for propertyID: String,
//                                                                   landlord: Landlord, completion: @escaping (String) -> Void) {
//        
//        guard let landlordID = landlord.id, let image = UIImage(named: landlordID), let property = Property(availableDate: NSDate(), bathroomCount: 2.0, bedroomCount: 1, monthlyPayment: 1, petFriendly: true, smokingAllowed: true, address: "1", zipCode: "1", propertyID: propertyID, landlord: landlord) else { return }
//        
//        
//        
//        let count = 1
//        FirebaseController.store(profileImage: image, forUserID: landlordID, and: property, with: count, completion: { (metadata, error, imageData) in
//            guard let imageURL = metadata?.downloadURL()?.absoluteString else {
//                if let error = error { print(error.localizedDescription) }
//                return
//            }
//            print("Successfully uploaded image")
//            completion(imageURL)
//        })
//    }
    
    static func createLandlordMockInFirebase(id: String, dictionary: [String: Any]) {
        FirebaseController.landlordsRef.child(id).setValue(dictionary)
    }
}
