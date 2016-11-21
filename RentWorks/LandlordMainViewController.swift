//
//  LandlordMainViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordMainViewController: MainViewController {
    
    @IBOutlet weak var lblFrontCardCreditRating: UILabel!
    @IBOutlet weak var lblBackCardCreditRating: UILabel!
    
    var wantsCreditRating = ""
    
    var cardsAreLoading = false {
        didSet {
            if cardsAreLoading {
                let storyboard = UIStoryboard(name: "LandlordMain", bundle: nil)
                let mainVC = storyboard.instantiateViewController(withIdentifier: "cardLoadingVC")
                self.present(mainVC, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let desiredCreditRating = UserController.currentLandlord?.wantsCreditRating {
            wantsCreditRating = desiredCreditRating
            FirebaseController.renters = desiredCreditRating == "Any" ? FirebaseController.renters : FirebaseController.renters.filter({ $0.creditRating == desiredCreditRating})
            
            if !(FirebaseController.renters.count > 0) {
                super.swipeableView.isHidden = true
                super.backgroundView.isHidden = true
                self.performSegue(withIdentifier: Identifiers.Segues.MoreCardsVC.rawValue, sender: self)
                return
            } else {
                super.swipeableView.isHidden = false
            }
            self.updateRenterCardUI()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if super.previousVCWasCardsLoadingVC {
            super.previousVCWasCardsLoadingVC = false
        } else {
            if let desiredCreditRating = UserController.currentLandlord?.wantsCreditRating {
                if wantsCreditRating != desiredCreditRating {
                    cardsAreLoading = true
                    UserController.fetchAllRentersAndWait(completion: {
                        FirebaseController.renters = desiredCreditRating == "Any" ? FirebaseController.renters : FirebaseController.renters.filter({ $0.creditRating == desiredCreditRating})
                        
                        if !(FirebaseController.renters.count > 0) {
                            super.swipeableView.isHidden = true
                            super.backgroundView.isHidden = true
                            return
                        } else {
                            super.swipeableView.isHidden = false
                        }
                        self.cardsAreLoading = false
                        self.updateRenterCardUI()
                    })
                }
            }
        }
    }
    
    func updateRenterCardUI() {
        if !(FirebaseController.renters.count > 0) {
            return
        }
        super.updateUIElementsForRenterCards()
        let renter = FirebaseController.renters[super.imageIndex]
        var backCardRenter: Renter? = nil
        if !super.backgroundView.isHidden {
            backCardRenter = FirebaseController.renters[super.imageIndex-1]
        }
        
        lblFrontCardCreditRating.text = renter.creditRating
        lblBackCardCreditRating.text = backCardRenter == nil ? "" : backCardRenter!.creditRating
    }
}
