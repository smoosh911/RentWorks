//
//  LandlordAllowedViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordAllowedViewController: UIViewController {
    
    var smokingAllowed: Bool?
    var petsAllowed: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    @IBAction func petsAllowedButtonTapped(_ sender: AnyObject) {
        petsAllowed = true
    }
    
    @IBAction func noPetsAllowedButtonTapped(_ sender: AnyObject) {
        petsAllowed = false
    }
    
    @IBAction func smokingAllowedButtonTapped(_ sender: AnyObject) {
        smokingAllowed = true
    }
    
    @IBAction func noSmokingButtonTapped(_ sender: AnyObject) {
        smokingAllowed = true
    }
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        if let petsAllowed = petsAllowed, let smokingAllowed = smokingAllowed {
            UserController.addAttributeToUserDictionary(attribute: [UserController.UserDictionaryKeys.kPetsAllowed: petsAllowed])
            UserController.addAttributeToUserDictionary(attribute: [UserController.UserDictionaryKeys.kSmokingAllowed: smokingAllowed])
            
            self.performSegue(withIdentifier: "toPropertyFeaturesVC", sender: self)
        } else {
            let alert = UIAlertController(title: "Hold on a second!", message: "Please select whether you allow pets and smoking on your property before continuing.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
