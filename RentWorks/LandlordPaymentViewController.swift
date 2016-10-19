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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        paymentAmountLabel.text = "$\(Int(paymentSlider.value)) per month"
        // Do any additional setup after loading the view.
    }

    @IBAction func paymentSliderValueChanged(_ sender: UISlider) {
        paymentAmountLabel.text = "$\(Int(paymentSlider.value)) per month"
        if paymentSlider.value >= 3000 {
            paymentAmountLabel.text = "$\(Int(paymentSlider.value))+ per month"

        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        UserController.addAttributeToUserDictionary(attribute: [UserController.kMonthlyPayment: Int(paymentSlider.value)])
    }
    

}
