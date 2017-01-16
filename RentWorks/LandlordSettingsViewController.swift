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
    
    @IBOutlet weak var lblMaxDistance: UILabel!
    @IBOutlet weak var sldrMaxDistance: UISlider!
    @IBOutlet weak var anyCreditButton: UIButton!
    @IBOutlet weak var aPlusCreditButton: UIButton!
    @IBOutlet weak var aCreditButton: UIButton!
    @IBOutlet weak var bCreditButton: UIButton!
    @IBOutlet weak var otherCreditButton: UIButton!
    @IBOutlet weak var propertyCountLabel: UILabel!
    
    var creditButtons: [UIButton] = []
    
    // MARK: variables
    
    
    // NOTE FOR MIKE: I changed the buttons names to match the credit rating options in the user creation process. It might mess up some of the logic in the viewDidLoad if you try to find the index of say 'D' credit rating as this array does not have it anymore.
    
    var creditRatings: [String] = ["Any", "A+", "A", "B", "Other"]
    
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.creditButtons = [anyCreditButton, aPlusCreditButton, aCreditButton, bCreditButton, otherCreditButton]
        
        guard let landlord = UserController.currentLandlord,
            let profileImages = landlord.profileImages?.array as? [ProfileImage],
            let desiredCreditRating = landlord.wantsCreditRating,
            let firstName = landlord.firstName,
            let lastName = landlord.lastName,
            let ratingIndex = creditRatings.index(of: desiredCreditRating),
            let propertyCount = landlord.property?.count else {
            return
        }
        
        if let profileImage = profileImages.first, let imageData = profileImage.imageData as? Data, let image = UIImage(data: imageData) {
            imgviewProfilePic.image = image
        }
        
        let buttonToSelect = creditButtons[ratingIndex]
        
        buttonToSelect.backgroundColor = AppearanceController.buttonPressedColor
        
        propertyCountLabel.text = "Properties: \(propertyCount)"
        let maxDistance = landlord.withinRangeMiles
        
        lblUserName.text = "\(firstName) \(lastName)"
        lblMaxDistance.text = "\(maxDistance)"
        
        sldrMaxDistance.value = Float(maxDistance)
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
    
    
    // NOTE FOR MIKE: I don't know how exactly you're changing these settings both locally and in Firebase, so I'll leave that up to you, instead of me probably messing something up.
    
    
    @IBAction func creditButtonTapped(_ sender: UIButton) {
        for button in creditButtons {
            if button == sender {
                button.backgroundColor = AppearanceController.buttonPressedColor
                updateCreditRatingForButton(button: sender)
            } else {
                button.backgroundColor = UIColor.clear
            }
        }
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
