//
//  TestUser.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/7/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class TestUser: Equatable {
    private let kID = "id"
    private let kFirebaseID = "uuid"
    private let kName = "name"
    private let kEmail = "email"
    private let kAddress = "address"
    
    var name: String
    var email: String
    var id: String
    var address: String?
    var profilePic: UIImage?
    
    init(name: String, email: String, address: String = "1234 S Testing Road, MockTown, UT, 84321", id: String, profilePic: UIImage? = nil) {
        self.name = name
        self.email = email
        self.address = address
        self.id = id
        self.profilePic = profilePic
    }
    
    // Facebook failable initializer
    
    init?(facebookDictionary: [String: Any]) {
        guard let id = facebookDictionary[kID] as? String,
            let name = facebookDictionary[kName] as? String,
            let email = facebookDictionary[kEmail] as? String
            else { return nil }
        
        self.name = name
        self.email = email
        self.id = id
    }
    
    init?(dictionary: [String: Any], id: String) {
        guard let name = dictionary[kName] as? String,
            let email = dictionary[kEmail] as? String,
            let address = dictionary[kAddress] as? String
            else { return nil }
        
        self.name = name
        self.email = email
        self.id = id
        self.address = address
    }
    var dictionaryRepresentation: [String: String] {
        return [kName: name, kEmail: email, kAddress: address ?? "No address"]
    }
}


func ==(lhs: TestUser, rhs: TestUser) -> Bool {
    return lhs.id == rhs.id
}
