//
//  Renter + Firebase.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

extension Renter {
    
    var emptyRenterDictionaryRepresentation: [String: Any]? { // This is only used for users who are not signed in
        var dictionaryRepresentation: [String: Any] = [:]
        dictionaryRepresentation[UserController.kZipCode] = wantedZipCode
        dictionaryRepresentation[UserController.kCity] = wantedCity
        dictionaryRepresentation[UserController.kState] = wantedState
        dictionaryRepresentation[UserController.kCountry] = wantedCountry
        dictionaryRepresentation[UserController.kPetsAllowed] = wantsPetFriendly
        dictionaryRepresentation[UserController.kSmokingAllowed] = wantsSmoking
        dictionaryRepresentation[UserController.kWasherDryer] = wantsWasherDryer
        dictionaryRepresentation[UserController.kGarage] = wantsGarage
        dictionaryRepresentation[UserController.kDishwasher] = wantsDishwasher
        dictionaryRepresentation[UserController.kBackyard] = wantsBackyard
        dictionaryRepresentation[UserController.kPool] = wantsPool
        dictionaryRepresentation[UserController.kGym] = wantsGym
        dictionaryRepresentation[UserController.kMonthlyPayment] = Int(wantedPayment)
        dictionaryRepresentation[UserController.kBedroomCount] = Int(wantedBedroomCount)
        dictionaryRepresentation[UserController.kBathroomCount] = wantedBathroomCount
        dictionaryRepresentation[UserController.kWithinRangeMiles] = withinRangeMiles
        
        return dictionaryRepresentation
    }
    var dictionaryRepresentation: [String: Any]? {
        guard let email = email,
            let zipCode = wantedZipCode,
            let city = wantedCity,
            let state = wantedState,
            let country = wantedCountry,
            let creditRating = creditRating,
            let firstName = firstName,
            let lastName = lastName,
            let id = id
            else { return nil }
        
        var dictionaryRepresentation: [String: Any] = [:]
        
        dictionaryRepresentation[UserController.kEmail] = email
        dictionaryRepresentation[UserController.kZipCode] = zipCode
        dictionaryRepresentation[UserController.kCity] = city
        dictionaryRepresentation[UserController.kState] = state
        dictionaryRepresentation[UserController.kCountry] = country
        dictionaryRepresentation[UserController.kCreditRating] = creditRating
        dictionaryRepresentation[UserController.kPetsAllowed] = wantsPetFriendly
        dictionaryRepresentation[UserController.kSmokingAllowed] = wantsSmoking
        dictionaryRepresentation[UserController.kWasherDryer] = wantsWasherDryer
        dictionaryRepresentation[UserController.kGarage] = wantsGarage
        dictionaryRepresentation[UserController.kDishwasher] = wantsDishwasher
        dictionaryRepresentation[UserController.kBackyard] = wantsBackyard
        dictionaryRepresentation[UserController.kPool] = wantsPool
        dictionaryRepresentation[UserController.kGym] = wantsGym
        dictionaryRepresentation[UserController.kFirstName] = firstName
        dictionaryRepresentation[UserController.kLastName] = lastName
        dictionaryRepresentation[UserController.kMonthlyPayment] = Int(wantedPayment)
        dictionaryRepresentation[UserController.kID] = id
        dictionaryRepresentation[UserController.kBedroomCount] = Int(wantedBedroomCount)
        dictionaryRepresentation[UserController.kBathroomCount] = wantedBathroomCount
        dictionaryRepresentation[UserController.kBio] = bio ?? "No bio available"
        dictionaryRepresentation[UserController.kStarRating] = starRating
        dictionaryRepresentation[UserController.kMaritalStatus] = maritalStatus ?? "Not specified"
        dictionaryRepresentation[UserController.kCurrentOccupation] = currentOccupation ?? "No occupation yet"
        dictionaryRepresentation[UserController.kWithinRangeMiles] = withinRangeMiles
        dictionaryRepresentation[UserController.kBankruptcies] = bankruptcies
        dictionaryRepresentation[UserController.kCriminalHistory] = criminalHistory ?? ""
        dictionaryRepresentation[UserController.kDriversLicenseNumber] = driversLicenceNum ?? ""
        dictionaryRepresentation[UserController.kDriversLicensePicURL] = driversLicensePicURL ?? ""
        dictionaryRepresentation[UserController.kEvictionHistory] = evictionHistory ?? ""
        dictionaryRepresentation[UserController.kIncome] = income 
        dictionaryRepresentation[UserController.kIsStudent] = isStudent 
        dictionaryRepresentation[UserController.kIsVerified] = isVerified 
        dictionaryRepresentation[UserController.kPreviousAddress] = previousAddress ?? ""
        dictionaryRepresentation[UserController.kReasonsForLeaving] = reasonForLeaving ?? ""
        dictionaryRepresentation[UserController.kSchool] = school ?? ""
        dictionaryRepresentation[UserController.kStudentID] = studentID ?? ""
        dictionaryRepresentation[UserController.kStudentPhotoIdURL] = studentPhotoIDURL ?? ""
        dictionaryRepresentation[UserController.kDateAdded] = dateAdded ?? Date().timeIntervalSince1970
        dictionaryRepresentation[UserController.kPhoneNumber] = phoneNumber ?? ""
        
        guard let profileImageArray = self.profileImages?.array as? [ProfileImage] else { return dictionaryRepresentation }
        
        let imageURLs = profileImageArray.flatMap({$0.imageURL})

        dictionaryRepresentation[UserController.kImageURLS] = imageURLs
        
        guard let occupationHistory = self.occupation?.allObjects as? [Occupation] else { return dictionaryRepresentation }
        
        let occupationDicts = occupationHistory.flatMap({ $0.dictionaryRepresentation })
        
        dictionaryRepresentation[UserController.kOccupationHistory] = occupationDicts
        
        return dictionaryRepresentation
    }
    
}
