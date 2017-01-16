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
        
        guard let address = address,
            let availableDate = availableDate,
            let zipCode = zipCode,
            let propertyID = propertyID,
            let city = city,
            let state = state,
            let country = country else { return nil }
        
        guard let profileImageArray = self.profileImages?.array as? [ProfileImage] else { return nil }
        
        let imageURLs = profileImageArray.flatMap({$0.imageURL})
        
        var dictionaryRepresentation: [String: Any] = [:]
        
        dictionaryRepresentation[UserController.kAddress] = address
        dictionaryRepresentation[UserController.kZipCode] = zipCode
        dictionaryRepresentation[UserController.kCity] = city
        dictionaryRepresentation[UserController.kState] = state
        dictionaryRepresentation[UserController.kCountry] = country
        dictionaryRepresentation[UserController.kAvailableDate] = availableDate.timeIntervalSince1970
        dictionaryRepresentation[UserController.kBathroomCount] = bathroomCount
        dictionaryRepresentation[UserController.kBedroomCount] = Int(bedroomCount)
        dictionaryRepresentation[UserController.kMonthlyPayment] = Int(monthlyPayment)
        dictionaryRepresentation[UserController.kPetsAllowed] = petFriendly
        dictionaryRepresentation[UserController.kSmokingAllowed] = smokingAllowed
        dictionaryRepresentation[UserController.kPropertyDescription] = propertyDescription ?? "No description available"
        dictionaryRepresentation[UserController.kStarRating] = rentalHistoryRating
        dictionaryRepresentation[UserController.kPropertyID] = propertyID
        dictionaryRepresentation[UserController.kWasherDryer] = washerDryer
        dictionaryRepresentation[UserController.kGarage] = garage
        dictionaryRepresentation[UserController.kDishwasher] = dishwasher
        dictionaryRepresentation[UserController.kBackyard] = backyard
        dictionaryRepresentation[UserController.kPool] = pool
        dictionaryRepresentation[UserController.kGym] = gym
        dictionaryRepresentation[UserController.kImageURLS] = imageURLs
        dictionaryRepresentation[UserController.kAirConditioning] = airConditioning
        dictionaryRepresentation[UserController.kDateAdded] = dateAdded ?? Date().timeIntervalSince1970
        dictionaryRepresentation[UserController.kHeating] = heating
        dictionaryRepresentation[UserController.kKitchen] = kitchen
        dictionaryRepresentation[UserController.kLeaseEnd] = leaseEnd
        dictionaryRepresentation[UserController.kLeaseLengthMonths] = leaseLengthMonths
        dictionaryRepresentation[UserController.kLivingRoom] = livingRoom
        dictionaryRepresentation[UserController.kName] = name
        dictionaryRepresentation[UserController.kStorage] = storage
        dictionaryRepresentation[UserController.kUtilities] = utilities
        dictionaryRepresentation[UserController.kWifi] = wifi
        
        guard let landlordID = landlord?.id else { return dictionaryRepresentation }
        
        dictionaryRepresentation[UserController.kLandlordID] = landlordID
        
        return dictionaryRepresentation
    }
}
