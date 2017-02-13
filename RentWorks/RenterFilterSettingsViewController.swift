//
//  RenterFilterSettingsViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 1/29/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation

protocol RenterFilterSettingsModalViewControllerDelegate {
    func viewDismissed()
}

protocol RenterFilterSettingsViewControllerDelegate: class {
    func updateSettings()
}

class RenterFilterSettingsViewController: UIViewController {
    
    // MARK: outlets
    
    
    // MARK: variables
    
    var settingsTVC: RenterSettingsContainerTableViewController?
    
    weak var delegate: RenterFilterSettingsViewControllerDelegate?
    var modalViewDelegate: RenterFilterSettingsModalViewControllerDelegate?
    
    let renter = UserController.currentRenter
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        modalViewDelegate?.viewDismissed()
    }
    
    // MARK: segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SettingsTVCEmbed" {
            if let settingsTVC = segue.destination as? RenterSettingsContainerTableViewController {
                self.settingsTVC = settingsTVC
            }
        }
    }
    
    // MARK: actions
    
    @IBAction func btnSave_TouchedUpInside(_ sender: UIButton) {
        guard let id = UserController.currentUserID, let renter = renter, let settingsTVC = settingsTVC else { return }
        
        let zipcode = settingsTVC.txtfldZipCode.text!
        
        renter.wantedZipCode = zipcode
        if UserController.currentUserID != "" {
            RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: settingsTVC.filterKeys.kZipCode.rawValue, newValue: zipcode)
        }
        
        self.delegate?.updateSettings()
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
