//
//  LandlordOrUserViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/13/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordOrUserViewController: UIViewController {
    
    @IBOutlet weak var renterButton: UIButton!
    @IBOutlet weak var landlordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRenterAddressVC" {
            UserController.userCreationType = "renter"
        } else if segue.identifier == "toLandlordAddressVC" {
            UserController.userCreationType = "landlord"
        }
    }
}
