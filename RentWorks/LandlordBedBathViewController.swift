//
//  LandlordBedBathViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/6/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordBedBathViewController: UIViewController {
    
    @IBOutlet weak var bedroomCountTextField: UITextField!
    @IBOutlet weak var bathroomCountTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        AppearanceController.appearanceFor(textFields: [bedroomCountTextField, bathroomCountTextField])
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
