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
    
    let facebookLoginButton = FBSDKLoginButton()
    let loginManager = FBSDKLoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookLoginButton.delegate = self
        facebookLoginButton.loginBehavior = .web
        facebookLoginButton.readPermissions = ["email"]
        
        self.view.addSubview(facebookLoginButton)
        
        constraintsForFacebookLoginButton()
        //        AuthenticationController.attemptToSignInToFirebase {
        //            self.initialRequest(completion: { (dict) in
        //                guard let user = TestUser(dictionary: dict) else { return }
        //                MatchController.observeLikesFor(user: user)
        //            })
    }
    
    
    // TODO: - Run a check to see if the user has already created a RW account with Facebook. (Using the FBSDKAccessToken.current().userID)
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        AuthenticationController.attemptToSignInToFirebase { (success) in
            if success {
                FacebookRequestController.requestCurrentUsers(information: [.name, .email], completion: { (dict) in
                    guard let dict = dict, let currentUser = TestUser(facebookDictionary: dict as [String : Any]) else { return }
                    
                    FirebaseController.checkForExistingUserInformation(user: currentUser, completion: { (hasAccount, hasPhoto) in
                        FirebaseController.handleUserInformationScenariosFor(user: currentUser, hasAccount: hasAccount, hasPhoto: hasPhoto, completion: {
                            // Do stuff like segue to the next VC?
                        })
                    })
                })
            } else {
                
                print("Unsuccessful log in.")
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
        let topConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .top, relatedBy: .equal, toItem: passwordTextField, attribute: .bottom, multiplier: 1, constant: 8)
        let widthConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .width, relatedBy: .equal, toItem: self.passwordTextField, attribute: .width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0, constant: 30)
        self.view.addConstraints([centerXConstraint, widthConstraint, topConstraint, heightConstraint])
    }
}
