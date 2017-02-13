//
//  LoginViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/3/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    // MARK: outlets
    
    @IBOutlet weak var btnRenter: UIButton!
    @IBOutlet weak var btnLandlord: UIButton!

    // MARK: variables
    
    var loadingView: UIView?
    var loadingActivityIndicator: UIActivityIndicatorView?
    
    let facebookLoginButton = FBSDKLoginButton()
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnRenter.layer.cornerRadius = 10
        btnLandlord.layer.cornerRadius = 10
        
        facebookLoginButton.delegate = self
        facebookLoginButton.loginBehavior = .web
        facebookLoginButton.readPermissions = [FacebookRequestController.FacebookPermissions.email.rawValue, FacebookRequestController.FacebookPermissions.user_birthday.rawValue, FacebookRequestController.FacebookPermissions.user_work_history_permission.rawValue]
        
        self.view.addSubview(facebookLoginButton)
        
        AppearanceController.appearanceFor(navigationController: self.navigationController)
        
        constraintsForFacebookLoginButton()
    }
    
    // MARK: actions
    
    @IBAction func btnRenterOrLandlord_TouchedUpInside(_ sender: UIButton) {
        guard let buttonLabel = sender.titleLabel, let buttonText = buttonLabel.text else {
            return
        }
        self.performCorrectSegue(buttonText: buttonText)
    }
    
    // MARK: segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Identifiers.Segues.renterMainVC.rawValue {
            UserController.userCreationType = "renter"
            UserController.currentUserType = "renter"
            UserController.currentRenter = Renter(isEmpty: true)
        } else if segue.identifier == Identifiers.Segues.landlordMainVC.rawValue {
            UserController.userCreationType = "landlord"
            UserController.currentUserType = "landlord"
        }
    }
    
    // MARK: helper functions
    
    private func performCorrectSegue(buttonText: String) {
        if buttonText == "Renter" {
            performSegue(withIdentifier: Identifiers.Segues.renterMainVC.rawValue, sender: self)
        } else {
            
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        var validBirthday = false // Make sure user has birthday on facebook and they are older than 18
        
        guard result.isCancelled != true else { return }
        
        setUpAndDisplayLoadingScreen()
        
        FacebookRequestController.requestCurrentUsers(information: [.age_range], completion: { (facebookDictionary) in
            
            if facebookDictionary == nil {
                self.displayInvalidBirthdayAlert()
                let manager = FBSDKLoginManager()
                manager.logOut()
                self.dismissLoadingScreen()
            } else {
                let ageRange = facebookDictionary!["age_range"]! as! [String: Any]
                if let max = ageRange["max"] as? Int {
                    if max < 18 {
                        self.displayInvalidBirthdayAlert()
                        let manager = FBSDKLoginManager()
                        manager.logOut()
                        self.dismissLoadingScreen()
                    } else {
                        validBirthday = true
                    }
                } else if let min = ageRange["min"] as? Int {
                    if min < 18 {
                        self.displayInvalidBirthdayAlert()
                        let manager = FBSDKLoginManager()
                        manager.logOut()
                        self.dismissLoadingScreen()
                    } else {
                        validBirthday = true
                    }
                }
            }
            if validBirthday {
                if FBSDKAccessToken.current() != nil { print(FBSDKAccessToken.current().expirationDate) }
                FirebaseController.handleUserInformationScenarios(inViewController: self, completion: { (success) in
                    self.dismissLoadingScreen()
                    let storyboard: UIStoryboard!
                    let mainVC: UIViewController!
                    if success {
                        if UserController.userCreationType == "landlord" {
                            storyboard = UIStoryboard(name: "LandlordMain", bundle: nil)
                            mainVC = storyboard.instantiateViewController(withIdentifier: "cardLoadingVC")
                        } else {
                            storyboard = UIStoryboard(name: "RenterMain", bundle: nil)
                            mainVC = storyboard.instantiateViewController(withIdentifier: "mainVC")
                        }
                        
                        self.present(mainVC, animated: true, completion: nil)
                    } else {
                        self.displayNoAccountCreatedAlert()
                    }
                })
            }
        })
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
    
    // MARK: alerts
    
    func displayNoAccountCreatedAlert() {
        let alert = UIAlertController(title: "Hold on a second!", message: "Thanks for logging into Facebook, but you haven't created an account yet. Please tap the 'Create account' button below to begin creating your Venga account!", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        let createLandlordAccount = UIAlertAction(title: "Create Landlord", style: .default) { (_) in
            LandlordController.createLandlordAndPropertyForCurrentUser {
                self.dismissLoadingScreen()
                self.performSegue(withIdentifier: Identifiers.Segues.landlordMainVC.rawValue, sender: self)
            }
        }
        
        let createRenterAccount = UIAlertAction(title: "Create Renter", style: .default) { (_) in
            RenterController.createRenterForCurrentUser {
                self.dismissLoadingScreen()
                self.performSegue(withIdentifier: Identifiers.Segues.renterMainVC.rawValue, sender: self)
            }
        }
        
        alert.addAction(dismissAction)
        alert.addAction(createRenterAccount)
        alert.addAction(createLandlordAccount)
        
        alert.view.tintColor = .black
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayInvalidBirthdayAlert() {
        let alert = UIAlertController(title: "Must be 18 or older", message: "You either don't have your age posted on facebook or you are under 18. We need you to be at least 18 to talk to landlords or potential renters", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alert.addAction(dismissAction)
        
        alert.view.tintColor = .black
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func constraintsForFacebookLoginButton() {
        facebookLoginButton.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .width, relatedBy: .equal, toItem: btnRenter, attribute: .width, multiplier: 1, constant: 0)

        let heightConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .height, relatedBy: .equal, toItem: btnRenter, attribute: .height, multiplier: 3/5, constant: 0)
        
        let centerXConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .bottom, relatedBy: .equal, toItem: btnRenter, attribute: .top, multiplier: 1, constant: -20)
        
        self.view.addConstraints([widthConstraint, heightConstraint, centerXConstraint, yConstraint])
    }

}
