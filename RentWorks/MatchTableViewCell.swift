//
//  MatchTableViewCell.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/14/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class MatchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var renter: Renter?
    var property: Property?
    
    
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
        self.addressLabel.text = renter?.address ?? "No address available."
        
        guard let imageData = (property.profileImages?.firstObject as? ProfileImage)?.imageData else { return }
        self.profileImageView.image = UIImage(data: imageData as Data)
        
        setupCell()
    }
    
    func setupCell() {
        profileImageView.layer.cornerRadius = 36.5
        profileImageView.clipsToBounds = true
    }
    
    
}
