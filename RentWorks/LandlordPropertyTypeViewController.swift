//
//  LandlordPropertyTypeViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/6/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordPropertyTypeViewController: UIViewController {
    
    @IBOutlet weak var apartmentButton: UIButton!
    @IBOutlet weak var singleFamilyButton: UIButton!
    @IBOutlet weak var condoButton: UIButton!
    @IBOutlet weak var multifamilyButton: UIButton!
    @IBOutlet weak var otherPropertyButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AppearanceController.appearanceFor(selectionButtons: [apartmentButton, singleFamilyButton, condoButton, multifamilyButton, otherPropertyButton])
        AppearanceController.appearanceFor(nextButton: nextButton)
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
