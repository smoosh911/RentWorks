    //
//  CardLoadingViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 11/8/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import FirebaseAuth

class CardLoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if UserController.currentUserType == "renter" {
//            PropertyController.fetchProperties(numberOfProperties: FirebaseController.cardDownloadCount, completion: {
//                self.propertiesWereUpdated()
//            })

    }
    
//    func propertiesWereUpdated() {
//        MatchController.observeLikesForCurrentRenter()
//        self.performSegue(withIdentifier: Identifiers.Segues.MainSwipingVC.rawValue, sender: nil)
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserController.currentUserType == "landlord" {
            if FIRAuth.auth()?.currentUser == nil {
                loadLandlordPreview()
            } else {
                PropertyController.fetchPropertiesForLandlord(landlordID: UserController.currentUserID!, completion: { success in
                    if success {
                        self.landlordPropertiesLoaded()
                    }
                })
            }
        }
    }
    
    private func landlordPropertiesLoaded() {
        MatchController.observeLikesForCurrentLandlord()
        self.performSegue(withIdentifier: Identifiers.Segues.PropertiesViewVC.rawValue, sender: nil)
    }
    
    private func loadLandlordPreview() {
        self.performSegue(withIdentifier: Identifiers.Segues.swipingVC.rawValue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.PropertiesViewVC.rawValue {
            if let desinationNav = segue.destination as? UINavigationController {
                if let childVC = desinationNav.viewControllers[0] as? LandlordMainViewController {
                    childVC.previousVCWasCardsLoadingVC = true
                }
//                else if let childVC = desinationNav.viewControllers[0] as? RenterMainViewController {
//                    childVC.previousVCWasCardsLoadingVC = true
//                }
            }
        }
    }
}
