//
//  RenterCreditRatingViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class RenterCreditRatingViewController: UIViewController {
    
    @IBOutlet weak var aPlusCreditButton: UIButton!
    @IBOutlet weak var aPlusCreditLabel: UILabel!
    @IBOutlet weak var aPlusCreditScoreLabel: UILabel!
    @IBOutlet weak var aPlusCreditBackgroundView: UIView!
    
    @IBOutlet weak var aCreditButton: UIButton!
    @IBOutlet weak var aCreditLabel: UILabel!
    @IBOutlet weak var aCreditScoreLabel: UILabel!
    @IBOutlet weak var aCreditBackgroundView: UIView!
    
    @IBOutlet weak var bCreditButton: UIButton!
    @IBOutlet weak var bCreditLabel: UILabel!
    @IBOutlet weak var bCreditScoreLabel: UILabel!
    @IBOutlet weak var bCreditBackgroundView: UIView!
    
    @IBOutlet weak var otherCreditButton: UIButton!
    @IBOutlet weak var otherCreditLabel: UILabel!
    @IBOutlet weak var otherCreditScoreLabel: UILabel!
    @IBOutlet weak var otherCreditBackgroundView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    
    let buttonPressedColor = AppearanceController.buttonPressedColor
    
    var creditRating: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//        nextButton.isHidden = true
//        nextButton.center.x += 200
        
        aPlusCreditBackgroundView.layer.cornerRadius = 15
        aCreditBackgroundView.layer.cornerRadius = 15
        bCreditBackgroundView.layer.cornerRadius = 15
        otherCreditBackgroundView.layer.cornerRadius = 15
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveCreditRatingInformationToUserCreationDictionary()
    }
    
    @IBAction func creditAPlusButtonTapped(_ sender: UIButton) {
        creditRating = UserController.CreditRating.a.rawValue
        buttonPressedAppearanceFor(backgroundView: aPlusCreditBackgroundView, letterLabel: aPlusCreditLabel, and: aPlusCreditScoreLabel)
        
    }
    
    @IBAction func creditAButtonTapped(_ sender: UIButton) {
        creditRating = UserController.CreditRating.b.rawValue
        buttonPressedAppearanceFor(backgroundView: aCreditBackgroundView, letterLabel: aCreditLabel, and: aCreditScoreLabel)
    }
    
    @IBAction func creditBButtonTapped(_ sender: UIButton) {
        creditRating = UserController.CreditRating.c.rawValue
        buttonPressedAppearanceFor(backgroundView: bCreditBackgroundView, letterLabel: bCreditLabel, and: bCreditScoreLabel)
    }
    
    @IBAction func creditOtherButtonTapped(_ sender: UIButton) {
        creditRating = UserController.CreditRating.d.rawValue
        buttonPressedAppearanceFor(backgroundView: otherCreditBackgroundView, letterLabel: otherCreditLabel, and: otherCreditScoreLabel)
        
    }
    
    
    func buttonPressedAppearanceFor(backgroundView: UIView, letterLabel: UILabel, and scoreLabel: UILabel) {
        self.showAndAnimateNextButton()
        
        AccountCreationController.addNextVCToRenterPageVCDataSource(renterVC: self)

        let buttonBackgroundViews = [aPlusCreditBackgroundView, aCreditBackgroundView, bCreditBackgroundView, otherCreditBackgroundView].filter({$0 != backgroundView})
        
        let otherLabels = [aPlusCreditLabel, aPlusCreditScoreLabel, aCreditLabel, aCreditScoreLabel, bCreditLabel, bCreditScoreLabel, otherCreditLabel, otherCreditScoreLabel].filter({$0 != letterLabel}).filter({$0 != scoreLabel})
        
        UIView.transition(with: backgroundView, duration: 0.1, options: .transitionCrossDissolve, animations: {
            backgroundView.backgroundColor = AppearanceController.viewButtonPressedColor
            letterLabel.textColor = AppearanceController.buttonPressedColor
            scoreLabel.textColor = AppearanceController.buttonPressedColor
            
        }) { _ in
            
            UIView.transition(with: backgroundView, duration: 0.2, options: .transitionCrossDissolve, animations: { 
                buttonBackgroundViews.forEach({$0?.backgroundColor = AppearanceController.customOrangeColor})
                otherLabels.forEach({$0?.textColor = .white})
                letterLabel.textColor = .white
                scoreLabel.textColor = .white
            }, completion: { (_) in
            })
            
        }
    }
    
    
    func showAndAnimateNextButton() {
//        if nextButton.isHidden {
//            nextButton.slideFromRight()
//        }
    }

    func saveCreditRatingInformationToUserCreationDictionary() {
        UserController.addAttributeToUserDictionary(attribute: [UserController.kCreditRating : creditRating])
    }
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        if creditRating != "" {
            saveCreditRatingInformationToUserCreationDictionary()
            AccountCreationController.pageRightFrom(renterVC: self)
        } else {
            let alert = UIAlertController(title: "Hold on a second!", message: "Please select your current credit score.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
