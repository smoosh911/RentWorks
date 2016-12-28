//
//  RenterSettingsViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/21/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class RenterSettingsViewController: SettingsViewController {
    
    // MARK: outlets
    
    @IBOutlet weak var settingsTVCContainerView: UIView!
    @IBOutlet weak var lblOccupation: UILabel!
    
    // MARK: variables
    
    var settingsTVC: RenterSettingsContainerTableViewController?
    
    weak var delegate: UpdateSettingsDelegate?
    
    let renter = UserController.currentRenter
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let profileImages = UserController.currentRenter? .profileImages?.array as? [ProfileImage] else { return }
        
        if let imageData = profileImages[0].imageData as? Data, let image = UIImage(data: imageData) {
            imgviewProfilePic.image = image
        }
        
        lblUserName.text = "\(UserController.currentRenter!.firstName!) \(UserController.currentRenter!.lastName!)"
        
        let filterSettingsDict = RenterController.getRenterFiltersDictionary()
        let kCurrentOccupation = UserController.RenterFilters.kCurrentOccupation
        guard let occupation = filterSettingsDict[kCurrentOccupation.rawValue] as? String else { return }
        
        lblOccupation.text = occupation
        
    }
    
    
    @IBAction func btnSubmitChanges_TouchedUpInside(_ sender: Any) {
        guard let id = UserController.currentUserID, let renter = renter, let settingsTVC = settingsTVC else { return }
        
        let zipcode = settingsTVC.txtfldZipCode.text!
        
        renter.wantedZipCode = zipcode
        RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: settingsTVC.filterKeys.kZipCode.rawValue, newValue: zipcode)
        self.delegate?.updateSettings()
        // UserController.saveToPersistentStore()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SettingsTVCEmbed" {
            if let settingsTVC = segue.destination as? RenterSettingsContainerTableViewController {
                self.settingsTVC = settingsTVC
            }
        }
    }
}


protocol UpdateSettingsDelegate: class {
    func updateSettings()
}
