//
//  TestUser.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/7/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class TestUser {
    private let kID = "id"
    private let kFirebaseID = "uuid"
    private let kName = "name"
    private let kEmail = "email"
    
    var name: String
    var email: String
    var id: String
    var profilePic: UIImage?
    
    init(name: String, email: String, id: String, profilePic: UIImage? = nil) {
        self.name = name
        self.email = email
        self.profilePic = profilePic
        self.id = id
    }
    
    init?(dictionary: [String: Any]) {
        guard let id = dictionary[kID] as? String,
            let name = dictionary[kName] as? String,
            let email = dictionary[kEmail] as? String
            else { return nil }
        
        self.name = name
        self.email = email
        self.id = id
    }
    
    init?(dictionary: [String: Any], id: String) {
        guard let name = dictionary[kName] as? String,
            let email = dictionary[kEmail] as? String
            else { return nil }
        
        self.name = name
        self.email = email
        self.id = id
    }
    var dictionaryRepresentation: [String: String] {
        return ["name": name, "email": email]
    }
    
}
