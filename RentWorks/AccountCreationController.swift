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
    
    
    static var currentRenterVCs: [UIViewController] = [] {
        didSet {
            currentRenterVCs.forEach({print($0.description)})
            print("\n\n\n\n\n")
        }
    }
    
    static func addNextVCToRenterPageVCDataSource(renterVC: UIViewController) {
        guard let pageVC = renterVC.parent as? RenterPageViewController, let currentVCIndex = pageVC.renterVCs.index(of: renterVC) else { return }
        let nextVC = pageVC.renterVCs[currentVCIndex + 1]
        guard !currentRenterVCs.contains(nextVC) else { return }
        currentRenterVCs.append(nextVC)
//        AccountCreationController.resetRenterPageVCDataSourceFor(renterVC: renterVC)
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
