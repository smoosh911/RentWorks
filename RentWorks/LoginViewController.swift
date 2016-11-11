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
    
    @IBOutlet weak var rentingMadeSmartLabel: UILabel!

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
        
        constraintsForFacebookLoginButton()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        guard result.isCancelled != true else { return }

        setUpAndDisplayLoadingScreen()
        if FBSDKAccessToken.current() != nil { print(FBSDKAccessToken.current().expirationDate) }
        FirebaseController.handleUserInformationScenarios { (success) in
            self.dismissLoadingScreen()
            if success {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainVC = storyboard.instantiateViewController(withIdentifier: "cardLoadingVC")
                
                self.present(mainVC, animated: true, completion: nil)
            } else {
                self.displayNoAccountCreatedAlert()
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
    
    func displayNoAccountCreatedAlert() {
        let alert = UIAlertController(title: "Hold on a second!", message: "Thanks for logging into Facebook, but you haven't created an account yet. Please tap the 'Create account' button below to begin creating your RentMatch account!", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        let createAccountAction = UIAlertAction(title: "Create account", style: .default) { (_) in
            self.performSegue(withIdentifier: "toAccountTypeVC", sender: nil)
        }
        
        alert.addAction(dismissAction)
        alert.addAction(createAccountAction)
        
        alert.view.tintColor = .black
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func constraintsForFacebookLoginButton() {
        facebookLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        let centerXConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .top, relatedBy: .equal, toItem: rentingMadeSmartLabel, attribute: .bottom, multiplier: 1, constant: 8)

        self.view.addConstraints([centerXConstraint, yConstraint])
    }
}
