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
        guard let firstName = firstName, let lastName = lastName, let email = email, let wantsCreditRating = wantsCreditRating /*, let id = id, let birthday = birthday */ else { return nil }
        
        return [UserController.kFirstName: firstName, UserController.kLastName: lastName, UserController.kEmail: email, UserController.kWantsCreditRating: wantsCreditRating]
    }
    
    
}
