//
//  LandlordSettingsViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import CoreData

class LandlordSettingsViewController: SettingsViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var propertyCountLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var bioTextView: UITextView!
    var profileItems: [String] = []
    
     // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfileInfo()
    }
    
    
    // MARK tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileItems.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        cell.textLabel?.text = profileItems[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print ("here")
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! PropertiesHeaderCell
//        headerCell.lblTitle.text = ""
//        return headerCell
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30
//    }
    
    
    // MARK helper functions 
    
    private func setProfileInfo() {
        guard let landlord = UserController.currentLandlord,
            let firstProfileImage = landlord.profileImages?.firstObject as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePic = UIImage(data: imageData as Data),
            let firstName = landlord.firstName,
            let lastName = landlord.lastName,
            let email = landlord.email,
            let propertyCount = landlord.property?.count else {
                return
        }
        
        // set profile image and convert to circle
        profileImageView.image = profilePic
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        
        profileItems.append(firstName)
        profileItems.append(lastName)
        profileItems.append(email)
        profileItems.append("Properties: " + propertyCount.description)
//        bioTextView.text = "This is where I would write my bio and talk a little about myself"
    
//        lblUserName.text = "\(firstName) \(lastName)"
    }
    
    
}
