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
    
//    var landlordImage: UIImage?
    
    // MARK: life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblNameOfPersonMessging.text = property.propertyDescription
//        getLandlordImage()
    }
    
    override func sendMessage(messageText: String, completion: @escaping (_ success: Bool) -> Void) {
        guard
            let property = self.property,
            let propertyID = property.propertyID,
            let landlordID = property.landlordID,
            let renter = self.renter,
            let renterID = renter.id,
            let renterFName = renter.firstName,
            let renterLName = renter.lastName else {
            return
        }
        
        let renterName = "\(renterFName) \(renterLName)"
        
        NotificationController.sendNotificationToUser(message: messageText, toUser: landlordID, fromUser: renterID, fromUserName: renterName, forProperty: propertyID)
        
        Message(message: messageText, toUserID: landlordID, fromUserID: renterID, fromUserName: renterName, forPropertyID: propertyID)
        
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
    // needs work: get landlord image from firebase
//    private func getLandlordImage() {
//        guard let landlordID = property.landlordID else {
//            return
//        }
//        LandlordController.getLandlordWithID(landlordID: landlordID) { (landlord) in
//            var profilePicture: UIImage?
//            if let landlord = landlord, let firstProfileImage = landlord.profileImages?.firstObject as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePic = UIImage(data: imageData as Data) {
//                profilePicture = profilePic
//            } else {
//                log("ERROR: couldn't load a profile image")
//            }
//            self.landlordImage = profilePicture
//        }
//    }
//    
    private func setMessageImage(forCell cell: MessageCollectionViewCell) {
//        if let image = landlordImage {
//            cell.imgSender.image = image
//        }
        var profilePicture: UIImage?
        if let firstProfileImage = property.profileImages?.firstObject as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePic = UIImage(data: imageData as Data) {
            profilePicture = profilePic
        } else {
            log("ERROR: couldn't load a profile image")
        }
        cell.imgSender.image = profilePicture
        cell.imgSender.layer.cornerRadius = cell.imgSender.frame.width / 2
    }
}
