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
        lblNameOfPersonMessging.text = renter.firstName
    }
    
    override func sendMessage(messageText: String, completion: @escaping (_ success: Bool) -> Void) {
        guard
            let landlord = self.landlord,
            let landlordID = landlord.id,
//            let landlordFName = landlord.firstName,
//            let landlordLName = landlord.lastName,
            let property = self.property,
            let propertyID = property.propertyID,
            let propertyName = property.propertyDescription,
            let renterID = renter.id else {
            return
        }
        
//        let landlordName = "\(landlordFName) \(landlordLName)"
        
        NotificationController.sendNotificationToUser(message: messageText, toUser: renterID, fromUser: landlordID, fromUserName: propertyName, forProperty: propertyID)
        
        Message(message: messageText, toUserID: renterID, fromUserID: landlordID, fromUserName: propertyName, forPropertyID: propertyID)
        
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
        
        let allMessages = Message.getAllMessages()
        
        messages = allMessages.filter({ $0.forPropertyID == propertyID && ($0.fromUserID == renterID || $0.toUserID == renterID) })
        
        return messages
    }
    
    // MARK: collectionview
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.messages = self.getMessages()
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.CollectionViewCells.MessageCell.rawValue, for: indexPath) as! MessageCollectionViewCell
        
        let message = messages[indexPath.row]
        
        cell.txtvwMessage.text = message.message
        styleMessageTextView(forCell: cell, withMessage: message)
        setMessageImage(forCell: cell)
        
        if indexPath.row == (messages.count - 1) {
            lastCollectionViewItemIndexPath = indexPath
        }
        
        return cell
    }
    
    // MARK: collectionview helper functions
    
    private func setMessageImage(forCell cell: MessageCollectionViewCell) {
        var profilePicture: UIImage?
        if let firstProfileImage = renter.profileImages?.firstObject as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePic = UIImage(data: imageData as Data) {
            profilePicture = profilePic
        } else {
            log("ERROR: couldn't load a profile image")
            profilePicture = #imageLiteral(resourceName: "noImageProfile90x90")
        }
        cell.imgSender.image = profilePicture
        cell.imgSender.layer.cornerRadius = cell.imgSender.frame.width / 2
    }
}
