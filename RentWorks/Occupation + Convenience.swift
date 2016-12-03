//
//  Occupation + Convenience.swift
//  RentWorks
//
//  Created by Michael Perry on 12/2/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import CoreData

extension Occupation {
    @discardableResult convenience init?(occupation: String, landlordOrRenter: Any, context: NSManagedObjectContext? = CoreDataStack.context) {
        
        if let context = context {
            self.init(context: context)
        } else {
            self.init(entity: HasBeenViewedBy.entity(), insertInto: nil)
        }
        // TODO: - Change this to not a static value
        
        if let landlord = landlordOrRenter as? Landlord {
            self.user = landlord
        } else if let renter = landlordOrRenter as? Renter {
            self.user = renter
        }
        
        self.title = occupation
    }
}
