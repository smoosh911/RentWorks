//
//  AccountCreationFacebookLoginViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class AccountCreationFacebookLoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var findLabel: UILabel!
    
    let facebookLoginButton = FBSDKLoginButton()
    
    var loadingView: UIView?
    var loadingActivityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserController.userCreationType == "renter" {
            findLabel.text = "Now find your new home!"
        } else {
            findLabel.text = "Now find your new renter!"
        }
        
        
        if FBSDKAccessToken.current() != nil {
            AuthenticationController.attemptToSignInToFirebase { (success) in
                self.dismissLoadingScreen()
                if UserController.userCreationType == "landlord" {
                    UserController.createLandlordAndPropertyForCurrentUser {
                        print("Successfully created landlord for currentUser")
                    }
                } else if UserController.userCreationType == "renter" {
                    UserController.createRenterForCurrentUser {
                        print("Successfuly created renter for current user.")
                    }
                }
            }
        }
        
        facebookLoginButton.delegate = self
        facebookLoginButton.loginBehavior = .web
        facebookLoginButton.readPermissions = [FacebookRequestController.FacebookPermissions.email.rawValue, FacebookRequestController.FacebookPermissions.user_birthday.rawValue]
        constraintsForFacebookLoginButton()
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        guard result.isCancelled != true else { return }
        setUpAndDisplayLoadingScreen()
        AuthenticationController.attemptToSignInToFirebase { (success) in
            self.dismissLoadingScreen()
            if UserController.userCreationType == "landlord" {
                UserController.createLandlordAndPropertyForCurrentUser {
                    print("Successfully created landlord for currentUser")
                }
            } else if UserController.userCreationType == "renter" {
                UserController.createRenterForCurrentUser {
                    print("Successfuly created renter for current user.")
                }
            }
        }
        
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        dismissLoadingScreen()
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        
        return true
    }
    
    func setUpAndDisplayLoadingScreen() {
        self.loadingView = UIView(frame: self.view.frame)
        self.loadingActivityIndicator = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25, y: self.view.center.y - 25, width: 50, height: 50))
        
        guard let loadingView = self.loadingView, let loadingActivityIndicator = self.loadingActivityIndicator else { return }
        
        loadingView.backgroundColor = UIColor.gray
        loadingView.alpha = 0.3
        loadingActivityIndicator.activityIndicatorViewStyle = .whiteLarge
        
        self.view.addSubview(loadingView)
        self.view.addSubview(loadingActivityIndicator)
        
        let centerXLoadingViewConstraint = NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYLoadingViewConstraint = NSLayoutConstraint(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.view.addConstraints([centerXLoadingViewConstraint, centerYLoadingViewConstraint])
        
        loadingActivityIndicator.startAnimating()
    }
    
    func dismissLoadingScreen() {
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingActivityIndicator?.alpha = 0
            self.loadingActivityIndicator?.stopAnimating()
            self.loadingView?.alpha = 0
        }) { (_) in
            self.loadingActivityIndicator?.removeFromSuperview()
            self.loadingView?.removeFromSuperview()
        }
    }
    
    func constraintsForFacebookLoginButton() {
        facebookLoginButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(facebookLoginButton)
        let centerXConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 40)
        let widthConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .width, relatedBy: .equal, toItem: findLabel, attribute: .width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0, constant: 30)
        self.view.addConstraints([centerXConstraint, centerYConstraint, widthConstraint, heightConstraint])
    }
}
