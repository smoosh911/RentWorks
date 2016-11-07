//
//  LandlordPageViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 11/2/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordPageViewController: UIPageViewController {
    
    private(set) lazy var landlordVCs: [UIViewController] = {
        let storyboard = UIStoryboard(name: "LandlordCreationViews", bundle: nil)
        
        let vc1 = storyboard.instantiateViewController(withIdentifier: "LandlordAddressVC")
        let vc2 = storyboard.instantiateViewController(withIdentifier: "LandlordRoomVC")
        let vc3 = storyboard.instantiateViewController(withIdentifier: "LandlordPaymentVC")
        let vc4 = storyboard.instantiateViewController(withIdentifier: "LandlordAllowedVC")
        let vc5 = storyboard.instantiateViewController(withIdentifier: "LandlordFeaturesVC")
        let vc6 = storyboard.instantiateViewController(withIdentifier: "LandlordAddPhotosVC")
        let vc7 = storyboard.instantiateViewController(withIdentifier: "LandlordPropertyAvailableVC")
        let vc8 = storyboard.instantiateViewController(withIdentifier: "finalAccountCreationVC")
        return [vc1, vc2, vc3, vc4, vc5, vc6, vc7, vc8]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        self.view.backgroundColor = AppearanceController.customOrangeColor
        if let vc1 = landlordVCs.first {
            setViewControllers([vc1], direction: .forward, animated: true, completion: nil)
        }
        
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


extension LandlordPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
            
            guard let viewControllerIndex = landlordVCs.index(of: viewController) else { return nil }
            
            let previousIndex = viewControllerIndex - 1
            
            guard previousIndex >= 0, AccountCreationController.currenLandlordVCs.count > previousIndex else { return nil }
            
            return landlordVCs[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
            guard let viewControllerIndex = landlordVCs.index(of: viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            let landlordVCsCount = AccountCreationController.currenLandlordVCs.count
            
            guard landlordVCsCount != nextIndex, landlordVCsCount > nextIndex else { return nil }
            
            return landlordVCs[nextIndex]
        }
    }
