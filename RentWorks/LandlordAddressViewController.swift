////
////  LandlordAddressViewController.swift
////  RentWorks
////
////  Created by Spencer Curtis on 10/6/16.
////  Copyright © 2016 Michael Perry. All rights reserved.
////
//
//import UIKit
//
//class LandlordAddressViewController: UIViewController {
//    
//    @IBOutlet weak var zipCodeTextField: UITextField!
//    @IBOutlet weak var addressTextField: UITextField!
//    @IBOutlet weak var nextButton: UIButton!
//    
//    var pageViewController: LandlordCreationPageViewController?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        pageViewController = storyboard.instantiateViewController(withIdentifier: "LandlordPVC") as? LandlordCreationPageViewController
//        
//        AppearanceController.appearanceFor(textFields: [zipCodeTextField, addressTextField])
//        AppearanceController.appearanceFor(nextButton: nextButton)
//    }
//    
//    @IBAction func nextButtonTapped(_ sender: AnyObject) {
//        guard let pageViewController = pageViewController, let index = pageViewController.orderedViewControllers.index(of: self) else { return }
//        let nextVC = pageViewController.orderedViewControllers[index + 1] as! LandlordPropertyTypeViewController
//        self.pageViewController?.setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
//        
//        
//    }
//    
//    
//    
//}
