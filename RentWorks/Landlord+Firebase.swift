//
//  Landlord+Firebase.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

extension Landlord {
    
    var dictionaryRepresentation: [String: Any]? {
        guard let firstName = firstName,
            let lastName = lastName,
            let email = email,
            let wantsCreditRating = wantsCreditRating /*, let id = id, let birthday = birthday */
            else { return nil }

        var dictionaryRepresentation: [String: Any] = [:]
        
        dictionaryRepresentation[UserController.kFirstName] = firstName
        dictionaryRepresentation[UserController.kLastName] = lastName
        dictionaryRepresentation[UserController.kEmail] = email
        dictionaryRepresentation[UserController.kWantsCreditRating] = wantsCreditRating
        dictionaryRepresentation[UserController.kWithinRangeMiles] = withinRangeMiles
        dictionaryRepresentation[UserController.kPhoneNumber] = phoneNumber
        dictionaryRepresentation[UserController.kDateAdded] = dateAdded ?? Date().timeIntervalSince1970
        
        guard let profileImageArray = self.profileImages?.array as? [ProfileImage] else { return dictionaryRepresentation }
        
        let imageURLs = profileImageArray.flatMap({$0.imageURL})
        
        dictionaryRepresentation[UserController.kImageURLS] = imageURLs
        
        return dictionaryRepresentation
    }
}
