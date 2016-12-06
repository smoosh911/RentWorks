//
//  Renter + Firebase.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

extension Renter {
    var dictionaryRepresentation: [String: Any]? {
        guard let email = email,
            let address = address,
            let zipCode = wantedZipCode,
            let wantedPropertyFeatures = wantedPropertyFeatures,
            let creditRating = creditRating,
            let firstName = firstName,
            let lastName = lastName,
            let id = id
            else { return nil }
        
        var dictionaryRepresentation: [String: Any] = [UserController.kEmail: email,
                UserController.kZipCode: zipCode,
                UserController.kPropertyFeatures: wantedPropertyFeatures,
                UserController.kCreditRating: creditRating,
                UserController.kPetsAllowed: wantsPetFriendly,
                UserController.kSmokingAllowed: wantsSmoking,
                UserController.kFirstName: firstName,
                UserController.kLastName: lastName,
                UserController.kMonthlyPayment: Int(wantedPayment),
                UserController.kID: id,
                UserController.kBedroomCount: Int(wantedBedroomCount),
                UserController.kBathroomCount: wantedBathroomCount,
                UserController.kAddress: address,
                UserController.kBio: bio ?? "No bio available",
                UserController.kCurrentOccupation: currentOccupation ?? "No occupation yet",
                UserController.kOccupationHistory: occupationHistory?.components(separatedBy: "~") ?? "No occupation history yet",
                UserController.kWithinRangeMiles: withinRangeMiles]
        
        guard let profileImageArray = self.profileImages?.array as? [ProfileImage] else { return dictionaryRepresentation }
        
        let imageURLs = profileImageArray.flatMap({$0.imageURL})

        dictionaryRepresentation[UserController.kImageURLS] = imageURLs
        
        return dictionaryRepresentation
    }
    
}
