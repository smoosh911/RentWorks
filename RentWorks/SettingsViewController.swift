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

    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgviewProfilePic: UIImageView!
    
    let manager = FBSDKLoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserController.currentUserType == "renter" {
            guard let profileImages = UserController.currentRenter!.profileImages?.array as? [ProfileImage] else { return }
            
            lblUserName.text = "\(UserController.currentRenter!.firstName!) \(UserController.currentRenter!.lastName!)"
            imgviewProfilePic.image = UIImage(data: profileImages[0].imageData as! Data)
        } else {
            lblUserName.text = "\(UserController.currentLandlord!.firstName!) \(UserController.currentLandlord!.lastName!)"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(manager)
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
