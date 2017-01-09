//
//  MessageCollectionViewCell.swift
//  RentWorks
//
//  Created by Michael Perry on 1/7/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation

class MessageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var vwMessage: UIView!
    @IBOutlet weak var txtvwMessage: UITextView!
    @IBOutlet weak var imgSender: UIImageView!
    
    @IBOutlet weak var cnstrntTxtVwLeft: NSLayoutConstraint!
    @IBOutlet weak var cnstrntTxtVwRight: NSLayoutConstraint!
    
    // MARK: variables
    
    var currentUserSentMessage = false
    
    // MARK: life cycles
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        if currentUserSentMessage {
//            imgSender.isHidden = true
//            txtvwMessage.textAlignment = .right
//            txtvwMessage.backgroundColor = AppearanceController.vengaYellowColor
//            cnstrntTxtVwLeft.constant = (self.frame.width * 0.2)
//            cnstrntTxtVwRight.constant = 8
//        } else {
//            imgSender.isHidden = false
//            txtvwMessage.textAlignment = .left
//            txtvwMessage.backgroundColor = UIColor(white: 0.95, alpha: 1)
//            cnstrntTxtVwRight.constant = (self.frame.width * 0.2)
//            cnstrntTxtVwLeft.constant = 8
//        }
//    }
}
