//
//  CreateAccountViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 9/24/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController {
    
    
    @IBOutlet weak var accountTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var maritalStatusTextField: UITextField!
    @IBOutlet weak var numberOfAdultsTextField: UITextField!
    @IBOutlet weak var numberOfChildrenTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var numberOfBedRoomsTextField: UITextField!
    @IBOutlet weak var numberOfBathroomsTextField: UITextField!
    @IBOutlet weak var smokingAllowedTextField: UITextField!
    @IBOutlet weak var petFriendlyTextField: UITextField!
    @IBOutlet weak var dateAvailableTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayTextFieldsForAccountType()
    }
    
    
    func displayTextFieldsForAccountType() {
        
        switch accountTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            UIView.animate(withDuration: 1, animations: {
                self.maritalStatusTextField.isHidden = false
                self.numberOfAdultsTextField.isHidden = false
                self.numberOfChildrenTextField.isHidden = false
                self.addressTextField.isHidden = true // Is it necessary to have an address for the renters?
                self.numberOfBedRoomsTextField.isHidden = true
                self.numberOfBathroomsTextField.isHidden = true
                self.smokingAllowedTextField.isHidden = true
                self.petFriendlyTextField.isHidden = true
                self.dateAvailableTextField.isHidden = true
            })
            
        case 1:
            UIView.animate(withDuration: 1, animations: {
                self.maritalStatusTextField.isHidden = true
                self.numberOfAdultsTextField.isHidden = true
                self.numberOfChildrenTextField.isHidden = true
                self.addressTextField.isHidden = false // Is it necessary to have an address for the renters?
                self.numberOfBedRoomsTextField.isHidden = false
                self.numberOfBathroomsTextField.isHidden = false
                self.smokingAllowedTextField.isHidden = false
                self.petFriendlyTextField.isHidden = false
                self.dateAvailableTextField.isHidden = false
            })
            
        default:
            break
        }
    }
    
    @IBAction func accountTypeSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        displayTextFieldsForAccountType()
    }
}
