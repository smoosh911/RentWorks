//
//  LandlordAllowedViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordAllowedViewController: UIViewController {
    
    @IBOutlet weak var petsAllowedButton: UIButton!
    @IBOutlet weak var noPetsAllowedButton: UIButton!
    @IBOutlet weak var smokingAllowedButton: UIButton!
    @IBOutlet weak var noSmokingButton: UIButton!
//    @IBOutlet weak var nextButton: UIButton!
    
    var smokingAllowed: Bool?
    var petsAllowed: Bool?
    
    let buttonPressedColor = AppearanceController.buttonPressedColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        nextButton.isHidden = true
        
        petsAllowedButton.layer.cornerRadius = 15
        noPetsAllowedButton.layer.cornerRadius = 15
        smokingAllowedButton.layer.cornerRadius = 15
        noSmokingButton.layer.cornerRadius = 15
        
    }
    @IBAction func petsAllowedButtonTapped(_ sender: AnyObject) {
        petsAllowedButton.backgroundColor = AppearanceController.viewButtonPressedColor
        noPetsAllowedButton.backgroundColor = .clear
        
        petsAllowed = true
        
        checkIfBothButtonsHaveBeenSelected()
        
    }
    
    @IBAction func noPetsAllowedButtonTapped(_ sender: AnyObject) {
        noPetsAllowedButton.backgroundColor = AppearanceController.viewButtonPressedColor
        petsAllowedButton.backgroundColor = .clear
        
        petsAllowed = false
        
        checkIfBothButtonsHaveBeenSelected()
        
    }
    
    @IBAction func smokingAllowedButtonTapped(_ sender: AnyObject) {
        smokingAllowedButton.backgroundColor = AppearanceController.viewButtonPressedColor
        noSmokingButton.backgroundColor = .clear
        
        smokingAllowed = true
        
        checkIfBothButtonsHaveBeenSelected()
    }
    
    @IBAction func noSmokingButtonTapped(_ sender: AnyObject) {
        noSmokingButton.backgroundColor = AppearanceController.viewButtonPressedColor
        smokingAllowedButton.backgroundColor = .clear
        
        smokingAllowed = false
        
        checkIfBothButtonsHaveBeenSelected()
    }
    
//    @IBAction func nextButtonTapped(_ sender: AnyObject) {
//        if let petsAllowed = petsAllowed, let smokingAllowed = smokingAllowed {
//            UserController.addAttributeToUserDictionary(attribute: [UserController.kPetsAllowed: petsAllowed])
//            UserController.addAttributeToUserDictionary(attribute: [UserController.kSmokingAllowed: smokingAllowed])
//            
//            AccountCreationController.pageRightFrom(landlordVC: self)
//        } else {
//            presentAllowedAlert()
//        }
//    }
    
    func checkIfBothButtonsHaveBeenSelected() {
        if smokingAllowed != nil, petsAllowed != nil /* , nextButton.isHidden == true */ {
//            nextButton.center.x += 200
//            nextButton.slideFromRight()
            
            
            AccountCreationController.addNextVCToLandlordPageVCDataSource(landlordVC: self)
        }
    }
    
    func presentAllowedAlert() {
        let alert = UIAlertController(title: "Hold on a second!", message: "Please select whether you allow pets and smoking on your property before continuing.", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alert.addAction(dismissAction)
        
        alert.view.tintColor = .black
        
        self.present(alert, animated: true, completion: nil)
    }
}
