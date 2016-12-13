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
    @IBOutlet weak var titleView: UIView!
    
    var pageVC: LandlordPageViewController?
    
    var didSlide = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AccountCreationController.currenLandlordVCs.append(self)
        
        zipCodeTextField.delegate = self
        addressTextField.delegate = self
        hideKeyboardWhenViewIsTapped()
        
        AppearanceController.appearanceFor(textFields: [zipCodeTextField, addressTextField])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.pageVC = self.parent as? LandlordPageViewController
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if zipCodeTextField.text != "", zipCodeTextField.text?.characters.count == 5 || addressTextField.text != "" {
            saveAddressInformationToAccountCreationDictionary()
        }
    }
    
    @IBAction func zipCodeTextFieldDidChange(_ sender: Any) {
        
        if zipCodeTextField.text?.characters.count == 5 {
            zipCodeTextField.resignFirstResponder()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.parent?.dismiss(animated: true, completion: nil)
    }
    
    //    @IBAction func nextButtonTapped(_ sender: AnyObject) {
    //
    ////        let zipCode = zipCodeTextField.text?.trimmingCharacters(in: .letters)
    //
    //        if zipCodeTextField.text != "", zipCodeTextField.text?.characters.count == 5 || addressTextField.text != "" {
    //            saveAddressInformationToAccountCreationDictionary()
    //            AccountCreationController.pageRightFrom(landlordVC: self)
    //        } else {
    //            let alert = UIAlertController(title: "Hold on a second!", message: "Please enter both a valid zip code and address before continuing", preferredStyle: .alert)
    //            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
    //            alert.addAction(dismissAction)
    //            alert.view.tintColor = .black
    //            self.present(alert, animated: true, completion: nil)
    //
    //        }
    //    }
    
    func saveAddressInformationToAccountCreationDictionary() {
        
        UserController.addAttributeToUserDictionary(attribute: [UserController.kAddress : addressTextField.text ?? "No address"])
        UserController.addAttributeToUserDictionary(attribute: [UserController.kZipCode: zipCodeTextField.text ?? "No zip code"])
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
        if zipCodeTextField.text?.characters.count == 5 || addressTextField.text != ""  {
            
            AccountCreationController.addNextVCToLandlordPageVCDataSource(landlordVC: self)
            //            if didSlide == false {
            //                nextButton.center.x += 200
            //                nextButton.slideFromRight()
            //                didSlide = true
            //            }
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
