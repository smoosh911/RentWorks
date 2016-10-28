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
        
        nextButton.alpha = 0
        
        zipCodeTextField.delegate = self
        addressTextField.delegate = self
        hideKeyboardWhenViewIsTapped()
        
        self.navigationController?.navigationController?.navigationBar.barTintColor = UIColor.white
        AppearanceController.appearanceFor(textFields: [zipCodeTextField, addressTextField])
        AppearanceController.appearanceFor(navigationController: self.navigationController)
    }
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        
        let zipCode = zipCodeTextField.text?.trimmingCharacters(in: .letters)
        
        if zipCode != "" && addressTextField.text != "" && zipCode?.characters.count == 5 {
            guard let address = addressTextField.text, let zipCode = zipCodeTextField.text else { return }
            UserController.addAttributeToUserDictionary(attribute: [UserController.kAddress : address])
            UserController.addAttributeToUserDictionary(attribute: [UserController.kZipCode: zipCode])
            
            self.performSegue(withIdentifier: "toLandlordBedroomVC", sender: self)
        } else {
            let alert = UIAlertController(title: "Hold on a second!", message: "Please enter both a valid zip code and address before continuing", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(dismissAction)
            alert.view.tintColor = AppearanceController.customOrangeColor
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return true }
        if string == "" {
            return true
        } else if text.characters.count == 5 {
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if zipCodeTextField.text != "" && addressTextField.text != "" {
            nextButton.slideFromRight()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
