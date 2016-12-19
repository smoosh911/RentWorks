//
//  MatchTableViewCell.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/14/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import MessageUI

class MatchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var contactButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var renter: Renter?
    var property: Property?
    
    weak var delegate: ContactEmailDelegate?
    
    @IBAction func contactButtonTapped(_ sender: AnyObject) {
        let mailComposeVC = MFMailComposeViewController()
        
        //        mailComposeVC.navigationBar.barTintColor = UIColor.orange
        guard MFMailComposeViewController.canSendMail() else { /* present alert to say they can't send email */ return }
        mailComposeVC.view.tintColor = AppearanceController.vengaYellowColor
        if let renter = renter {
            guard let email = renter.email else { return }
            mailComposeVC.setToRecipients([email])
            mailComposeVC.setSubject("We matched on Venga!")
            delegate?.present(emailComposeVC: mailComposeVC)
        } else if let property = property {
            // Fix this fetching later to pull the landlord from CoreData when they actually have that relationship.
            if let email = property.landlord?.email {
                mailComposeVC.setToRecipients([email])
                mailComposeVC.setSubject("We matched on Venga!")
                delegate?.present(emailComposeVC: mailComposeVC)
            } else {
                FirebaseController.getLandlordFor(property: property, completion: { (landlord) in
                    guard let landlord = landlord, let email = landlord.email else { return }
                    mailComposeVC.setToRecipients([email])
                    mailComposeVC.setSubject("We matched on Venga!")
                    self.delegate?.present(emailComposeVC: mailComposeVC)
                })
            }
        }
    }
    
    func createEmailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        sendMailErrorAlert.addAction(dismissAction)
        
        delegate?.present(emailErrorAlert: sendMailErrorAlert)
    }
    
    func updateWith(renter: Renter) {
        self.renter = renter
        
        
        self.nameLabel.text = "\(renter.firstName ?? "No name available") \(renter.lastName ?? "")"
        self.addressLabel.text = renter.bio ?? "No bio yet!"
        
        guard let imageData = (renter.profileImages?.firstObject as? ProfileImage)?.imageData else { return }
        self.profileImageView.image = UIImage(data: imageData as Data)
        
        setupCell()
    }
    
    func updateWith(property: Property) {
        self.property = property
        
        self.nameLabel.text = property.propertyDescription ?? "No description available"
        self.addressLabel.text = property.address ?? "No address available."
        
        guard let imageData = (property.profileImages?.firstObject as? ProfileImage)?.imageData else { return }
        self.profileImageView.image = UIImage(data: imageData as Data)
        
        setupCell()
    }
    
    func setupCell() {
        profileImageView.layer.cornerRadius = 36.5
        profileImageView.clipsToBounds = true
        
        contactButton.layer.borderColor = AppearanceController.vengaYellowColor.cgColor
        contactButton.layer.cornerRadius = 4
        contactButton.layer.borderWidth = 0.4
    }
}

protocol ContactEmailDelegate: class {
    func present(emailComposeVC: MFMailComposeViewController)
    func present(emailErrorAlert: UIAlertController)
}
