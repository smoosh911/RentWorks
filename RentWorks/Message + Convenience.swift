//
//  Message + Convenience.swift
//  RentWorks
//
//  Created by Michael Perry on 1/7/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation
import CoreData

extension Message {
    @discardableResult convenience init?(message: String, toUserID: String, fromUserID: String, fromUserName: String, forPropertyID: String, context: NSManagedObjectContext? = CoreDataStack.messagingContext) {
        
        if let context = context {
            self.init(context: context)
        } else {
            self.init(entity: Message.entity(), insertInto: nil)
        }
        
        self.message = message
        self.toUserID = toUserID
        self.fromUserID = fromUserID
        self.forPropertyID = forPropertyID
        self.timeDateSent = NSDate()
    }
    
    static internal func getAllMessages() -> [Message] {
        do {
            guard let allMessages = try CoreDataStack.context.fetch(Message.fetchRequest()) as? [Message] else {
                return []
            }
            return allMessages
        } catch let e {
            log(e)
        }
        return []
    }
}
