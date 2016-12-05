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
    
    @IBOutlet weak var pkrCreditRating: UIPickerView!
    
    @IBOutlet weak var lblMaxDistance: UILabel!
    @IBOutlet weak var stpMaxDistance: UIStepper!
    
    // MARK: variables
    
    var creditRatingPickerViewContent = ["Any","A","B","C","D","F"]
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pkrCreditRating.dataSource = self
        pkrCreditRating.delegate = self
        
        guard let landlord = UserController.currentLandlord, let desiredCreditRating = landlord.wantsCreditRating,  let firstName = landlord.firstName, let lastName = landlord.lastName, let ratingIndex = creditRatingPickerViewContent.index(of: desiredCreditRating) else {
            return
        }
        
        let maxDistance = landlord.withinRangeMiles
        
        lblUserName.text = "\(firstName) \(lastName)"
        lblMaxDistance.text = "\(maxDistance)"
        
        stpMaxDistance.value = Double(maxDistance)
        
        pkrCreditRating.selectRow(ratingIndex, inComponent: 0, animated: false)
    }
    
    // MARK: actions
    
    @IBAction func stpMaxDistance_ValueChanged(_ sender: UIStepper) {
        let maxDistance = Int16(sender.value)
        guard let landlord = UserController.currentLandlord, let id = landlord.id else { return }
        
        let countString = "\(maxDistance)"
        lblMaxDistance.text = countString
        landlord.withinRangeMiles = maxDistance
        UserController.updateCurrentLandlordInFirebase(id: id, attributeToUpdate: UserController.kWithinRangeMiles, newValue: maxDistance)
        // UserController.saveToPersistentStore()
        updateSettingsChanged()
    }
    
    // MARK: picker view delegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let rowValue = creditRatingPickerViewContent[row]
        if UserController.currentUserID == nil {
            return
        }
        UserController.currentLandlord?.wantsCreditRating = rowValue
        UserController.updateCurrentLandlordInFirebase(id: UserController.currentUserID!, attributeToUpdate: UserController.kWantsCreditRating, newValue: rowValue)
//        UserController.saveToPersistentStore()
        updateSettingsChanged()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return creditRatingPickerViewContent[row]
    }
    
    // MARK: picker view datasource
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return creditRatingPickerViewContent.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    private func updateSettingsChanged() {
        SettingsViewController.settingsDidChange = true
        UserController.renterFetchCount = 0
        UserController.resetStartAtForAllPropertiesInFirebase()
    }
}
