//
//  ProfileImage+Convenience.swift
//  
//
//  Created by Spencer Curtis on 10/17/16.
//
//

import Foundation
import CoreData

extension ProfileImage {
    
    @discardableResult convenience init?(userID: String, imageData: NSData, renter: Renter?, property: Property?, imageURL: String, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        
        self.userID = userID
        self.imageData = imageData
        self.imageURL = imageURL
        
        if property != nil {
            self.property = property
        } else if renter != nil {
            self.renter = renter
        }
    }
}
