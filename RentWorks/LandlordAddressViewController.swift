//
//  LandlordAddressViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/6/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import DropDown

// needs work: a lot of this view and the renter view are the same. They should be inheriting
class LandlordAddressViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: outlets
    
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var vwAddress: UIView!
    @IBOutlet weak var titleView: UIView!
    
    // MARK: variables
    
    var dropDown: DropDown = DropDown()
    
    var cities: [City] = []
    var selectedCity: City?
    
    var pageVC: LandlordPageViewController?
    
    var didSlide = false
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDropDown()
        
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
    
    // MARK: dropdown
    
    private func itemSelected(index: Int, item: String) {
        addressTextField.text = item
        selectedCity = cities[index]
        saveAddressInformationToAccountCreationDictionary()
    }
    
    private func setupDropDown() {
        dropDown.anchorView = vwAddress
        dropDown.cornerRadius = 0
        dropDown.topOffset = CGPoint(x: 0, y: -vwAddress.frame.height)
        dropDown.selectionAction = itemSelected
    }
    
    // MARK: actions
    
    @IBAction func zipCodeTextFieldDidChange(_ sender: Any) {
        
        if zipCodeTextField.text?.characters.count == 5 {
            zipCodeTextField.resignFirstResponder()
        }
    }
    
    // text fields
    
    @IBAction func txtfldAdress_EditingChanged(_ sender: UITextView) {
        guard let city = sender.text else { return }
        if city.characters.count > 3 {
            LocationManager.getCitiesWith(cityName: city, resultCount: 5) { (cityResults) in
                guard let cityResults = cityResults else { return }
                self.cities = cityResults
                let cityStrings = self.cities.flatMap({ $0.getCityStateString() })
                self.dropDown.dataSource = cityStrings
                self.dropDown.show()
            }
        }
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
    
    // buttons
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.parent?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: text field delegate
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: helper functions
    
    private func saveAddressInformationToAccountCreationDictionary() {
        guard let city = selectedCity else { return }
        let cityName = city.name
        let state = city.state
        let country = city.country
        
        UserController.addAttributeToUserDictionary(attribute: [UserController.kCity: cityName ?? ""])
        UserController.addAttributeToUserDictionary(attribute: [UserController.kState: state ?? ""])
        UserController.addAttributeToUserDictionary(attribute: [UserController.kCountry: country ?? ""])
        UserController.addAttributeToUserDictionary(attribute: [UserController.kAddress: ""])
        UserController.addAttributeToUserDictionary(attribute: [UserController.kZipCode: zipCodeTextField.text ?? "No zip code"])
    }
    
    // MARK: keyboard
    
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
}
