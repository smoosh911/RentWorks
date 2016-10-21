//
//  Landlord + Convenience.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import CoreData

extension Landlord {
    
    @discardableResult convenience init?(email: String, firstName: String, lastName: String, id: String, starRating: Double = 5.0, context: NSManagedObjectContext = CoreDataStack.context) {
        
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Landlord", in: context) else { return nil }
        
        self.init(entity: entity, insertInto: context)
        
        
        self.birthday = birthday
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.starRating = starRating
    }
    
    @discardableResult convenience init?(dictionary: [String: Any], id: String, context: NSManagedObjectContext = CoreDataStack.context) {
        guard let email = dictionary[UserController.kEmail] as? String,
            let firstName = dictionary[UserController.kFirstName] as? String,
            let lastName = dictionary[UserController.kLastName] as? String else { return nil }

        
        self.init(context: context)
        
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        // TODO: - Change this later
        self.starRating = 5.0
    }
    
}
