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
    
    @discardableResult convenience init?(userID: String, imageData: NSData, user: Any?, property: Property?, imageURL: String, context: NSManagedObjectContext? = CoreDataStack.context) {
    
        if let context = context {
            self.init(context: context)
        } else {
            self.init(entity: ProfileImage.entity(), insertInto: nil)
        }
        
        self.userID = userID
        self.imageData = imageData
        self.imageURL = imageURL
        
        if property != nil {
            self.property = property
        } else if let renter = user as? Renter {
            self.renter = renter
        } else if let landlord = user as? Landlord {
            self.landlord = landlord
        } else {
            log("ERROR: couldn't create profile image")
        }
    }
}
