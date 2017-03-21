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
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var txtfldBio: UITextView!
    @IBOutlet weak var txtfldFirstName: UITextField!
    @IBOutlet weak var txtfldLastName: UITextField!
    @IBOutlet weak var txtfldEmail: UITextField!
    @IBOutlet weak var lblPropertiesCount: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnSignOut: UIButton!
    @IBOutlet weak var btnAppInfo: UIButton!
    
    var isEditMode: Bool = false
    
     // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setProfileInfo()
    }
    
    @IBAction func editBtnTapped(_ sender: Any) {
        var enabledColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)
        var disabledColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:0.5)
        
        if(!isEditMode) {
            setTxtfldEnabled(isEnabled: true)
            btnEdit.setTitle("Save",for: .normal)
            lblPropertiesCount.textColor = disabledColor
            
            //disable signout and app info buttons
            btnSignOut.isEnabled = false
            btnAppInfo.isEnabled = false
            btnSignOut.setTitleColor(disabledColor, for: .normal)
            btnAppInfo.setTitleColor(disabledColor, for: .normal)

            isEditMode = true
            
        } else {
            setTxtfldEnabled(isEnabled: false)
            btnEdit.setTitle("Edit",for: .normal)
            updateLandlordSettings()
            lblPropertiesCount.textColor = enabledColor
            
            //enable signout and app info buttons
            btnSignOut.isEnabled = true
            btnAppInfo.isEnabled = true
            btnSignOut.setTitleColor(enabledColor, for: .normal)
            btnAppInfo.setTitleColor(enabledColor, for: .normal)

            
            isEditMode = false
        }
        
    }
    
    private func setTxtfldEnabled(isEnabled:Bool) {
        txtfldFirstName.isUserInteractionEnabled = isEnabled
        txtfldLastName.isUserInteractionEnabled = isEnabled
        txtfldLastName.isUserInteractionEnabled = isEnabled
        txtfldEmail.isUserInteractionEnabled = isEnabled
        txtfldBio.isUserInteractionEnabled = isEnabled
    }
    
    private func updateLandlordSettings() {
        guard let landlord = UserController.currentLandlord, let id = landlord.id else {
            AlertManager.alert(withTitle: "Not Logged In", withMessage: "Must log in to use filters", dismissTitle: "OK", inViewController: self)
            return
        }
        
        let firsName = txtfldFirstName.text
        landlord.firstName = firsName
        LandlordController.updateCurrentLandlordInFirebase(id: id, attributeToUpdate: UserController.kFirstName, newValue: firsName!)
        
        let lastName = txtfldLastName.text
        landlord.lastName = lastName
        LandlordController.updateCurrentLandlordInFirebase(id: id, attributeToUpdate: UserController.kLastName, newValue: lastName!)
        
        let email = txtfldFirstName.text
        landlord.email = email
        LandlordController.updateCurrentLandlordInFirebase(id: id, attributeToUpdate: UserController.kEmail, newValue: email!)
        
        //let bio = txtfldBio.text
        //landlord.bio = firsName
        //LandlordController.updateCurrentLandlordInFirebase(id: id, attributeToUpdate: UserController.kFirstName, newValue: firsName!)
        
        //SettingsViewController.settingsDidChange = true
        
    }

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
        
        txtfldFirstName.text = firstName
        txtfldLastName.text = lastName
        txtfldEmail.text = email
        lblPropertiesCount.text = "Properties: \(propertyCount.description)"
        txtfldBio.text = "Venga's next update will allow me to put a bio here to describe what an awesome landlord I will be!"
    }
    
    
}
