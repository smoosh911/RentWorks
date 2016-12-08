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
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var paymentSliderBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.isHidden = true
        
        nextButton.slideFromRight()
        
        paymentSliderBackgroundView.layer.cornerRadius = 4
        
        AccountCreationController.addNextVCToRenterPageVCDataSource(renterVC: self)
        
        paymentAmountLabel.text = "$\(Int(paymentSlider.value)) per month"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        savePaymentAmountInformationToUserCreationDictionary()
    }
    
    @IBAction func paymentSliderValueChanged(_ sender: UISlider) {
        let roundBy: Float = 25.0
        let price = Int(round(value: sender.value, toNearest: roundBy))
        paymentAmountLabel.text = "$\(price) per month"
        if paymentSlider.value >= 3000 {
            paymentAmountLabel.text = "$\(price)+ per month"
            
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        savePaymentAmountInformationToUserCreationDictionary()
        AccountCreationController.pageRightFrom(renterVC: self)
    }

    func savePaymentAmountInformationToUserCreationDictionary() {
         UserController.addAttributeToUserDictionary(attribute: [UserController .kMonthlyPayment: Int(paymentSlider.value)])
    }
    // MARK: - Navigation
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
}
