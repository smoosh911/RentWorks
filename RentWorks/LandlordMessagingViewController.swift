//
//  LandlordMessagingViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 1/7/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation

class LandlordMessagingViewController: MessagingViewController {
    
    // MARK: variables
    
    var renter: Renter!
    var property: Property!
    var landlord: Landlord?
    
    // MARK: life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let landlord = UserController.currentLandlord else {
            return
        }
        
        self.landlord = landlord
    }
    
    override func sendMessage(messageText: String, completion: @escaping (_ success: Bool) -> Void) {
        guard
            let landlord = self.landlord,
            let landlordID = landlord.id,
            let property = self.property,
            let propertyID = property.propertyID,
            let renterID = renter.id else {
            return
        }
        
        NotificationController.sendNotificationToUser(message: messageText, toUser: renterID, fromUser: landlordID, forProperty: propertyID)
        
        Message(message: messageText, toUserID: renterID, fromUserID: landlordID, forPropertyID: propertyID)
        
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
            let renterID = renter.id else {
            return []
        }
        
        let allMessages = getAllMessages()
        
        messages = allMessages.filter({ $0.forPropertyID == propertyID && ($0.fromUserID == renterID || $0.toUserID == renterID) })
        
        return messages
    }
    
    // MARK: collectionview
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.messages = self.getMessages()
        return messages.count
    }
}
