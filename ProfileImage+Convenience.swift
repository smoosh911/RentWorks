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
    
    @discardableResult init?(userID: String, imageData: Data, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        
        self.userID = userID
        self.imageData = imageData
    }
}
