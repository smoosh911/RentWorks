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
    
    @IBOutlet weak var lblOccupation: UILabel!
    
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var sldRent: UISlider!
    
    @IBOutlet weak var stpBedrooms: UIStepper!
    @IBOutlet weak var lblBedroomCount: UILabel!
    
    @IBOutlet weak var stpBathrooms: UIStepper!
    @IBOutlet weak var lblBathroomCount: UILabel!
    
    @IBOutlet weak var swtPets: UISwitch!
    @IBOutlet weak var swtSmoking: UISwitch!
    
    @IBOutlet weak var txtfldFeatures: UITextField!
    @IBOutlet weak var txtfldZipCode: UITextField!
    
    // MARK: variables
    
    var filterSettingsDict: [String: Any]?
    let filterKeys = UserController.RenterFilters.self
    
    let renter = UserController.currentRenter
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterSettingsDict = UserController.getRenterFiltersDictionary()
        
        guard let filterSettings = filterSettingsDict else { return }
        
        for filter in filterSettings {
            switch filter.key {
            case filterKeys.kBedroomCount.rawValue:
                let bedroomCount = filter.value as! Int
                stpBedrooms.value = Double(bedroomCount)
                lblBedroomCount.text = "\(stpBedrooms.value)"
                break
            case filterKeys.kBathroomCount.rawValue:
                let bathroomCount = filter.value as! Double
                stpBathrooms.value = bathroomCount
                lblBathroomCount.text = "\(stpBathrooms.value)"
                break
            case filterKeys.kMonthlyPayment.rawValue:
                sldRent.value = Float(filter.value as! Int)
                let price = "\(Int(sldRent.value))"
                lblPrice.text = price
                break
            case filterKeys.kPetsAllowed.rawValue:
                let petsAllowed = filter.value as! Bool
                swtPets.isOn = petsAllowed
                break
            case filterKeys.kPropertyFeatures.rawValue:
                let features = filter.value as! String
                txtfldFeatures.text = features
                break
            case filterKeys.kSmokingAllowed.rawValue:
                let smokingAllowed = filter.value as! Bool
                swtSmoking.isOn = smokingAllowed
                break
            case filterKeys.kZipCode.rawValue:
                let zipcode = filter.value as! String
                txtfldZipCode.text = zipcode
                break
            default:
                log("no filters")
            }
        }
        
        guard let profileImages = UserController.currentRenter!.profileImages?.array as? [ProfileImage] else { return }
        
        lblUserName.text = "\(UserController.currentRenter!.firstName!) \(UserController.currentRenter!.lastName!)"
        imgviewProfilePic.image = UIImage(data: profileImages[0].imageData as! Data)
    }
    
    // MARK: actions
    
    // slider
    
    @IBAction func sldRent_ValueChanged(_ sender: UISlider) {
        let price = "\(Int(sender.value))"
        lblPrice.text = price
    }
    
    @IBAction func sldRent_TouchedUpInsideAndOutside(_ sender: UISlider) {
        let price = Int64(sender.value)
        if UserController.currentUserID == nil {
            return
        }
//        let priceString = "\(Int(sender.value))"
        UserController.currentRenter?.wantedPayment = price
        UserController.updateCurrentRenterInFirebase(id: UserController.currentUserID!, attributeToUpdate: filterKeys.kMonthlyPayment.rawValue, newValue: price)
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
        UserController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kBedroomCount.rawValue, newValue: bedroomCount)
        updateSettingsChanged()
        // UserController.saveToPersistentStore()
    }
    
    @IBAction func stpBathrooms_ValueChanged(_ sender: UIStepper) {
        let bathroomCount = sender.value
        guard let id = UserController.currentUserID else { return }
        
        let countString = "\(bathroomCount)"
        lblBathroomCount.text = countString
        renter?.wantedBathroomCount = bathroomCount
        UserController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kBathroomCount.rawValue, newValue: bathroomCount)
        updateSettingsChanged()
        // UserController.saveToPersistentStore()
    }
    
    // switches
    
    @IBAction func swtPet_ValueChanged(_ sender: UISwitch) {
        let petsAllowed = sender.isOn
        guard let id = UserController.currentUserID else { return }
        
//        let boolString = "\(petsAllowed)"
        renter?.wantsPetFriendly = petsAllowed
        UserController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kPetsAllowed.rawValue, newValue: petsAllowed)
        updateSettingsChanged()
        // UserController.saveToPersistentStore()
    }
    
    @IBAction func swtSmoking_ValueChanged(_ sender: UISwitch) {
        let smokingAllowed = sender.isOn
        guard let id = UserController.currentUserID else { return }
        
//        let boolString = "\(smokingAllowed)"
        renter?.wantsSmoking = smokingAllowed
        UserController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kSmokingAllowed.rawValue, newValue: smokingAllowed)
        updateSettingsChanged()
        // UserController.saveToPersistentStore()
    }
    
    // buttons
    
    @IBAction func btnSubmitChanges_TouchedUpInside(_ sender: Any) {
        guard let id = UserController.currentUserID else { return }
        
        let propertyFeatures = txtfldFeatures.text!
        let zipcode = txtfldZipCode.text!
        
        renter?.wantedPropertyFeatures = propertyFeatures
        renter?.wantedZipCode = zipcode
        UserController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kPropertyFeatures.rawValue, newValue: propertyFeatures)
        UserController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kZipCode.rawValue, newValue: zipcode)
        updateSettingsChanged()
        // UserController.saveToPersistentStore()
    }
    
    // MARK: helper functions
    
    private func updateSettingsChanged() {
        SettingsViewController.settingsDidChange = true
        UserController.propertyFetchCount = 0
        UserController.resetStartAtForRenterInFirebase(renterID: renter!.id!)
    }
}
