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
        guard
            let property = self.property,
            let propertyID = property.propertyID,
            let landlordID = property.landlordID,
            let renter = self.renter,
            let renterID = renter.id else {
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
    
    // MARK: helper functions
    
    private func getMessages() -> [Message] {
        
        guard
            let property = self.property,
            let propertyID = property.propertyID,
            let landlordID = property.landlordID else {
            return []
        }
        
        let allMessages = getAllMessages()
        
        messages = allMessages.filter({ $0.forPropertyID == propertyID && ($0.fromUserID == landlordID || $0.toUserID == landlordID) })
        
        return messages
    }
    
    // MARK: collectionview
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.messages = self.getMessages()
        return messages.count
    }
}
