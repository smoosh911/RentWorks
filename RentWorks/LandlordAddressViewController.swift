//
//  LandlordAddressViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/6/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordAddressViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zipCodeTextField.delegate = self
        addressTextField.delegate = self
        
        self.navigationController?.navigationController?.navigationBar.barTintColor = UIColor.white
        AppearanceController.appearanceFor(textFields: [zipCodeTextField, addressTextField])
        AppearanceController.appearanceFor(navigationController: self.navigationController)
    }
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        
        if zipCodeTextField.text != "" && addressTextField.text != "" {
            guard let address = addressTextField.text, let zipCode = zipCodeTextField.text else { return }
            UserController.addAttributeToUserDictionary(attribute: [UserController.kAddress : address])
            UserController.addAttributeToUserDictionary(attribute: [UserController.kZipCode: zipCode])
            
            self.performSegue(withIdentifier: "toLandlordBedroomVC", sender: self)
        } else {
            let alert = UIAlertController(title: "Hold on a second!", message: "Please enter both a valid zip code and address please!", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
