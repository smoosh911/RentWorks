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
    
//    var settingsTVC: RenterSettingsContainerTableViewController?
    
//    weak var delegate: UpdateSettingsDelegate?
    
    let renter = UserController.currentRenter
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
//        swipeDown.direction = UISwipeGestureRecognizerDirection.down
//        self.view.addGestureRecognizer(swipeDown)
    }
    
    // MARK: actions
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
    
    @IBAction func btnSubmitChanges_TouchedUpInside(_ sender: Any) {
//        guard let id = UserController.currentUserID, let renter = renter, let settingsTVC = settingsTVC else { return }
//        
//        let zipcode = settingsTVC.txtfldZipCode.text!
//        
//        renter.wantedZipCode = zipcode
//        if UserController.currentUserID != "" {
//            RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: settingsTVC.filterKeys.kZipCode.rawValue, newValue: zipcode)
//        }
//        
//        self.delegate?.updateSettings()
    }
    
    // MARK: helper functions
    
    private func setupUI() {
        guard let profileImages = UserController.currentRenter?.profileImages?.array as? [ProfileImage] else { return }
        
        if let imageData = profileImages[0].imageData as? Data, let image = UIImage(data: imageData) {
            imgviewProfilePic.image = image
        }
        
        lblUserName.text = "\(UserController.currentRenter!.firstName!) \(UserController.currentRenter!.lastName!)"
        
        guard let filterSettingsDict = RenterController.getRenterFiltersDictionary() else {
            log("ERROR: couldnt' get renter filter dictionary")
            return
        }
        let kCurrentOccupation = UserController.RenterFilters.kCurrentOccupation
        guard let occupation = filterSettingsDict[kCurrentOccupation.rawValue] as? String else { return }
        
        lblOccupation.text = occupation
    }
    
    // MARK: segues
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        
//        if segue.identifier == "SettingsTVCEmbed" {
//            if let settingsTVC = segue.destination as? RenterSettingsContainerTableViewController {
//                self.settingsTVC = settingsTVC
//            }
//        }
//    }
    
    // MARK: keyboard
    
//    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            switch swipeGesture.direction {
//            case UISwipeGestureRecognizerDirection.right:
//                print("Swiped right")
//            case UISwipeGestureRecognizerDirection.down:
//                print("Swiped down")
//                
//                self.view.endEditing(true)
//                
//            case UISwipeGestureRecognizerDirection.left:
//                print("Swiped left")
//            case UISwipeGestureRecognizerDirection.up:
//                print("Swiped up")
//            default:
//                break
//            }
//        }
//    }
}


//protocol UpdateSettingsDelegate: class {
//    func updateSettings()
//}
