//
//  LandlordCardDetailContainerViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 12/31/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class LandlordCardDetailContainterViewController: UITableViewController {
    
    // MARK: outlets
    
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var lblMaritalStatus: UILabel!
    
    @IBOutlet weak var swtPets: UISwitch!
    @IBOutlet weak var swtSmoking: UISwitch!
    
    // MARK: variables
    
    var renterDetailsDict: [String: Any]?
    let renterDetailKeys = UserController.RenterDetails.self
    
    var renter: Renter? = nil
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateSettingsInformation()
    }
    
    // MARK: helper functions
    
    private func updateSettingsInformation() {
        guard let renter = renter else { return }
        renterDetailsDict = RenterController.getRenterDetailsDictionary(forRenter: renter)
        
        guard let renterDetails = renterDetailsDict else { return }
        
        for detail in renterDetails {
            switch detail.key {
            case renterDetailKeys.kBio.rawValue:
                guard let bio = detail.value as? String else { break }
                lblBio.text = bio
                break
            case renterDetailKeys.kMaritalStatus.rawValue:
                guard let maritalStatus = detail.value as? String else { break }
                lblMaritalStatus.text = maritalStatus
            case renterDetailKeys.kPetsAllowed.rawValue:
                guard let petsAllowed = detail.value as? Bool else { break }
                swtPets.isOn = petsAllowed
                break
            case renterDetailKeys.kSmokingAllowed.rawValue:
                guard let smokingAllowed = detail.value as? Bool else { break }
                swtSmoking.isOn = smokingAllowed
                break
            default:
                log("no filters")
            }
        }
    }
}
