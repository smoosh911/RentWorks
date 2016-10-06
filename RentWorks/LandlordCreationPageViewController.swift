//
//  LandlordCreationPageViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/6/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordCreationPageViewController: UIPageViewController {

    let first = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandlordVC1")
    let second = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandlordVC2")
    let third = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandlordVC3")
    let fourth = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandlordVC4")
    let fifth = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandlordVC5")
    //let sixth = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SixthViewController")
    
    
    var orderedViewControllers: [UIViewController] {
        return [first, second, third, fourth, fifth]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        if let firstVC = orderedViewControllers.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }
    
//    private func newViewController(name: String) -> UIViewController {
//        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(name)ViewController")
//    }
    
}

extension LandlordCreationPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }

}
