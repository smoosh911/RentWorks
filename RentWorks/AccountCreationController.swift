//
//  AccountCreationController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 11/5/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class AccountCreationController {
    
    static let sharedController = AccountCreationController()
    
    static var renterVCs: [UIViewController] = {
        let storyboard = UIStoryboard(name: "RenterCreationViews", bundle: nil)
        
        let vc1 = storyboard.instantiateViewController(withIdentifier: "RenterAddressVC")
        let vc2 = storyboard.instantiateViewController(withIdentifier: "RenterRoomVC")
        let vc3 = storyboard.instantiateViewController(withIdentifier: "RenterAllowedVC")
        let vc4 = storyboard.instantiateViewController(withIdentifier: "RenterFeaturesVC")
        let vc5 = storyboard.instantiateViewController(withIdentifier: "RenterPaymentVC")
        let vc6 = storyboard.instantiateViewController(withIdentifier: "RenterCreditScoreVC")
        let vc7 = storyboard.instantiateViewController(withIdentifier: "finalAccountCreationVC")
        return [vc1, vc2, vc3, vc4, vc5, vc6, vc7]
    }()
    
    static var currentRenterVCs: [UIViewController] = [] {
        didSet {
            currentRenterVCs.forEach({print($0.description)})
            print("\n\n\n\n\n")
        }
    }
    
    static func addNextVCToRenterPageVCDataSource(renterVC: UIViewController) {
        guard let currentVCIndex = renterVCs.index(of: renterVC), let pageVC = renterVC.parent as? RenterPageViewController else { return }
        let nextVC = renterVCs[currentVCIndex + 1]
        guard !currentRenterVCs.contains(nextVC) else { return }
        currentRenterVCs.append(nextVC)
        AccountCreationController.resetRenterPageVCDataSourceFor(renterVC: renterVC)
        pageVC.setViewControllers([self], direction: .forward, animated: true, completion: nil)
        
    }
    
    static func resetRenterPageVCDataSourceFor(renterVC: UIViewController) {
        guard let pageVC = renterVC.parent as? RenterPageViewController else { return }
        pageVC.dataSource = nil
        pageVC.dataSource = pageVC
    }
    
    static func pageRightFrom(landlordVC currentVC: UIViewController) {
        guard let pageVC = currentVC.parent as? LandlordPageViewController else { return }
        guard let currentVCIndex = pageVC.landlordVCs.index(of: currentVC), currentVCIndex + 1 <= pageVC.landlordVCs.count else { return }
        
        let newIndex = currentVCIndex + 1
        let nextVC = pageVC.landlordVCs[newIndex]
        pageVC.setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
    }
    
    
    static func pageRightFrom(renterVC currentVC: UIViewController) {
        guard let pageVC = currentVC.parent as? RenterPageViewController else { return }
        guard let currentVCIndex = self.currentRenterVCs.index(of: currentVC), currentVCIndex + 1 <= self.currentRenterVCs.count else { return }
        
        let newIndex = currentVCIndex + 1
        let nextVC = self.currentRenterVCs[newIndex]
        pageVC.setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
    }
    
}
