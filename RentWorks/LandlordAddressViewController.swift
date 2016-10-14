//
//  LandlordAddressViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/6/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordAddressViewController: UIViewController {
    
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationController?.navigationBar.barTintColor = UIColor.white
        AppearanceController.appearanceFor(textFields: [zipCodeTextField, addressTextField])
    }
}
