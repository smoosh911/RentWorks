//
//  LandlordSettingsViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import CoreData

class LandlordSettingsViewController: SettingsViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: outlets
    
    @IBOutlet weak var lblMaxDistance: UILabel!
    @IBOutlet weak var sldrMaxDistance: UISlider!
    
    // MARK: variables
    
    var creditRatingPickerViewContent = ["Any","A+", "A", "B","Other"]
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        guard let landlord = UserController.currentLandlord,
            let desiredCreditRating = landlord.wantsCreditRating,
            let firstName = landlord.firstName,
            let lastName = landlord.lastName,
            let ratingIndex = creditRatingPickerViewContent.index(of: desiredCreditRating) else {
            return
        }
        
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
    
    
    private func updateSettingsChanged() {
        SettingsViewController.settingsDidChange = true
        UserController.renterFetchCount = 0
        PropertyController.resetStartAtForAllPropertiesInFirebase()
    }
}
