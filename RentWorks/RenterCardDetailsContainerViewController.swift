//
//  RenterCardDetailsContainerViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 12/29/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class RenterCardDetailsContainerViewController: UITableViewController {
    
    // MARK: outlets
    
    @IBOutlet weak var propertyNameTextField: UITextField!
    @IBOutlet weak var txtfldPropertyAddress: UITextField!
    @IBOutlet weak var dtpckrDateAvailable: UIDatePicker!
    
    @IBOutlet weak var lblBedroomCount: UILabel!
    
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
    
    // MARK: variables
    
    var property: Property!
    
    // MARK: life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let propertyDetailsDict = PropertyController.getPropertyDetailsDictionary(property: property)
        updatePropertyDetails(propertyDetailsDict: propertyDetailsDict)
    }
    
    // MARK: helper functions
    
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
                lblBedroomCount.text = "\(bedroomCount)"
                break
            case propertyDetailKeys.kBathroomCount.rawValue:
                let bathroomCount = detail.value as! Double
                lblBathroomCount.text = "\(bathroomCount)"
                break
            case propertyDetailKeys.kPetsAllowed.rawValue:
                let petsAllowed = detail.value as! Bool
                swtPets.isOn = petsAllowed
                break
            case propertyDetailKeys.kSmokingAllowed.rawValue:
                let smokingAllowed = detail.value as! Bool
                swtSmoking.isOn = smokingAllowed
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
                log("no details for key \(detail.key)")
            }
        }
    }
}
