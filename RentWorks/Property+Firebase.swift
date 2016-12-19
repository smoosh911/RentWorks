//
//  Property+Firebase.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

extension Property {
    
    var dictionaryRepresentation: [String: Any]? {
        
        guard let address = address, let availableDate = availableDate, let zipCode = zipCode, let propertyID = propertyID else { return nil }
        
        guard let profileImageArray = self.profileImages?.array as? [ProfileImage] else { return nil }
        
        let imageURLs = profileImageArray.flatMap({$0.imageURL})
        
        var dictionaryRepresentation: [String: Any] = [UserController.kAddress: address,
                UserController.kZipCode: zipCode,
                UserController.kAvailableDate: availableDate.timeIntervalSince1970,
                UserController.kBathroomCount: bathroomCount,
                UserController.kBedroomCount: Int(bedroomCount),
                UserController.kMonthlyPayment: Int(monthlyPayment),
                UserController.kPetsAllowed: petFriendly,
                UserController.kSmokingAllowed: smokingAllowed,
                UserController.kPropertyDescription: propertyDescription ?? "No description available",
                UserController.kStarRating: rentalHistoryRating,
                UserController.kPropertyID: propertyID,
                UserController.kImageURLS: imageURLs]
        
        guard let landlordID = landlord?.id else { return dictionaryRepresentation }
        
        dictionaryRepresentation[UserController.kLandlordID] = landlordID
        
        return dictionaryRepresentation
    }
}
