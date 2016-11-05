//
//  RenterPageViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 11/2/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class RenterPageViewController: UIPageViewController {
   
    
    private(set) lazy var renterVCs: [UIViewController] = {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        self.view.backgroundColor = AppearanceController.customOrangeColor
        if let vc1 = renterVCs.first {
            setViewControllers([vc1], direction: .forward, animated: true, completion: nil)
        }
        
    }
}


extension RenterPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = renterVCs.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0, AccountCreationController.currentRenterVCs.count > previousIndex else { return nil }
        
        return renterVCs[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = renterVCs.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let renterVCsCount = AccountCreationController.currentRenterVCs.count
        
        guard renterVCsCount != nextIndex, renterVCsCount > nextIndex else { return nil }
        
        return renterVCs[nextIndex]
    }
}
