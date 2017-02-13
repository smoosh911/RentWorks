//
//  LandlordFilterSettingsViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 2/11/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation
import FirebaseAuth

protocol LandlordFilterSettingsViewControllerDelegate {
    func modalViewDismissed()
}

class LandlordFilterSettingsViewController: UIViewController {
    
    // MARK: outlets
    
    @IBOutlet weak var lblMaxDistance: UILabel!
    @IBOutlet weak var sldrMaxDistance: UISlider!
    @IBOutlet weak var anyCreditButton: UIButton!
    @IBOutlet weak var aPlusCreditButton: UIButton!
    @IBOutlet weak var aCreditButton: UIButton!
    @IBOutlet weak var bCreditButton: UIButton!
    @IBOutlet weak var otherCreditButton: UIButton!
    
    // MARK: variables 
    
    // NOTE FOR MIKE: I changed the buttons names to match the credit rating options in the user creation process. It might mess up some of the logic in the viewDidLoad if you try to find the index of say 'D' credit rating as this array does not have it anymore.
    
    var creditRatings: [String] = ["Any", "A+", "A", "B", "Other"]
    var creditButtons: [UIButton] = []
    
    var delegate: LandlordFilterSettingsViewControllerDelegate?
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.creditButtons = [anyCreditButton, aPlusCreditButton, aCreditButton, bCreditButton, otherCreditButton]
        
        guard let landlord = UserController.currentLandlord,
            let desiredCreditRating = landlord.wantsCreditRating,
            let ratingIndex = creditRatings.index(of: desiredCreditRating) else {
                return
        }
        
        let buttonToSelect = creditButtons[ratingIndex]
        
        buttonToSelect.backgroundColor = AppearanceController.buttonPressedColor
        
        let maxDistance = landlord.withinRangeMiles
        lblMaxDistance.text = "\(maxDistance)"
        sldrMaxDistance.value = Float(maxDistance)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let delegate = delegate {
            delegate.modalViewDismissed()
        }
    }
    
    // MARK: actions
    
    @IBAction func sldMaxDistance_ValueChanged(_ sender: UISlider) {
        let maxDistance = Int16(sender.value)
        lblMaxDistance.text = "\(maxDistance)"
    }
    
    @IBAction func sldMaxDistance_TouchedUpInsideAndOutside(_ sender: UISlider) {
        let maxDistance = Int16(sender.value)
        guard let landlord = UserController.currentLandlord, let id = landlord.id else { return }
        
        let countString = "\(maxDistance)"
        lblMaxDistance.text = countString
        landlord.withinRangeMiles = maxDistance
        LandlordController.updateCurrentLandlordInFirebase(id: id, attributeToUpdate: UserController.kWithinRangeMiles, newValue: maxDistance)
        // UserController.saveToPersistentStore()
        updateSettingsChanged()
    }
    
    @IBAction func creditButtonTapped(_ sender: UIButton) {
        
        if FIRAuth.auth()?.currentUser == nil {
            AlertManager.alert(withTitle: "Not Logged In", withMessage: "Must log in to use filters", dismissTitle: "OK", inViewController: self)
        } else {
            for button in creditButtons {
                if button == sender {
                    button.backgroundColor = AppearanceController.buttonPressedColor
                    updateCreditRatingForButton(button: sender)
                } else {
                    button.backgroundColor = UIColor.clear
                }
            }
        }
    }
    
    @IBAction func btnSave_TouchedUpInside(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: helper functions
    
    private func updateCreditRatingForButton(button: UIButton) {
        guard let creditRating = button.titleLabel?.text, let landlord = UserController.currentLandlord, let id = landlord.id else { return }
        
        landlord.wantsCreditRating = creditRating
        LandlordController.updateCurrentLandlordInFirebase(id: id, attributeToUpdate: UserController.kWantsCreditRating, newValue: creditRating)
        updateSettingsChanged()
    }
    
    private func updateSettingsChanged() {
        SettingsViewController.settingsDidChange = true
        UserController.renterFetchCount = 0
        PropertyController.resetStartAtForAllPropertiesInFirebase()
    }
}
