//
//  RenterAddressViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class RenterAddressViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonCenterXConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nextButton.alpha = 0.0
        zipCodeTextField.delegate = self
        addressTextField.delegate = self
        
        hideKeyboardWhenViewIsTapped()
        
        self.navigationController?.navigationController?.navigationBar.barTintColor = UIColor.white
        AppearanceController.appearanceFor(textFields: [zipCodeTextField, addressTextField])
        AppearanceController.appearanceFor(navigationController: self.navigationController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        nextButton.setOffScreenToRight()
    }
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        
        if zipCodeTextField.text != "" && addressTextField.text != "" {
            guard let address = addressTextField.text, let zipCode = zipCodeTextField.text else { return }
            UserController.addAttributeToUserDictionary(attribute: [UserController.kAddress : address])
            UserController.addAttributeToUserDictionary(attribute: [UserController.kZipCode: zipCode])
            
            self.performSegue(withIdentifier: "toRenterBedroomVC", sender: self)
        } else {
            let alert = UIAlertController(title: "Hold on a second!", message: "Please enter both a valid zip code and address before continuing.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(dismissAction)
            alert.view.tintColor = AppearanceController.customOrangeColor

            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if zipCodeTextField.text != "" && addressTextField.text != "" {

            nextButton.slideFromRight()
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension UIViewController {
    func hideKeyboardWhenViewIsTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
