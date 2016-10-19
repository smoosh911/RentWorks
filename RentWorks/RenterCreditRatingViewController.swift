//
//  RenterCreditRatingViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class RenterCreditRatingViewController: UIViewController {
    
    
    var creditRating: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func creditAButtonTapped(_ sender: AnyObject) {
        creditRating = UserController.CreditRating.a.rawValue
    }
    
    @IBAction func creditBButtonTapped(_ sender: AnyObject) {
        creditRating = UserController.CreditRating.b.rawValue
    }

    @IBAction func creditCButtonTapped(_ sender: AnyObject) {
        creditRating = UserController.CreditRating.c.rawValue
    }
    
    @IBAction func creditDButtonTapped(_ sender: AnyObject) {
        creditRating = UserController.CreditRating.d.rawValue
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
