//
//  RenterPaymentViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class RenterPaymentViewController: UIViewController {
    @IBOutlet weak var paymentSlider: UISlider!
    @IBOutlet weak var paymentAmountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        paymentAmountLabel.text = "$\(Int(paymentSlider.value)) per month"
    }
    
    @IBAction func paymentSliderValueChanged(_ sender: UISlider) {
        paymentAmountLabel.text = "$\(Int(paymentSlider.value)) per month"
        if paymentSlider.value >= 3000 {
            paymentAmountLabel.text = "$\(Int(paymentSlider.value))+ per month"
            
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        UserController.addAttributeToUserDictionary(attribute: [UserController .kMonthlyPayment: Int(paymentSlider.value)])
    }
}
