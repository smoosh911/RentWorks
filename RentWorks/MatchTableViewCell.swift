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
        // Initialization code
    }
    
    var user: TestUser?
    
    
    func updateWith(user: TestUser) {
        self.user = user
        
        self.nameLabel.text = user.name
        self.addressLabel.text = user.address
        self.profileImageView.image = user.profilePic
        
        setupCell()
    }
    
    func setupCell() {
        profileImageView.layer.cornerRadius = 36.5
        profileImageView.clipsToBounds = true
    }
    
    
}
