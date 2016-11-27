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
        landlordButton.layer.cornerRadius = 15
        renterButton.layer.cornerRadius = 15
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRenterPageVC" {
            UserController.userCreationType = "renter"
            UserController.currentUserType = "renter"
        } else if segue.identifier == "toLandlordPageVC" {
            UserController.userCreationType = "landlord"
            UserController.currentUserType = "landlord"
        }
    }
}
