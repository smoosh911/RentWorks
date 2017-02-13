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
            let firstName = dictionary[UserController.kFirstName] as? String,
            let lastName = dictionary[UserController.kLastName] as? String,
            let id = dictionary[UserController.kID] as? String
            else { return nil }
        
        if let context = context {
            self.init(context: context)
        } else {
            self.init(entity: Renter.entity(), insertInto: nil)
        }
        
        if let withinRangeMiles = dictionary[UserController.kWithinRangeMiles] as? Int {
            self.withinRangeMiles = Int16(withinRangeMiles)
        } else {
            self.withinRangeMiles = 5
        }
        
        if let occupation = dictionary[UserController.kCurrentOccupation] as? String {
            self.currentOccupation = occupation
        }

        if let occupationHistoryFromFacebook = dictionary[UserController.kOccupationHistory] as? [[String: Any]] {
            var occupationList: [String] = []
            for occupation in occupationHistoryFromFacebook {
                var startDate: Date?
                var city = ""
                var state = ""
                guard let position = occupation["position"] as? [String: Any], let positionName = position["name"] as? String, let employer = occupation["employer"] as? [String: Any], let employerName = employer["name"] as? String else { continue }
                if let startDateString = occupation["start_date"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-mm-dd"
                    if let date = dateFormatter.date(from: startDateString) {
                        startDate = date
                    }
                }
                if let location = occupation["location"] as? [String: Any], let locationName = location["name"] as? String {
                    let citySate = locationName.components(separatedBy: ", ")
                    city = citySate[0]
                    state = citySate[1]
                }
                let occupationString = "\(positionName) at \(employerName)"
                Occupation(occupationTitle: positionName, employer: employerName, city: city, state: state, address: "", startDate: startDate, endDate: nil, landlordOrRenter: self)
                occupationList.append(occupationString)
            }
            if occupationList.count > 0 {
                self.currentOccupation = occupationList[0]
            }
//            self.occupationHistory = occupationList.joined(separator: "~")
        }
        
//        if let occupationHistoryFromFirebase = dictionary[UserController.kOccupationHistory] as? [[String: Any]] {
//            for occupation in occupationHistoryFromFirebase {
//                var startDate: Date?
//                var city = ""
//                var state = ""
//                guard let employer = occupation[UserController.kEmployer], let title = occupation[UserController.kTitle] else {
//                    return
//                }
//            }
//        }
        
        if let hasBeenViewedBy = dictionary[UserController.kHasBeenViewedBy] as? [String: Bool] {
            let hasBeenViewedByIDs = Array(hasBeenViewedBy.keys)
            
            for id in hasBeenViewedByIDs {
                HasBeenViewedBy(hasBeenViewedByID: id, propertyOrRenter: self)
            }
        }
        
        if let startAtVal = dictionary[UserController.kStartAt] as? String {
            self.startAt = startAtVal
        } else {
            PropertyController.getFirstPropertyID(completion: { (propertyID) in
                self.startAt = propertyID
            })
        }
        
        if let starRating = dictionary[UserController.kStarRating] as? Double {
            self.starRating = starRating
        } else {
            self.starRating = 0.0
        }
        
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.creditRating = dictionary[UserController.kCreditRating] as? String ?? "Other"
        self.wantedZipCode = dictionary[UserController.kZipCode] as? String ?? ""
        self.wantedCity = dictionary[UserController.kCity] as? String ?? ""
        self.wantedState = dictionary[UserController.kState] as? String ?? ""
        self.wantedCountry = dictionary[UserController.kCountry] as? String ?? ""
        self.wantsPetFriendly = dictionary[UserController.kPetsAllowed] as? Bool ?? false
        self.wantedPayment = dictionary[UserController.kMonthlyPayment] as? Int64 ?? 1500
        self.wantedBedroomCount = dictionary[UserController.kBedroomCount] as? Int64 ?? 1
        self.wantedBathroomCount = dictionary[UserController.kBathroomCount] as? Double ?? 1.0
        self.wantsSmoking = dictionary[UserController.kSmokingAllowed] as? Bool ?? false
        self.wantsWasherDryer = dictionary[UserController.kWasherDryer] as? Bool ?? false
        self.wantsGarage = dictionary[UserController.kGarage] as? Bool ?? false
        self.wantsDishwasher = dictionary[UserController.kDishwasher] as? Bool ?? false
        self.wantsBackyard = dictionary[UserController.kBackyard] as? Bool ?? false
        self.wantsPool = dictionary[UserController.kPool] as? Bool ?? false
        self.wantsGym = dictionary[UserController.kGym] as? Bool ?? false
        self.maritalStatus = dictionary[UserController.kMaritalStatus] as? String ?? "Not specified"
        self.bankruptcies = dictionary[UserController.kBankruptcies] as? Int16 ?? 0
        self.criminalHistory = dictionary[UserController.kCriminalHistory] as? String ?? ""
        self.driversLicenceNum = dictionary[UserController.kDriversLicenseNumber] as? String ?? ""
        self.driversLicensePicURL = dictionary[UserController.kDriversLicensePicURL] as? String ?? ""
        self.evictionHistory = dictionary[UserController.kEvictionHistory] as? String ?? ""
        self.income = dictionary[UserController.kIncome] as? Float ?? 0
        self.isStudent = dictionary[UserController.kIsStudent] as? Bool ?? false
        self.isVerified = dictionary[UserController.kIsVerified] as? Bool ?? false
        self.previousAddress = dictionary[UserController.kPreviousAddress] as? String ?? ""
        self.reasonForLeaving = dictionary[UserController.kReasonsForLeaving] as? String ?? ""
        self.school = dictionary[UserController.kSchool] as? String ?? ""
        self.studentID = dictionary[UserController.kStudentID] as? String ?? ""
        self.studentPhotoIDURL = dictionary[UserController.kStudentPhotoIdURL] as? String ?? ""
    }
    
    @discardableResult convenience init?(isEmpty: Bool, context: NSManagedObjectContext? = CoreDataStack.context) {
        
        if let context = context {
            self.init(context: context)
        } else {
            self.init(entity: Renter.entity(), insertInto: nil)
        }
        
        UserController.currentUserID = ""
        
        self.wantedZipCode = "84604"
        self.wantedCity = ""
        self.wantedState = ""
        self.wantedCountry = ""
        self.wantsPetFriendly = false
        self.wantedPayment = 3000
        self.wantedBedroomCount = 1
        self.wantedBathroomCount = 1
        self.withinRangeMiles = 50
        self.wantsSmoking = false
        self.wantsWasherDryer = false
        self.wantsGarage = false
        self.wantsDishwasher = false
        self.wantsBackyard = false
        self.wantsPool = false
        self.wantsGym = false
    }
}
