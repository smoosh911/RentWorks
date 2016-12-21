//
//  RenterSettingsContainerTableViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 12/16/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class RenterSettingsContainerTableViewController: UITableViewController, UpdateSettingsDelegate {

    
    @IBOutlet weak var lblOccupation: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var sldRent: UISlider!
    
    @IBOutlet weak var stpBedrooms: UIStepper!
    @IBOutlet weak var lblBedroomCount: UILabel!
    
    @IBOutlet weak var stpBathrooms: UIStepper!
    @IBOutlet weak var lblBathroomCount: UILabel!
    
    @IBOutlet weak var stpMaxDistance: UIStepper!
    @IBOutlet weak var lblMaxDistanceCount: UILabel!
    
    @IBOutlet weak var swtPets: UISwitch!
    @IBOutlet weak var swtSmoking: UISwitch!
    
    @IBOutlet weak var txtfldFeatures: UITextField!
    @IBOutlet weak var txtfldZipCode: UITextField!

    
    var filterSettingsDict: [String: Any]?
    let filterKeys = UserController.RenterFilters.self

    let renter = UserController.currentRenter

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateSettingsInformation()
        
        guard let renterSettingsVC = self.parent as? RenterSettingsViewController else { return }
        renterSettingsVC.delegate = self

    }
    
    // MARK: actions
    
    // slider

    @IBAction func sldRent_ValueChanged(_ sender: UISlider) {
        let roundBy: Float = 25.0
        let price = Int(round(value: sender.value, toNearest: roundBy))
        let priceString = "\(price)"
        lblPrice.text = priceString
    }
    
    @IBAction func sldRent_TouchedUpInsideAndOutside(_ sender: UISlider) {
        let roundBy: Float = 25.0
        let price = Int64(round(value: sender.value, toNearest: roundBy))
        if UserController.currentUserID == nil {
            return
        }
        //        let priceString = "\(Int(sender.value))"
        UserController.currentRenter?.wantedPayment = price
        RenterController.updateCurrentRenterInFirebase(id: UserController.currentUserID!, attributeToUpdate: filterKeys.kMonthlyPayment.rawValue, newValue: price)
        updateSettingsChanged()
        // UserController.saveToPersistentStore()
    }
    
    // steppers
    
    @IBAction func stpBedrooms_ValueChanged(_ sender: UIStepper) {
        let bedroomCount = Int64(sender.value)
        guard let id = UserController.currentUserID else { return }
        
        let countString = "\(bedroomCount)"
        lblBedroomCount.text = countString
        renter?.wantedBedroomCount = bedroomCount
        RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kBedroomCount.rawValue, newValue: bedroomCount)
        updateSettingsChanged()
        // UserController.saveToPersistentStore()
    }
    
    @IBAction func stpBathrooms_ValueChanged(_ sender: UIStepper) {
        let bathroomCount = sender.value
        guard let id = UserController.currentUserID else { return }
        
        let countString = "\(bathroomCount)"
        lblBathroomCount.text = countString
        renter?.wantedBathroomCount = bathroomCount
        RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kBathroomCount.rawValue, newValue: bathroomCount)
        updateSettingsChanged()
        // UserController.saveToPersistentStore()
    }
    
    @IBAction func stpMaxDistance_ValueChanged(_ sender: UIStepper) {
        let maxDistance = Int16(sender.value)
        guard let id = UserController.currentUserID else { return }
        
        let countString = "\(maxDistance)"
        lblMaxDistanceCount.text = countString
        renter?.withinRangeMiles = maxDistance
        RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: UserController.kWithinRangeMiles, newValue: maxDistance)
        // UserController.saveToPersistentStore()
        updateSettingsChanged()
    }
    
    // switches
    
    @IBAction func swtPet_ValueChanged(_ sender: UISwitch) {
        let petsAllowed = sender.isOn
        guard let id = UserController.currentUserID else { return }
        
        //        let boolString = "\(petsAllowed)"
        renter?.wantsPetFriendly = petsAllowed
        RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kPetsAllowed.rawValue, newValue: petsAllowed)
        updateSettingsChanged()
        // UserController.saveToPersistentStore()
    }
    
    @IBAction func swtSmoking_ValueChanged(_ sender: UISwitch) {
        let smokingAllowed = sender.isOn
        guard let id = UserController.currentUserID else { return }
        
        //        let boolString = "\(smokingAllowed)"
        renter?.wantsSmoking = smokingAllowed
        RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kSmokingAllowed.rawValue, newValue: smokingAllowed)
        updateSettingsChanged()
        // UserController.saveToPersistentStore()
    }
    
    // MARK: helper functions
    
    private func updateSettingsInformation() {
        filterSettingsDict = RenterController.getRenterFiltersDictionary()
        
        guard let filterSettings = filterSettingsDict else { return }
        
        for filter in filterSettings {
            switch filter.key {
            case filterKeys.kBedroomCount.rawValue:
                guard let bedroomCount = filter.value as? Int else { break }
                stpBedrooms.value = Double(bedroomCount)
                lblBedroomCount.text = "\(stpBedrooms.value)"
                break
            case filterKeys.kBathroomCount.rawValue:
                guard let bathroomCount = filter.value as? Double else { break }
                stpBathrooms.value = bathroomCount
                lblBathroomCount.text = "\(stpBathrooms.value)"
                break
            case filterKeys.kMonthlyPayment.rawValue:
                guard let price = filter.value as? Int else { break }
                sldRent.value = Float(price)
                let priceString = "\(Int(sldRent.value))"
                lblPrice.text = priceString
                break
            case filterKeys.kPetsAllowed.rawValue:
                guard let petsAllowed = filter.value as? Bool else { break }
                swtPets.isOn = petsAllowed
                break
                
            case filterKeys.kSmokingAllowed.rawValue:
                guard let smokingAllowed = filter.value as? Bool else { break }
                swtSmoking.isOn = smokingAllowed
                break
            case filterKeys.kZipCode.rawValue:
                guard let zipcode = filter.value as? String else { break }
                txtfldZipCode.text = zipcode
                break
            case filterKeys.kCurrentOccupation.rawValue:
                guard let occupation = filter.value as? String else { break }
//                lblOccupation.text = occupation
            case filterKeys.kWithinRangeMiles.rawValue:
                guard let maxDistance = filter.value as? Int16 else { break }
                let maxDistanceString = "\(maxDistance)"
                lblMaxDistanceCount.text = maxDistanceString
                stpMaxDistance.value = Double(maxDistance)
            default:
                log("no filters")
            }
        }
    }
    
    func updateSettings() {
        updateSettingsChanged()
    }
    
    private func updateSettingsChanged() {
        SettingsViewController.settingsDidChange = true
        UserController.propertyFetchCount = 0
        RenterController.resetStartAtForRenterInFirebase(renterID: renter!.id!)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    

}