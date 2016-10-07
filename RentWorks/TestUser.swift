//
//  TestUser.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/7/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class TestUser {
    
    private static let kName = "name"
    private static let kEmail = "email"
    
    var name: String
    var email: String
    var profilePic: UIImage?
    
    init(name: String, email: String, profilePic: UIImage?) {
        self.name = name
        self.email = email
        self.profilePic = profilePic
    }
    
    var dictionaryRepresentation: [String: Any] {
        return [TestUser.kName: name, TestUser.kEmail: email]
    }
    
}
