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
        
        return [UserController.kEmail: email,
                UserController.kZipCode: wantedZipCode,
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
                UserController.kZipCode: zipCode,
                UserController.kBio: bio ?? "No bio available"]

    }
    
}
