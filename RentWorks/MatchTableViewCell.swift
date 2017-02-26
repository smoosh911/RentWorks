//
//  MatchTableViewCell.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/14/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import MessageUI

protocol MatchTableViewCellDelegate {
    func presentDetailView(selectedCell: MatchTableViewCell)
}

class MatchTableViewCell: UITableViewCell {
    
    // MARK: outlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lblLastMessage: UILabel!
    @IBOutlet weak var lblTimeOfLastMessage: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var btnViewDetails: UIButton!
    @IBOutlet weak var imgChatBadge: UIImageView!
    
    // MARK: variables
    
    var renter: Renter?
    var property: Property?
    
    var matchesDelegate: Any?
    
    // MARK: life cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setChatBadgeImage()
    }
    
    // MARK: actions
    
    @IBAction func btnViewDetails_TouchedUpInside(_ sender: UIButton) {
        if let matchesDelegate = matchesDelegate as? MatchTableViewCellDelegate {
            matchesDelegate.presentDetailView(selectedCell: self)
            self.matchViewed()
        }
    }
    
    // MARK: helper functions
    
    private func matchViewed() {
        if let renter = renter, let renterID = renter.id {
            var matchedRenterIDs: [String] = []
            if let existingMatchedRenterIDs = UserDefaults.standard.array(forKey: Identifiers.UserDefaults.propertyMatchedRenterIDs.rawValue) as? [String] {
                matchedRenterIDs.append(contentsOf: existingMatchedRenterIDs)
            }
            if !matchedRenterIDs.contains(renterID) {
                matchedRenterIDs.append(renterID)
            }
            UserDefaults.standard.set(matchedRenterIDs, forKey: Identifiers.UserDefaults.propertyMatchedRenterIDs.rawValue)
        } else if let property = property, let propertyID = property.propertyID {
            var matchedPropertyIDs: [String] = []
            if let existingMatchedPropertyIDs = UserDefaults.standard.array(forKey: Identifiers.UserDefaults.renterMatchedPropertiesIDs.rawValue) as? [String] {
                matchedPropertyIDs.append(contentsOf: existingMatchedPropertyIDs)
            }
            if !matchedPropertyIDs.contains(propertyID){
                matchedPropertyIDs.append(propertyID)
            }
            UserDefaults.standard.set(matchedPropertyIDs, forKey: Identifiers.UserDefaults.renterMatchedPropertiesIDs.rawValue)
        }
        setChatBadgeImage()
    }
    
    private func setChatBadgeImage() {
        if showGrayChatBadge() {
            imgChatBadge.image = #imageLiteral(resourceName: "popup-gray-blip-icon")
        } else {
            imgChatBadge.image = #imageLiteral(resourceName: "popup-yellow-blip-icon")
        }
    }
    
    private func showGrayChatBadge() -> Bool {
        if let renter = renter, let renterID = renter.id {
            guard let matchedRenterIDs: [String] = UserDefaults.standard.array(forKey: Identifiers.UserDefaults.propertyMatchedRenterIDs.rawValue) as? [String] else {
                return false
            }
            return matchedRenterIDs.contains(renterID)
        } else if let property = property, let propertyID = property.propertyID {
            guard let matchedPropertyIDs: [String] = UserDefaults.standard.array(forKey: Identifiers.UserDefaults.renterMatchedPropertiesIDs.rawValue) as? [String] else {
                return false
            }
            return matchedPropertyIDs.contains(propertyID)
        }
        return true
    }
    
    func updateWith(renter: Renter, property: Property) {
        setupCell()
        
        self.renter = renter
        
        self.nameLabel.text = "\(renter.firstName ?? "No name available") \(renter.lastName ?? "")"
        
        guard let imageData = (renter.profileImages?.firstObject as? ProfileImage)?.imageData else { return }
        self.profileImageView.image = UIImage(data: imageData as Data)
        
        guard let lastMessage = getLastMessage(renter: renter, property: property) else {
            self.lblLastMessage.text = ""
            self.lblTimeOfLastMessage.text = ""
            return
        }
        setCellLastMessageInfo(message: lastMessage)
    }
    
    func updateWith(property: Property) {
        setupCell()
        
        self.property = property
        
        self.nameLabel.text = property.propertyDescription ?? "No description available"
        
        guard let imageData = (property.profileImages?.firstObject as? ProfileImage)?.imageData else { return }
        self.profileImageView.image = UIImage(data: imageData as Data)
        
        guard let lastMessage = getLastMessage(property: property) else {
            self.lblLastMessage.text = ""
            self.lblTimeOfLastMessage.text = ""
            return
        }
        setCellLastMessageInfo(message: lastMessage)
    }
    
    private func setupCell() {
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.clipsToBounds = true
        
        imgChatBadge.layer.cornerRadius = imgChatBadge.bounds.width / 2
    }
    
    private func setCellLastMessageInfo(message: Message) {
        self.lblLastMessage.text = message.message
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "am"
        dateFormatter.pmSymbol = "pm"
        let dateString = dateFormatter.string(from: message.timeDateSent as! Date)
        self.lblTimeOfLastMessage.text = dateString
    }
    
    private func getLastMessage(property: Property) -> Message? {
        
        guard
            let propertyID = property.propertyID,
            let landlordID = property.landlordID else {
                return nil
        }
        
        let allMessages = Message.getAllMessages()
        
        let messages = allMessages.filter({ $0.forPropertyID == propertyID && ($0.fromUserID == landlordID || $0.toUserID == landlordID) })
        
        if messages.count > 0 {
            return messages.last!
        } else {
            return nil
        }
    }
    
    private func getLastMessage(renter: Renter, property: Property) -> Message? {
        
        guard
            let propertyID = property.propertyID,
            let renterID = renter.id else {
                return nil
        }
        
        let allMessages = Message.getAllMessages()
        
        let messages = allMessages.filter({ $0.forPropertyID == propertyID && ($0.fromUserID == renterID || $0.toUserID == renterID) })
        
        if messages.count > 0 {
            return messages.last!
        } else {
            return nil
        }
    }
}
