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
    
//    @IBOutlet weak var propertyNameTextField: UITextField!
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
    
    @IBOutlet weak var lblLeaseEndDate: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblZipcode: UILabel!
    
    
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
            case propertyDetailKeys.kPropertyDescription.rawValue:
                let propertyDescription = detail.value as! String
                lblDescription.text = propertyDescription
            case propertyDetailKeys.kZipCode.rawValue:
                let zipcode = detail.value as! String
                lblZipcode.text = zipcode
                break
            case propertyDetailKeys.kLeaseEnd.rawValue:
                let leaseEnd = detail.value as! NSDate
                lblLeaseEndDate.text = "\(leaseEnd)"
            default:
                log("no details for key \(detail.key)")
            }
        }
    }
}
