//
//  RenterCreditRatingViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class RenterCreditRatingViewController: UIViewController {
    
    @IBOutlet weak var aCreditButton: UIButton!
    @IBOutlet weak var aCreditLabel: UILabel!
    
    @IBOutlet weak var bCreditButton: UIButton!
    @IBOutlet weak var bCreditLabel: UILabel!
    
    @IBOutlet weak var cCreditButton: UIButton!
    @IBOutlet weak var cCreditLabel: UILabel!
    
    @IBOutlet weak var dCreditButton: UIButton!
    @IBOutlet weak var dCreditLabel: UILabel!
    
    var creditRating: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func creditAButtonTapped(_ sender: UIButton) {
        creditRating = UserController.CreditRating.a.rawValue
        greenButtonSelectionFor(buttonLabel: aCreditLabel)
    }
    
    @IBAction func creditBButtonTapped(_ sender: UIButton) {
        creditRating = UserController.CreditRating.b.rawValue
        greenButtonSelectionFor(buttonLabel: bCreditLabel)
    }

    @IBAction func creditCButtonTapped(_ sender: UIButton) {
        creditRating = UserController.CreditRating.c.rawValue
        greenButtonSelectionFor(buttonLabel: cCreditLabel)
    }
    
    @IBAction func creditDButtonTapped(_ sender: UIButton) {
        creditRating = UserController.CreditRating.d.rawValue
        greenButtonSelectionFor(buttonLabel: dCreditLabel)
    }
    
    
    func greenButtonSelectionFor(buttonLabel: UILabel) {
        let buttonLabels = [aCreditLabel, bCreditLabel, cCreditLabel, dCreditLabel].filter({$0 != buttonLabel})
        
        UIView.transition(with: buttonLabel, duration: 0.3, options: .transitionCrossDissolve, animations: {
            buttonLabel.textColor = .green
            }, completion: nil)
        
        for label in buttonLabels {
            guard let label = label else { return }
            UIView.transition(with: label, duration: 0.3, options: .transitionCrossDissolve, animations: {
                label.textColor = .white
                }, completion: nil)
        }
        
    }
    
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        if creditRating != "" {
            UserController.addAttributeToUserDictionary(attribute: [UserController.UserDictionaryKeys.kCreditRating : creditRating])
            self.performSegue(withIdentifier: "toFinalUserCreationVC", sender: self)
        } else {
            let alert = UIAlertController(title: "Hold on a second!", message: "Please select your current credit score.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
