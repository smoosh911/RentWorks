//
//  RenterBedroomViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class RenterBedroomViewController: UIViewController {
    
    @IBOutlet weak var bedroomCountLabel: UILabel!
    @IBOutlet weak var bathroomCountLabel: UILabel!
    @IBOutlet weak var bedroomStepper: UIStepper!
    @IBOutlet weak var bathroomStepper: UIStepper!
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.isHidden = true
        
        nextButton.slideFromRight()
        
        bedroomCountLabel.text = "1 bedroom"
        bathroomCountLabel.text = "0.5 bathroom"
    }
    
    @IBAction func bedroomStepperValueChanged(_ sender: UIStepper) {
        if sender.value > 1 {
            if sender.value.isInteger {
                let intValue = Int(sender.value)
                bedroomCountLabel.text = "\(intValue) bedrooms"
            } else {
                bedroomCountLabel.text = "\(sender.value) bedrooms"
            }
        } else {
            if sender.value == 1 {
                bedroomCountLabel.text = "1 bedroom"
            } else {
                bedroomCountLabel.text = "\(sender.value) bedroom"
            }
        }
    }
    
    @IBAction func bathroomStepperValueChanged(_ sender: UIStepper) {
        if sender.value > 1 {
            if sender.value.isInteger {
                let intValue = Int(sender.value)
                bathroomCountLabel.text = "\(intValue) bathrooms"
            } else {
                bathroomCountLabel.text = "\(sender.value) bathrooms"
            }
        } else {
            if sender.value == 1 {
                bathroomCountLabel.text = "1 bathroom"
            } else {
                bathroomCountLabel.text = "\(sender.value) bathroom"
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        UserController.addAttributeToUserDictionary(attribute: [UserController.kBedroomCount: bedroomStepper.value])
        
        UserController.addAttributeToUserDictionary(attribute: [UserController.kBathroomCount: bathroomStepper.value])
        
    }
}
