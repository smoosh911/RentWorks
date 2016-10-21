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
    
    @IBOutlet weak var rentMatchLabel: UILabel!
    
    var loadingView: UIView?
    var loadingActivityIndicator: UIActivityIndicatorView?
    
    let facebookLoginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookLoginButton.delegate = self
        facebookLoginButton.loginBehavior = .web
        facebookLoginButton.readPermissions = [FacebookRequestController.FacebookPermissions.email.rawValue, FacebookRequestController.FacebookPermissions.user_birthday.rawValue]
        
        self.view.addSubview(facebookLoginButton)
        
        AppearanceController.appearanceFor(navigationController: self.navigationController)
        self.navigationController?.navigationController?.navigationBar.barTintColor = UIColor.white

        constraintsForFacebookLoginButton()
    }
    
    
    // TODO: - Run a check to see if the user has already created a RW account with Facebook. (Using the FBSDKAccessToken.current().userID)
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        setUpAndDisplayLoadingScreen()
//        AuthenticationController.getCurrentUser { (success) in
//            if success == true {
//                guard let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainVC") else { return }
//                self.dismissLoadingScreen()
//                self.present(mainVC, animated: true, completion: nil)
//            } else {
//                self.dismissLoadingScreen()
//            }
//        }
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
        
        let centerXConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
//        let widthConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .width, relatedBy: .equal, toItem: self.passwordTextField, attribute: .width, multiplier: 1, constant: 0)
//        let heightConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0, constant: 30)
        self.view.addConstraints([centerXConstraint, centerYConstraint])
    }
}
