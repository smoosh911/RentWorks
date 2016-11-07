//
//  SettingsViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/23/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SettingsViewController: UIViewController {

    
    let manager = FBSDKLoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        manager.logOut()
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC")
        self.present(loginVC, animated: true, completion: nil)
    }
    
    
    @IBAction func goBackButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}
