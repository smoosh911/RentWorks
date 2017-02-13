//
//  LandlordSettingsViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import CoreData

class LandlordSettingsViewController: SettingsViewController {
    
    // MARK: outlets

    @IBOutlet weak var propertyCountLabel: UILabel!
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let landlord = UserController.currentLandlord,
            let profileImages = landlord.profileImages?.array as? [ProfileImage],
            let firstName = landlord.firstName,
            let lastName = landlord.lastName,
            let propertyCount = landlord.property?.count else {
            return
        }
        
        if let profileImage = profileImages.first, let imageData = profileImage.imageData as? Data, let image = UIImage(data: imageData) {
            imgviewProfilePic.image = image
        }
        
        propertyCountLabel.text = "Properties: \(propertyCount)"
        lblUserName.text = "\(firstName) \(lastName)"
    }
}
