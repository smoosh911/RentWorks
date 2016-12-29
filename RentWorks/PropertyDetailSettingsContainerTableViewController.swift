//
//  PropertyDetailSettingsContainerTableViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 12/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class PropertyDetailSettingsContainerTableViewController: UITableViewController, UITextFieldDelegate {
        
    @IBOutlet weak var propertyNameTextField: UITextField!
    @IBOutlet weak var txtfldPropertyAddress: UITextField!
    @IBOutlet weak var dtpckrDateAvailable: UIDatePicker!
    
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var sldRent: UISlider!
    
    @IBOutlet weak var stpBedrooms: UIStepper!
    @IBOutlet weak var lblBedroomCount: UILabel!
    
    @IBOutlet weak var stpBathrooms: UIStepper!
    @IBOutlet weak var lblBathroomCount: UILabel!
    
    @IBOutlet weak var swtPets: UISwitch!
    @IBOutlet weak var swtSmoking: UISwitch!
    @IBOutlet weak var swtWasherDryer: UISwitch!
    @IBOutlet weak var swtGarage: UISwitch!
    @IBOutlet weak var swtDishwasher: UISwitch!
    @IBOutlet weak var swtPool: UISwitch!
    @IBOutlet weak var swtGym: UISwitch!
    @IBOutlet weak var swtBackyard: UISwitch!
    
    @IBOutlet weak var txtfldZipCode: UITextField!
    @IBOutlet weak var txtfldCity: UITextField!
    @IBOutlet weak var txtfldState: UITextField!
    @IBOutlet weak var starImageView1: UIImageView!
    @IBOutlet weak var starImageView2: UIImageView!
    @IBOutlet weak var starImageView3: UIImageView!
    @IBOutlet weak var starImageView4: UIImageView!
    @IBOutlet weak var starImageView5: UIImageView!
    
    weak var delegate: UpdatePropertySettingsDelegate?
    
    var property: Property! = nil
    var landlord: Landlord! = UserController.currentLandlord
    
    var propertyTask = PropertyTask.editing
    
    enum SaveResults: String {
        case success = "Property Saved!"
        case failure = "Property Couldn't Save"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if propertyTask == PropertyTask.adding {
            guard let landlordID = UserController.currentUserID else { return }
            property = Property(landlordID: landlordID, landlord: landlord)
        }
        
        guard let property = property else { return }
        
        let propertyDetailsDict = PropertyController.getPropertyDetailsDictionary(property: property)
        updatePropertyDetails(propertyDetailsDict: propertyDetailsDict)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
        
        self.hideKeyboardWhenViewIsTapped()
    }
    
    // MARK: keyboard

    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let keyboardSizeValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue, let parent = self.parent else {
            return
        }
        
        let keyboardSize = keyboardSizeValue.cgRectValue.size
        
        if (parent.view.frame.origin.y == 0 && (txtfldZipCode.isEditing || txtfldCity.isEditing || txtfldState.isEditing)) {
            UIView.animate(withDuration: 0.1, animations: {
                parent.view.frame.origin.y -= keyboardSize.height
                parent.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let keyboardSizeValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue, let parent = self.parent else {
            return
        }
        
        let keyboardSize = keyboardSizeValue.cgRectValue.size
        
        if parent.view.frame.origin.y != 0 {
            UIView.animate(withDuration: 0.5, animations: {
                parent.view.frame.origin.y += keyboardSize.height
                parent.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: text field delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("return")
        return true
    }
    
    // MARK: actions
    
    // Buttons
    
    @IBAction func editPropertyNameButtonTapped(_ sender: Any) {
        propertyNameTextField.isUserInteractionEnabled = !propertyNameTextField.isUserInteractionEnabled
    }
    
    // slider
    
    @IBAction func sldRent_ValueChanged(_ sender: UISlider) {
        let roundBy: Float = 25.0
        let roundedPrice = Int(round(value: sender.value, toNearest: roundBy))
        let price = "\(roundedPrice)"
        lblPrice.text = price
    }
    
    @IBAction func sldRent_TouchedUpInsideAndOutside(_ sender: UISlider) {
        let roundBy: Float = 25.0
        let price = Int(round(value: sender.value, toNearest: roundBy))
        guard let id = property.propertyID else { return }
        property.monthlyPayment = Int64(price)
        if propertyTask == PropertyTask.editing {
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kMonthlyPayment, newValue: price)
            // UserController.saveToPersistentStore()
            self.updateSettingsChanged()
        }
    }
    
    // steppers
    
    @IBAction func stpBedrooms_ValueChanged(_ sender: UIStepper) {
        let bedroomCount = Int64(sender.value)
        guard let id = property.propertyID else { return }
        
        let countString = "\(bedroomCount)"
        lblBedroomCount.text = countString
        property.bedroomCount = bedroomCount
        if propertyTask == PropertyTask.editing {
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kBedroomCount, newValue: bedroomCount)
            // UserController.saveToPersistentStore()
            self.updateSettingsChanged()
        }
    }
    
    @IBAction func stpBathrooms_ValueChanged(_ sender: UIStepper) {
        let bathroomCount = sender.value
        guard let id = property.propertyID else { return }
        let countString = "\(bathroomCount)"
        lblBathroomCount.text = countString
        property.bathroomCount = bathroomCount
        if propertyTask == PropertyTask.editing {
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kBathroomCount, newValue: bathroomCount)
            // UserController.saveToPersistentStore()
            self.updateSettingsChanged()
        }
    }
    
    // switches
    
    @IBAction func swtPet_ValueChanged(_ sender: UISwitch) {
        let petsAllowed = sender.isOn
        guard let id = property.propertyID else { return }
        
        property.petFriendly = petsAllowed
        if propertyTask == PropertyTask.editing {
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kPetsAllowed, newValue: petsAllowed)
            // UserController.saveToPersistentStore()
            self.updateSettingsChanged()
        }
    }
    
    @IBAction func swtSmoking_ValueChanged(_ sender: UISwitch) {
        let smokingAllowed = sender.isOn
        guard let id = property.propertyID else { return }
        
        property.smokingAllowed = smokingAllowed
        if propertyTask == PropertyTask.editing {
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kSmokingAllowed, newValue: smokingAllowed)
            // UserController.saveToPersistentStore()
            self.updateSettingsChanged()
        }
    }
    
    @IBAction func swtWasherDryer_ValueChanged(_ sender: UISwitch) {
        let hasWasherDryer = sender.isOn
        guard let id = property.propertyID else { return }
        
        property.washerDryer = hasWasherDryer
        if propertyTask == PropertyTask.editing {
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kSmokingAllowed, newValue: hasWasherDryer)
            // UserController.saveToPersistentStore()
            self.updateSettingsChanged()
        }
    }
    
    @IBAction func swtGarage_ValueChanged(_ sender: UISwitch) {
        let hasGarage = sender.isOn
        guard let id = property.propertyID else { return }
        
        property.garage = hasGarage
        if propertyTask == PropertyTask.editing {
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kSmokingAllowed, newValue: hasGarage)
            // UserController.saveToPersistentStore()
            self.updateSettingsChanged()
        }
    }
    
    @IBAction func swtDishwasher_ValueChanged(_ sender: UISwitch) {
        let hasDishwasher = sender.isOn
        guard let id = property.propertyID else { return }
        
        property.dishwasher = hasDishwasher
        if propertyTask == PropertyTask.editing {
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kSmokingAllowed, newValue: hasDishwasher)
            // UserController.saveToPersistentStore()
            self.updateSettingsChanged()
        }
    }
    
    @IBAction func swtPool_ValueChanged(_ sender: UISwitch) {
        let hasPool = sender.isOn
        guard let id = property.propertyID else { return }
        
        property.pool = hasPool
        if propertyTask == PropertyTask.editing {
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kSmokingAllowed, newValue: hasPool)
            // UserController.saveToPersistentStore()
            self.updateSettingsChanged()
        }
    }
    
    @IBAction func swtGym_ValueChanged(_ sender: UISwitch) {
        let hasGym = sender.isOn
        guard let id = property.propertyID else { return }
        
        property.gym = hasGym
        if propertyTask == PropertyTask.editing {
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kSmokingAllowed, newValue: hasGym)
            // UserController.saveToPersistentStore()
            self.updateSettingsChanged()
        }
    }
    
    @IBAction func swtBackyard_ValueChanged(_ sender: UISwitch) {
        let hasBackyard = sender.isOn
        guard let id = property.propertyID else { return }
        
        property.backyard = hasBackyard
        if propertyTask == PropertyTask.editing {
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kSmokingAllowed, newValue: hasBackyard)
            // UserController.saveToPersistentStore()
            self.updateSettingsChanged()
        }
    }
    
    // MARK: helper methods
    
    private func updatePropertyDetails (propertyDetailsDict: [String: Any]) {
        let propertyDetailKeys = UserController.PropertyDetailValues.self
        
        for detail in propertyDetailsDict {
            switch detail.key {
            case propertyDetailKeys.kAddress.rawValue:
                let address = detail.value as! String
                txtfldPropertyAddress.text = address
                break
            case propertyDetailKeys.kAvailableDate.rawValue:
                guard let timeInterval = detail.value as? TimeInterval else { break }
                let availableDate = Date(timeIntervalSince1970: timeInterval)
                dtpckrDateAvailable.date = availableDate
                break
            case propertyDetailKeys.kBedroomCount.rawValue:
                let bedroomCount = detail.value as! Int
                stpBedrooms.value = Double(bedroomCount)
                lblBedroomCount.text = "\(stpBedrooms.value)"
                break
            case propertyDetailKeys.kBathroomCount.rawValue:
                let bathroomCount = detail.value as! Double
                stpBathrooms.value = bathroomCount
                lblBathroomCount.text = "\(stpBathrooms.value)"
                break
            case propertyDetailKeys.kMonthlyPayment.rawValue:
                sldRent.value = Float(detail.value as! Int)
                let price = "\(Int(sldRent.value))"
                lblPrice.text = price
                break
            case propertyDetailKeys.kPetsAllowed.rawValue:
                let petsAllowed = detail.value as! Bool
                swtPets.isOn = petsAllowed
                break
            case propertyDetailKeys.kSmokingAllowed.rawValue:
                let smokingAllowed = detail.value as! Bool
                swtSmoking.isOn = smokingAllowed
                break
            case propertyDetailKeys.kStarRating.rawValue:
                let rating = detail.value as! Double
                updateStars(starImageViews: [starImageView1, starImageView2, starImageView3, starImageView4, starImageView5], for: rating)
                break
            case propertyDetailKeys.kZipCode.rawValue:
                let zipcode = detail.value as! String
                txtfldZipCode.text = zipcode
                break
            case propertyDetailKeys.kCity.rawValue:
                let city = detail.value as! String
                txtfldCity.text = city
                break
            case propertyDetailKeys.kState.rawValue:
                let state = detail.value as! String
                txtfldState.text = state
                break
            case propertyDetailKeys.kWasherDryer.rawValue:
                let hasWasherDryer = detail.value as! Bool
                swtWasherDryer.isOn = hasWasherDryer
                break
            case propertyDetailKeys.kGarage.rawValue:
                let hasGarage = detail.value as! Bool
                swtGarage.isOn = hasGarage
                break
            case propertyDetailKeys.kDishwasher.rawValue:
                let hasDishwasher = detail.value as! Bool
                swtDishwasher.isOn = hasDishwasher
                break
            case propertyDetailKeys.kPool.rawValue:
                let hasPool = detail.value as! Bool
                swtPool.isOn = hasPool
                break
            case propertyDetailKeys.kGym.rawValue:
                let hasGym = detail.value as! Bool
                swtGym.isOn = hasGym
                break
            case propertyDetailKeys.kBackyard.rawValue:
                let hasBackyard = detail.value as! Bool
                swtBackyard.isOn = hasBackyard
                break
            default:
                log("no details")
            }
        }
    }
    
    func updateStars(starImageViews: [UIImageView], for rating: Double) {
        
        switch rating {
        case 1:
            starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
            starImageViews[1].image = #imageLiteral(resourceName: "Star")
            starImageViews[2].image = #imageLiteral(resourceName: "Star")
            starImageViews[3].image = #imageLiteral(resourceName: "Star")
            starImageViews[4].image = #imageLiteral(resourceName: "Star")
            
        case 2:
            starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
            starImageViews[1].image = #imageLiteral(resourceName: "StarFilled")
            starImageViews[2].image = #imageLiteral(resourceName: "Star")
            starImageViews[3].image = #imageLiteral(resourceName: "Star")
            starImageViews[4].image = #imageLiteral(resourceName: "Star")
        case 3:
            starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
            starImageViews[1].image = #imageLiteral(resourceName: "StarFilled")
            starImageViews[2].image = #imageLiteral(resourceName: "StarFilled")
            starImageViews[3].image = #imageLiteral(resourceName: "Star")
            starImageViews[4].image = #imageLiteral(resourceName: "Star")
        case 4:
            starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
            starImageViews[1].image = #imageLiteral(resourceName: "StarFilled")
            starImageViews[2].image = #imageLiteral(resourceName: "StarFilled")
            starImageViews[3].image = #imageLiteral(resourceName: "StarFilled")
            starImageViews[4].image = #imageLiteral(resourceName: "Star")
        case 5:
            starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
            starImageViews[1].image = #imageLiteral(resourceName: "StarFilled")
            starImageViews[2].image = #imageLiteral(resourceName: "StarFilled")
            starImageViews[3].image = #imageLiteral(resourceName: "StarFilled")
            starImageViews[4].image = #imageLiteral(resourceName: "StarFilled")
        default:
            _ = starImageViews.map({$0.image = #imageLiteral(resourceName: "Star")})
        }
    }
    
    func updateSettings() {
        guard let id = property.propertyID, let address = txtfldPropertyAddress.text, let zipcode = txtfldZipCode.text, let city = txtfldCity.text, let state = txtfldState.text else { return }
        property.address = address
        property.zipCode = zipcode
        property.city = city
        property.state = state
        
        if propertyTask == PropertyTask.editing {
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kZipCode, newValue: zipcode)
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kAddress, newValue: address)
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kCity, newValue: city)
            PropertyController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kState, newValue: state)
            delegate?.updatePropertySettingsWith(saveResult: SaveResults.success.rawValue)
            // UserController.saveToPersistentStore()
        } else {
            PropertyController.createPropertyInFirebase(property: property, completion: { success in
                FirebaseController.properties.append(self.property)
                self.propertyTask = PropertyTask.editing
            })
        }
        self.updateSettingsChanged()
    }
    
    func updateSettingsChanged() {
        SettingsViewController.settingsDidChange = true
        UserController.renterFetchCount = 0
        PropertyController.resetStartAtForAllPropertiesInFirebase()
    }
}

protocol UpdatePropertySettingsDelegate: class {
    func updatePropertySettingsWith(saveResult: String)
}
