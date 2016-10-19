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
        
        guard let address = address, let availableDate = availableDate, let propertyDescription = propertyDescription, let zipCode = zipCode else { return nil }
        
        return [UserController.kAddress: address,
                UserController.kZipCode: zipCode,
                UserController.kAvailableDate: availableDate,
                UserController.kBathroomCount: bathroomCount,
                UserController.kBedroomCount: bedroomCount,
                UserController.kMonthlyPayment: monthlyPayment,
                UserController.kPetsAllowed: petFriendly,
                UserController.kSmokingAllowed: smokingAllowed,
                UserController.kPropertyDescription: propertyDescription,
                UserController.kStarRating: rentalHistoryRating]
    }
    
    
}
