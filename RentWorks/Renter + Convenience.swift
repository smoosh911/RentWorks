//
//  Renter + Convenience.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import CoreData

extension Renter {
    
//    @discardableResult convenience init?(address: String, birthday: NSDate = NSDate(), firstName: String, lastName: String, starRating: Double, id: String, creditRating: String, email: String, wantedPropertyFeatures: String, wantsPetFriendly: Bool, wantsSmoking: Bool, wantedBedroomCount: Int64, wantedBathroomCount: Double, wantedPayment: Int64, wantedZipCode: String, maritalStatus: String, bio: String, context: NSManagedObjectContext? = CoreDataStack.context) {
//        
//        if let context = context {
//            self.init(context: context)
//        } else {
//            self.init(entity: Renter.entity(), insertInto: nil)
//        }
//        
//        self.address = address
//        self.birthday = birthday
//        self.firstName = firstName
//        self.lastName = lastName
//        self.starRating = starRating
//        self.id = id
//        self.creditRating = creditRating
//        self.email = email
//        self.wantedPropertyFeatures = wantedPropertyFeatures
//        self.wantsPetFriendly = wantsPetFriendly
//        self.wantsSmoking = wantsSmoking
//        self.wantedBedroomCount = wantedBedroomCount
//        self.wantedBathroomCount = wantedBathroomCount
//        self.wantedPayment = wantedPayment
//        self.wantedZipCode = wantedZipCode
//        self.maritalStatus = maritalStatus
//        self.bio = bio
//    }
    
    @discardableResult convenience init?(dictionary: [String: Any], context: NSManagedObjectContext? = CoreDataStack.context) {
        
        guard let email = dictionary[UserController.kEmail] as? String,
            let address = dictionary[UserController.kAddress] as? String,
            let zipCode = dictionary[UserController.kZipCode] as? String,
            let wantedPropertyFeatures = dictionary[UserController.kPropertyFeatures] as? String,
            let creditRating = dictionary[UserController.kCreditRating] as? String,
            let firstName = dictionary[UserController.kFirstName] as? String,
            let lastName = dictionary[UserController.kLastName] as? String,
            let id = dictionary[UserController.kID] as? String,
            let wantedPayment = dictionary[UserController.kMonthlyPayment] as? Int,
            let wantedBedroomCount = dictionary[UserController.kBedroomCount] as? Double,
            let wantedBathroomCount = dictionary[UserController.kBathroomCount] as? Double,
            let wantsPetFriendly = dictionary[UserController.kPetsAllowed] as? Bool,
            let wantsSmoking = dictionary[UserController.kSmokingAllowed] as? Bool
            else { return nil }
        
        if let context = context {
            self.init(context: context)
        } else {
            self.init(entity: Renter.entity(), insertInto: nil)
        }
        
        if let occupation = dictionary[UserController.kCurrentOccupation] as? String {
            self.currentOccupation = occupation
        }

        if let occupationHistoryFromFacebook = dictionary[UserController.kOccupationHistory] as? [[String: Any]] {
            var occupationList: [String] = []
            for occupation in occupationHistoryFromFacebook {
                guard let position = occupation["position"] as? [String: Any], let positionName = position["name"], let employer = occupation["employer"] as? [String: Any], let employerName = employer["name"] else { continue }
                let occupationString = "\(positionName) at \(employerName)"
                Occupation(occupation: occupationString, landlordOrRenter: self, context: context)
                occupationList.append(occupationString)
            }
            self.currentOccupation = occupationList[0]
            self.occupationHistory = occupationList.joined(separator: "~")
        }
        
        if let occupationHistory = dictionary[UserController.kOccupationHistory] as? [String] {
            for occupation in occupationHistory {
                Occupation(occupation: occupation, landlordOrRenter: self, context: context)
            }
        }
        
        if let hasBeenViewedBy = dictionary[UserController.kHasBeenViewedBy] as? [String: Bool] {
            let hasBeenViewedByIDs = Array(hasBeenViewedBy.keys)
            
            for id in hasBeenViewedByIDs {
                HasBeenViewedBy(hasBeenViewedByID: id, propertyOrRenter: self)
            }
        }
        
        if let startAtVal = dictionary[UserController.kStartAt] as? String {
            self.startAt = startAtVal
        } else {
            UserController.getFirstPropertyID(completion: { (propertyID) in
                self.startAt = propertyID
            })
        }
        
        self.email = email
        self.address = address
        self.wantedPropertyFeatures = wantedPropertyFeatures
        self.creditRating = creditRating
        self.wantedZipCode = zipCode
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.wantsPetFriendly = wantsPetFriendly
        self.wantedPayment = Int64(wantedPayment)
        self.wantedBedroomCount = Int64(wantedBedroomCount)
        self.wantedBathroomCount = wantedBathroomCount
        self.wantsSmoking = wantsSmoking
    }
}
