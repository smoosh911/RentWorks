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
    @IBOutlet weak var nextButton: UIButton!
    
    var smokingAllowed: Bool?
    var petsAllowed: Bool?
    
    let buttonPressedColor = AppearanceController.buttonPressedColor
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        nextButton.isHidden = true
        
        petsAllowedButton.layer.cornerRadius = 15
        noPetsAllowedButton.layer.cornerRadius = 15
        smokingAllowedButton.layer.cornerRadius = 15
        noSmokingButton.layer.cornerRadius = 15
        
    }
    @IBAction func petsAllowedButtonTapped(_ sender: AnyObject) {
        petsAllowedButton.setTitleColor(buttonPressedColor, for: .normal)
        noPetsAllowedButton.setTitleColor(.white, for: .normal)
        
        petsAllowedButton.backgroundColor = AppearanceController.viewButtonPressedColor
        noPetsAllowedButton.backgroundColor = AppearanceController.vengaYellowColor
        
        petsAllowed = true
        
        checkIfBothButtonsHaveBeenSelected()
        
    }
    
    @IBAction func noPetsAllowedButtonTapped(_ sender: AnyObject) {
        noPetsAllowedButton.setTitleColor(buttonPressedColor, for: .normal)
        petsAllowedButton.setTitleColor(.white, for: .normal)
        
        noPetsAllowedButton.backgroundColor = AppearanceController.viewButtonPressedColor
        petsAllowedButton.backgroundColor = AppearanceController.vengaYellowColor
        
        petsAllowed = false
        
        checkIfBothButtonsHaveBeenSelected()
        
    }
    
    @IBAction func smokingAllowedButtonTapped(_ sender: AnyObject) {
        smokingAllowedButton.setTitleColor(buttonPressedColor, for: .normal)
        noSmokingButton.setTitleColor(.white, for: .normal)
        
        smokingAllowedButton.backgroundColor = AppearanceController.viewButtonPressedColor
        noSmokingButton.backgroundColor = AppearanceController.vengaYellowColor
        smokingAllowed = true
        
        checkIfBothButtonsHaveBeenSelected()
    }
    
    @IBAction func noSmokingButtonTapped(_ sender: AnyObject) {
        noSmokingButton.setTitleColor(buttonPressedColor, for: .normal)
        smokingAllowedButton.setTitleColor(.white, for: .normal)
        
        noSmokingButton.backgroundColor = AppearanceController.viewButtonPressedColor
        smokingAllowedButton.backgroundColor = AppearanceController.vengaYellowColor
        
        smokingAllowed = true
        
        checkIfBothButtonsHaveBeenSelected()
    }
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        if let petsAllowed = petsAllowed, let smokingAllowed = smokingAllowed {
            UserController.addAttributeToUserDictionary(attribute: [UserController.kPetsAllowed: petsAllowed])
            UserController.addAttributeToUserDictionary(attribute: [UserController.kSmokingAllowed: smokingAllowed])
            
            AccountCreationController.pageRightFrom(landlordVC: self)
        } else {
            presentAllowedAlert()
        }
    }
    
    func checkIfBothButtonsHaveBeenSelected() {
        if smokingAllowed != nil, petsAllowed != nil, nextButton.isHidden == true {
            nextButton.slideFromRight()
            
            guard let pageVC = self.parent as? LandlordPageViewController else { return }
            pageVC.dataSource = nil
            pageVC.dataSource = pageVC
        }
    }
    
    func presentAllowedAlert() {
        let alert = UIAlertController(title: "Hold on a second!", message: "Please select whether you allow pets and smoking on your property before continuing.", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alert.addAction(dismissAction)
        
        alert.view.tintColor = AppearanceController.vengaYellowColor
        
        self.present(alert, animated: true, completion: nil)
    }
}
