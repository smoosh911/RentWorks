//
//  RenterMessagingViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 1/7/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation

class RenterMessagingViewController: MessagingViewController {
    
    // MARK: variables
    
    var renter: Renter?
    var property: Property!
    
    // MARK: life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func sendMessage(messageText: String, completion: @escaping (_ success: Bool) -> Void) {
        guard let property = self.property, let propertyID = property.propertyID, let landlordID = property.landlordID, let renter = self.renter, let renterID = renter.id else {
            return
        }
        
        NotificationController.sendNotificationToUser(message: messageText, toUser: landlordID, fromUser: renterID, forProperty: propertyID)
        
        Message(message: messageText, toUserID: landlordID, fromUserID: renterID, forPropertyID: propertyID)
        
        do {
            try CoreDataStack.messagingContext.save()
        } catch let e {
            completion(false)
            log(e)
        }
        completion(true)
    }
}
