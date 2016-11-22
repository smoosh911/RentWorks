//
//  CardLoadingViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 11/8/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class CardLoadingViewController: UIViewController, FirebaseUserDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        FirebaseController.delegate = self
        
        if UserController.currentUserType == "renter" {
            UserController.fetchAllProperties()
        } else if UserController.currentUserType == "landlord" {
            UserController.fetchAllRenters()
        }
    }
    
    func propertiesWereUpdated() {
        MatchController.observeLikesForCurrentRenter()
        self.performSegue(withIdentifier: Identifiers.Segues.MainSwipingVC.rawValue, sender: nil)
    }
    
    func rentersWereUpdated() {
        MatchController.observeLikesForCurrentLandlord()
        self.performSegue(withIdentifier: Identifiers.Segues.MainSwipingVC.rawValue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.MainSwipingVC.rawValue {
            if let desinationNav = segue.destination as? UINavigationController {
                if let childVC = desinationNav.viewControllers[0] as? LandlordMainViewController {
                    childVC.previousVCWasCardsLoadingVC = true
                } else if let childVC = desinationNav.viewControllers[0] as? RenterMainViewController {
                    childVC.previousVCWasCardsLoadingVC = true
                }
            }
        }
    }
}
