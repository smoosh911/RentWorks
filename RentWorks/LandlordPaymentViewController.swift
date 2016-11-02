//
//  LandlordPaymentViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordPaymentViewController: UIViewController {

    @IBOutlet weak var paymentSlider: UISlider!
    @IBOutlet weak var paymentAmountLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserController.canPage = true
        nextButton.isHidden = true
        
        nextButton.slideFromRight()
        
        paymentAmountLabel.text = "$\(Int(paymentSlider.value)) per month"
    }

    @IBAction func paymentSliderValueChanged(_ sender: UISlider) {
        paymentAmountLabel.text = "$\(Int(paymentSlider.value)) per month"
        if paymentSlider.value >= 3000 {
            paymentAmountLabel.text = "$\(Int(paymentSlider.value))+ per month"

        }
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        UserController.pageRightfrom(currentVC: self)
        
         UserController.addAttributeToUserDictionary(attribute: [UserController.kMonthlyPayment: Int(paymentSlider.value)])
    }
    
    // MARK: - Navigation
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
}
