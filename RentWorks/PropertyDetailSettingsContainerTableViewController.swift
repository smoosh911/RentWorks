//
//  PropertyDetailSettingsContainerTableViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 12/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class PropertyDetailSettingsContainerTableViewController: UITableViewController {
        
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
    
    var propertyImages: [ProfileImage] = []
    
    var propertyTask: PropertyTask = PropertyTask.editing
    
    enum SaveResults: String {
        case success = "Property Saved!"
        case failure = "Property Couldn't Save"
    }
    
    enum PropertyTask {
        case adding
        case editing
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if propertyTask == PropertyTask.adding {
            guard let landlordID = UserController.currentUserID else { return }
            property = Property(landlordID: landlordID, landlord: landlord)
        }
        
        guard let property = property, let profileImages = property.profileImages?.array as? [ProfileImage] else { return }
        propertyImages = profileImages
        
        let propertyDetailsDict = PropertyController.getPropertyDetailsDictionary(property: property)
        updatePropertyDetails(propertyDetailsDict: propertyDetailsDict)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)

    }

    func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let keyboardSizeValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardSize = keyboardSizeValue.cgRectValue.size
        
        if (self.view.frame.origin.y == 0 && (txtfldZipCode.isEditing || txtfldCity.isEditing || txtfldState.isEditing)) {
            UIView.animate(withDuration: 0.1, animations: {
                self.view.frame.origin.y -= keyboardSize.height
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let keyboardSizeValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardSize = keyboardSizeValue.cgRectValue.size
        
        if self.view.frame.origin.y != 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.view.frame.origin.y += keyboardSize.height
                self.view.layoutIfNeeded()
                
            })
        }
    }
    
    

    // MARK: actions
    
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