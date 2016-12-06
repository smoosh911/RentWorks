//
//  HasBeenViewedBy + Convenience.swift
//  RentWorks
//
//  Created by Michael Perry on 11/25/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import CoreData

extension HasBeenViewedBy {
    @discardableResult convenience init?(hasBeenViewedByID: String, propertyOrRenter: Any, context: NSManagedObjectContext? = CoreDataStack.context) {
        
        if let context = context {
            self.init(context: context)
        } else {
            self.init(entity: HasBeenViewedBy.entity(), insertInto: nil)
        }
        // TODO: - Change this to not a static value
        
        if let property = propertyOrRenter as? Property {
            self.property = property
        } else if let renter = propertyOrRenter as? Renter {
            self.renter = renter
        }
        
        self.viewerID = hasBeenViewedByID
    }
}
