//
//  LoginViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/3/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rentMatchLabel: UILabel!
    
    let facebookLoginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookLoginButton.delegate = self
        facebookLoginButton.loginBehavior = .web
        facebookLoginButton.readPermissions = ["email"]
        
        self.view.addSubview(facebookLoginButton)
        
        AppearanceController.appearanceFor(navigationController: self.navigationController)

        constraintsForFacebookLoginButton()
    }
    
    
    // TODO: - Run a check to see if the user has already created a RW account with Facebook. (Using the FBSDKAccessToken.current().userID)
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        AuthenticationController.getCurrentUser { (success) in
            if success {
                guard let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainVC") as? UINavigationController else { return }
                
                self.present(mainVC, animated: true, completion: nil)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        
        return true
    }
    
    func constraintsForFacebookLoginButton() {
        facebookLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        let centerXConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
//        let widthConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .width, relatedBy: .equal, toItem: self.passwordTextField, attribute: .width, multiplier: 1, constant: 0)
//        let heightConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0, constant: 30)
        self.view.addConstraints([centerXConstraint, centerYConstraint])
    }
}
