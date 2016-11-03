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
    
    var pageVC: LandlordPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.isHidden = true
        
        zipCodeTextField.delegate = self
        addressTextField.delegate = self
        hideKeyboardWhenViewIsTapped()
        
        
        
        self.navigationController?.navigationController?.navigationBar.barTintColor = UIColor.white
        AppearanceController.appearanceFor(textFields: [zipCodeTextField, addressTextField])
        AppearanceController.appearanceFor(navigationController: self.navigationController)
        
        self.pageVC = self.parent as? LandlordPageViewController
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.parent?.dismiss(animated: true, completion: nil)
    }
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        
        let zipCode = zipCodeTextField.text?.trimmingCharacters(in: .letters)
        
        if zipCode != "" && addressTextField.text != "" && zipCode?.characters.count == 5 {
            guard let address = addressTextField.text, let zipCode = zipCodeTextField.text else { return }
            UserController.addAttributeToUserDictionary(attribute: [UserController.kAddress : address])
            UserController.addAttributeToUserDictionary(attribute: [UserController.kZipCode: zipCode])

            UserController.pageRightFrom(landlordVC: self)
        } else {
            let alert = UIAlertController(title: "Hold on a second!", message: "Please enter both a valid zip code and address before continuing", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(dismissAction)
            alert.view.tintColor = AppearanceController.customOrangeColor
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        guard let text = textField.text, textField == zipCodeTextField else { return true }
        if string == "" {
            return true
        } else if text.characters.count == 5 {
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if zipCodeTextField.text != "",
            zipCodeTextField.text?.characters.count == 5, addressTextField.text != "" {
            nextButton.slideFromRight()
            UserController.enablePagingFor(landlordVC: self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
