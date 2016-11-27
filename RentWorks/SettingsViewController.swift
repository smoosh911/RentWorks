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

    // MARK: outlets
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgviewProfilePic: UIImageView!
    
    // MARK: variables
    
    let manager = FBSDKLoginManager()
    static var settingsDidChange = false
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        NotificationCenter.default.addObserver(self, selector: #selector(updateSettingsChanged), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(manager)
    }
    
    // MARK: actions
    // needs work: there should be a global function that clears global data upon sign outs
    @IBAction func signOutButtonTapped(_ sender: Any) {
        manager.logOut()
        for renter in MatchController.matchedRentersForProperties {
            UserDefaults.standard.set(0, forKey: "\(Identifiers.UserDefaults.propertyMatchCount.rawValue)/\(renter.key)")
        }
        UserDefaults.standard.set(0, forKey: Identifiers.UserDefaults.renterMatchCount.rawValue)
        MatchController.isObservingCurrentUserLikeEndpoint = false
        MatchController.matchedProperties = []
        MatchController.matchedRentersForProperties = [:]
        UserController.propertyFetchCount = 0
        UserController.renterFetchCount = 0
        
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC")
        self.present(loginVC, animated: true, completion: nil)
    }
    
    @IBAction func goBackButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: helper functions
    
//    @objc private func updateSettingsChanged() {
//        SettingsViewController.settingsDidChange = true
//    }
}
