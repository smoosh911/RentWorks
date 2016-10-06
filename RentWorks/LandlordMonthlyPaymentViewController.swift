//
//  LandlordMonthlyPaymentViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/6/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordMonthlyPaymentViewController: UIViewController {

    @IBOutlet weak var monthlyPaymentLabel: UILabel!
    @IBOutlet weak var paymentSlider: UISlider!
    @IBOutlet weak var paymentBackgroundView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundViewAppearance()
        AppearanceController.appearanceFor(nextButton: nextButton)

    }

    func backgroundViewAppearance() {
        paymentBackgroundView.layer.borderColor = UIColor.gray.cgColor
        paymentBackgroundView.layer.borderWidth = 1
        paymentBackgroundView.layer.cornerRadius = 10
    }
    
    @IBAction func paymentSliderValueChanged(_ sender: UISlider) {
        
        // TODO: - Update monthlyPaymentLabel here
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
