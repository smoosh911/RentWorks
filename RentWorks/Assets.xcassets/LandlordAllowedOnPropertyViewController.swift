//
//  LandlordAllowedOnPropertyViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/6/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordAllowedOnPropertyViewController: UIViewController {

    @IBOutlet weak var petsButton: UIButton!
    @IBOutlet weak var smokingButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppearanceController.appearanceFor(selectionButtons: [petsButton, smokingButton])
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
