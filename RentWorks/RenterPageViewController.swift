//
//  RenterPageViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 11/2/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class RenterPageViewController: UIPageViewController {
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        self.view.backgroundColor = AppearanceController.customOrangeColor
        if let vc1 = AccountCreationController.renterVCs.first {
            setViewControllers([vc1], direction: .forward, animated: true, completion: nil)
        }
        
    }
}


extension RenterPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = AccountCreationController.renterVCs.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0, AccountCreationController.currentRenterVCs.count > previousIndex else { return nil }
        
        return AccountCreationController.renterVCs[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = AccountCreationController.renterVCs.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let renterVCsCount = AccountCreationController.currentRenterVCs.count
        
        guard renterVCsCount != nextIndex, renterVCsCount > nextIndex else { return nil }
        
        return AccountCreationController.renterVCs[nextIndex]
    }
}
