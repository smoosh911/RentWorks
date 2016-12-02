//
//  CardLoadingViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 11/8/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class CardLoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserController.currentUserType == "renter" {
            UserController.fetchProperties(numberOfProperties: FirebaseController.cardDownloadCount, completion: { 
                self.propertiesWereUpdated()
            })
        } else if UserController.currentUserType == "landlord" {
            UserController.fetchPropertiesForLandlord(landlordID: UserController.currentUserID!, completion: {
                self.landlordPropertiesLoaded()
            })
        }
    }
    
    func propertiesWereUpdated() {
        MatchController.observeLikesForCurrentRenter()
        self.performSegue(withIdentifier: Identifiers.Segues.MainSwipingVC.rawValue, sender: nil)
    }
    
    func landlordPropertiesLoaded() {
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
