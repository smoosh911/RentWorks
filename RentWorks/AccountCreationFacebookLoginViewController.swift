//
//  AccountCreationFacebookLoginViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class AccountCreationFacebookLoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var findLabel: UILabel!
    @IBOutlet weak var lblLoading: UILabel!
    
    let facebookLoginButton = FBSDKLoginButton()
    
    var loadingView: UIView?
    var loadingActivityIndicator: UIActivityIndicatorView?
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserController.userCreationType == "renter" {
            findLabel.text = "Now find your new home!"
        } else {
            findLabel.text = "Now find your new renter!"
        }
        
        addAccountCreationObservers()
        
        facebookLoginButton.delegate = self
        facebookLoginButton.loginBehavior = .web
        facebookLoginButton.readPermissions = [FacebookRequestController.FacebookPermissions.email.rawValue, FacebookRequestController.FacebookPermissions.user_birthday.rawValue, FacebookRequestController.FacebookPermissions.user_work_history_permission.rawValue]
        constraintsForFacebookLoginButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if FBSDKAccessToken.current() != nil {
            setUpAndDisplayLoadingScreen()
            AuthenticationController.attemptToSignInToFirebase { (success) in
                
                FirebaseController.handleUserInformationScenarios(inViewController: self, completion: { (hasAccount) in
                    if !hasAccount {
                        if UserController.userCreationType == "landlord" {
                            LandlordController.createLandlordAndPropertyForCurrentUser {
                                self.dismissLoadingScreen()
                                let storyboard = UIStoryboard(name: "LandlordMain", bundle: nil)
                                let mainVC = storyboard.instantiateViewController(withIdentifier: "cardLoadingVC")
                                self.present(mainVC, animated: true, completion: nil)
                                print("Successfully created landlord for currentUser")
                            }
                        } else if UserController.userCreationType == "renter" {
                            RenterController.createRenterForCurrentUser {
                                self.dismissLoadingScreen()
                                let storyboard = UIStoryboard(name: "RenterMain", bundle: nil)
                                let mainVC = storyboard.instantiateViewController(withIdentifier: "cardLoadingVC")
                                self.present(mainVC, animated: true, completion: nil)
                                print("Successfuly created renter for current user.")
                            }
                        }
                    } else {
                        self.dismissLoadingScreen()
                        
                        let alert = UIAlertController(title: "Hey there", message: "Looks like you've already got an account attached to this Facebook account. If you want to log in, tap the 'Log in' button below.", preferredStyle: .alert)
                        
                        var loginAction: UIAlertAction!
                        if UserController.userCreationType == "landlord" {
                            let storyboard = UIStoryboard(name: "LandlordMain", bundle: nil)
                            loginAction = UIAlertAction(title: "Log in", style: .default, handler: { (_) in
                                let mainVC = storyboard.instantiateViewController(withIdentifier: "cardLoadingVC")
                                self.present(mainVC, animated: true, completion: nil)
                            })
                        } else {
                            let storyboard = UIStoryboard(name: "RenterMain", bundle: nil)
                            loginAction = UIAlertAction(title: "Log in", style: .default, handler: { (_) in
                                let mainVC = storyboard.instantiateViewController(withIdentifier: "cardLoadingVC")
                                self.present(mainVC, animated: true, completion: nil)
                            })
                        }
                        
                        if loginAction == nil {
                            log("ERROR: loginAction nil")
                            return
                        }
                        
                        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        alert.addAction(loginAction)
                        alert.addAction(dismissAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: helper functions
    
    private func addAccountCreationObservers() {
        for observer in Identifiers.CreatingUserNotificationObserver.allValues {
            NotificationCenter.default.addObserver(self, selector: #selector(changeLoadingLabel), name: Notification.Name(observer.rawValue), object: nil)
        }
    }
    
    @objc private func changeLoadingLabel(notification: NSNotification) {
        lblLoading.text = notification.name.rawValue
        switch notification.name.rawValue {
        case Identifiers.CreatingUserNotificationObserver.creatingLandlord.rawValue:
            break
        case Identifiers.CreatingUserNotificationObserver.finishedCreatingLandlord.rawValue:
            break
        case Identifiers.CreatingUserNotificationObserver.creatingProperty.rawValue:
            break
        case Identifiers.CreatingUserNotificationObserver.finishedCreatingProperty.rawValue:
            break
        case Identifiers.CreatingUserNotificationObserver.creatingRenter.rawValue:
            break
        case Identifiers.CreatingUserNotificationObserver.finishedCreatingRenter.rawValue:
            break
        case Identifiers.CreatingUserNotificationObserver.imageUploading.rawValue:
            break
        case Identifiers.CreatingUserNotificationObserver.imageFinishedUploading.rawValue:
            break
        default:
            break
        }
        print(notification)
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        guard result.isCancelled != true else { return }
        setUpAndDisplayLoadingScreen()
        if FBSDKAccessToken.current() != nil {
            AuthenticationController.attemptToSignInToFirebase { (success) in
                FirebaseController.handleUserInformationScenarios(inViewController: self, completion: { (hasAccount) in
                    if !hasAccount {
                        if UserController.userCreationType == "landlord" {
                            LandlordController.createLandlordAndPropertyForCurrentUser {
                                let storyboard = UIStoryboard(name: "LandlordMain", bundle: nil)
                                self.dismissLoadingScreen()
                                let mainVC = storyboard.instantiateViewController(withIdentifier: "cardLoadingVC")
                                self.present(mainVC, animated: true, completion: nil)
                                print("Successfully created landlord for currentUser")
                            }
                        } else if UserController.userCreationType == "renter" {
                            RenterController.createRenterForCurrentUser {
                                let storyboard = UIStoryboard(name: "RenterMain", bundle: nil)
                                self.dismissLoadingScreen()
                                let mainVC = storyboard.instantiateViewController(withIdentifier: "cardLoadingVC")
                                self.present(mainVC, animated: true, completion: nil)
                                print("Successfuly created renter for current user.")
                            }
                        }
                    } else {
                        self.dismissLoadingScreen()
                        
                        let alert = UIAlertController(title: "Hey there", message: "Looks like you've already got an account attached to this Facebook account. If you want to log in, tap the 'Log in' button below.", preferredStyle: .alert)
                        
                        alert.view.tintColor = .black
                        
                        var loginAction: UIAlertAction!
                        if UserController.userCreationType == "landlord" {
                            let storyboard = UIStoryboard(name: "LandlordMain", bundle: nil)
                            loginAction = UIAlertAction(title: "Log in", style: .default, handler: { (_) in
                                let mainVC = storyboard.instantiateViewController(withIdentifier: "cardLoadingVC")
                                self.present(mainVC, animated: true, completion: nil)
                            })
                        } else {
                            let storyboard = UIStoryboard(name: "RenterMain", bundle: nil)
                            loginAction = UIAlertAction(title: "Log in", style: .default, handler: { (_) in
                                let mainVC = storyboard.instantiateViewController(withIdentifier: "cardLoadingVC")
                                self.present(mainVC, animated: true, completion: nil)
                            })
                        }
                        
                        if loginAction == nil {
                            log("ERROR: loginAction nil")
                            return
                        }
                        
                        let dismissAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        
                        alert.addAction(loginAction)
                        alert.addAction(dismissAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
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
        let topToLabelBottomConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .top, relatedBy: .equal, toItem: findLabel, attribute: .bottom, multiplier: 1, constant: 12)
        let widthConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .width, relatedBy: .equal, toItem: findLabel, attribute: .width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: facebookLoginButton, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0, constant: 40)
        self.view.addConstraints([centerXConstraint, topToLabelBottomConstraint, widthConstraint, heightConstraint])
    }
}
