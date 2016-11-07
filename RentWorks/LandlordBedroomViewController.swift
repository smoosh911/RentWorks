//
//  LandlordBedroomViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordBedroomViewController: UIViewController {
    
    @IBOutlet weak var bedroomCountLabel: UILabel!
    @IBOutlet weak var bathroomCountLabel: UILabel!
    @IBOutlet weak var bedroomStepper: UIStepper!
    @IBOutlet weak var bathroomStepper: UIStepper!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AccountCreationController.addNextVCToLandlordPageVCDataSource(landlordVC: self)

        nextButton.isHidden = true

        nextButton.slideFromRight()
        
//        bedroomStepper.setIncrementImage(#imageLiteral(resourceName: "addStepper"), for: .normal)
//        bathroomStepper.setIncrementImage(#imageLiteral(resourceName: "addStepper"), for: .normal)
        
        bedroomCountLabel.text = "1"
        bathroomCountLabel.text = "1"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveRoomInformationToUserCreationDictionary()
    }
    
    @IBAction func bedroomStepperValueChanged(_ sender: UIStepper) {
        if sender.value > 1 {
            if sender.value.isInteger {
                let intValue = Int(sender.value)
                bedroomCountLabel.text = "\(intValue)"
            } else {
                bedroomCountLabel.text = "\(sender.value)"
            }
        } else {
            if sender.value == 1 {
                bedroomCountLabel.text = "1"
            } else {
                bedroomCountLabel.text = "\(sender.value)"
            }
        }
    }
    
    @IBAction func bathroomStepperValueChanged(_ sender: UIStepper) {
        if sender.value > 1 {
            if sender.value.isInteger {
                let intValue = Int(sender.value)
                bathroomCountLabel.text = "\(intValue)"
            } else {
                bathroomCountLabel.text = "\(sender.value)"
            }
        } else {
            if sender.value == 1 {
                bathroomCountLabel.text = "1"
            } else {
                bathroomCountLabel.text = "\(sender.value)"
            }
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        saveRoomInformationToUserCreationDictionary()
        AccountCreationController.pageRightFrom(renterVC: self)
        
    }
    
    func saveRoomInformationToUserCreationDictionary() {
        UserController.addAttributeToUserDictionary(attribute: [UserController.kBedroomCount: bedroomStepper.value])
        
        UserController.addAttributeToUserDictionary(attribute: [UserController.kBathroomCount: bathroomStepper.value])
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
}

extension Double {
    var isInteger: Bool { return rint(self) == self }
}
