//
//  RenterMessagingViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 1/7/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation

class RenterMessagingViewController: MessagingViewController {
    
    // MARK: outlet
    
    @IBOutlet weak var lblLandlordName: UILabel!
    
    // MARK: variables
    
    var renter: Renter?
    var property: Property!
    
    var landlord: Landlord?
    var landlordImage: UIImage?
    
    // MARK: life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblNameOfPersonMessging.text = property.propertyDescription
        
        guard let landlordID = property.landlordID else {
            return
        }
        
        getLandlord(landlordID: landlordID) { (landlord) in
            guard let landlord = landlord, let firstName = landlord.firstName, let lastName = landlord.lastName else {
                return
            }
            self.landlordImage = self.getLandlordImage(landlord: landlord)
            self.lblLandlordName.text = "You are now chatting with \(firstName) \(lastName)"
            self.clcvwMessages.reloadData()
        }
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
        
        let allMessages = Message.getAllMessages()
        
        messages = allMessages.filter({ $0.forPropertyID == propertyID && ($0.fromUserID == landlordID || $0.toUserID == landlordID) })
        
        return messages
    }
    
    private func getLandlordImage(landlord: Landlord) -> UIImage? {
        var profilePicture: UIImage?
        if let firstProfileImage = landlord.profileImages?.firstObject as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePic = UIImage(data: imageData as Data) {
            profilePicture = profilePic
        } else {
            log("ERROR: couldn't load a profile image")
        }
        return profilePicture
    }
    
    private func getLandlord(landlordID: String, completion: @escaping (_ landlord: Landlord?) -> Void) {
        LandlordController.fetchLandlordWithOneImageFor(landlordID: landlordID) { (landlord) in
            completion(landlord)
        }
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
//        if let image = landlordImage {
//            cell.imgSender.image = image
//        }
//        var profilePicture: UIImage?
//        if let firstProfileImage = property.profileImages?.firstObject as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePic = UIImage(data: imageData as Data) {
//            profilePicture = profilePic
//        } else {
//            log("ERROR: couldn't load a profile image")
//        }
        if let image = landlordImage {
            cell.imgSender.image = image
        }
        cell.imgSender.layer.cornerRadius = cell.imgSender.frame.width / 2
    }
}
