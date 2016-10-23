//
//  LandlordPropertyAvailableDateViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordPropertyAvailableDateViewController: UIViewController {
    
    @IBOutlet weak var availableDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        availableDatePicker.minimumDate = Date()
        availableDatePicker.setValue(UIColor.white, forKey: "textColor")
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        UserController.addAttributeToUserDictionary(attribute: [UserController.kAvailableDate: availableDatePicker.date.timeIntervalSince1970])
    }
    
    
}
