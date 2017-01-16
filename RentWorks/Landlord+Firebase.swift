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

        var dictionaryRepresentation: [String: Any] = [UserController.kFirstName: firstName,
                                                       UserController.kLastName: lastName,
                                                       UserController.kEmail: email,
                                                       UserController.kWantsCreditRating: wantsCreditRating,
                                                       UserController.kWithinRangeMiles: withinRangeMiles]
        
        guard let profileImageArray = self.profileImages?.array as? [ProfileImage] else { return dictionaryRepresentation }
        
        let imageURLs = profileImageArray.flatMap({$0.imageURL})
        
        dictionaryRepresentation[UserController.kImageURLS] = imageURLs
        
        return dictionaryRepresentation
    }
}
