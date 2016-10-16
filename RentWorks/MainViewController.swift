//
//  ViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 9/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UserMatchingDelegate, FirebaseUserDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var swipeableView: RWKSwipeableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundNameLabel: UILabel!
    @IBOutlet weak var backgroundAddressLabel: UILabel!
    @IBOutlet weak var navigationBarView: UIView!
    
    var rotationAngle: CGFloat = 0.0
    var xFromCenter: CGFloat = 0.0
    var yFromCenter: CGFloat = 0.0
    var velocity: CGPoint = CGPoint.zero
    var previousX: CGFloat = 0.0
    var originalCenter: CGPoint = CGPoint.zero
    
    var constraints: [NSLayoutConstraint] = []
    
    var loadingView: UIView?
    var loadingActivityIndicator: UIActivityIndicatorView?
    var loadingViewHasBeenDismissed = false {
        didSet {
            print("Did set boolean to true")
        }
    }
    
    var matchingUsersAlertController: UIAlertController?
    
    @IBOutlet weak var loadingLabel: UILabel!
    
    var imageIndex = 0
    var backgroundimageIndex: Int {
        return imageIndex + 1 <= users.count - 1 ? imageIndex + 1 : 0
    }
    var users: [TestUser] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpAndDisplayLoadingScreen()
        //        AppearanceController.appearanceFor(navigationController: self.navigationController)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        FirebaseController.delegate = self
        MatchController.delegate = self
        swipeableView.delegate = self
        
        swipeableView.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 15
        //        swipeableView.layer.masksToBounds = true
        
        backgroundImageView.layer.cornerRadius = 15
        backgroundView.layer.cornerRadius = 15
        //        backgroundView.layer.masksToBounds = true
        
        if AuthenticationController.currentUser == nil {
            AuthenticationController.getCurrentUser()
        }
        
        FirebaseController.getAllFirebaseUsersAndTheirProfilePictures()
    }
    
    
    // MARK: - FirebaseUserDelegate
    
    func firebaseUsersWereUpdated() {
        self.users = FirebaseController.users.reversed()
        dismissLoadingScreen()
    }
    
    // MARK: - UserMatchingDelegate
    
    func currentUserDidMatchWith(IDsOf users: [String]) {
        presentMatchAlertController(for: users)
    }
    
    func presentMatchAlertController(for userIDs: [String]?) {
        if loadingViewHasBeenDismissed == true {
            if let matchingUsersAlertController = self.matchingUsersAlertController {
                present(matchingUsersAlertController, animated: true, completion: nil)
            } else {
                guard let userIDs = userIDs else { return }
                FirebaseController.fetchUsersFor(userIDs: userIDs, completion: { (usersArray) in
                    guard usersArray.count > 0 else { return }
                    
                    let unwrappedUsersArray = usersArray.flatMap({$0})
                    
                    // WARNING: - This will change once the list of all users who have historically matched get a separate endpoint in Firebase.
                    MatchController.allMatches = unwrappedUsersArray
                    
                    let usersString = unwrappedUsersArray.flatMap({$0.name}).joined(separator: ", ")
                    
                    let message = unwrappedUsersArray.count == 1 ? "\(unwrappedUsersArray[0].name) has matched with you!" : "\(usersString) have all matched with you!"
                    let title = unwrappedUsersArray.count == 1 ? "You have a new match!" : "You have new matches!"
                    
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                    let showMatchVCAction = UIAlertAction(title: "Take me to my matches", style: .default, handler: { (_) in
                        self.performSegue(withIdentifier: "toMatchesVC", sender: self)
                    })
                    
                    alertController.addAction(dismissAction)
                    alertController.addAction(showMatchVCAction)
                    
                    alertController.view.tintColor = AppearanceController.customOrangeColor
                    
                    self.matchingUsersAlertController = alertController
                    FirebaseController.downloadAndAddProfileImages(forUsers: unwrappedUsersArray, completion: nil)
                    
                    self.present(alertController, animated: true, completion: nil)
                    print("Did present matchAlert")
                })
            }
        } else {
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (_) in
                self.presentMatchAlertController(for: userIDs)
            })
        }
    }
    
    
    // MARK: - UI Related
    
    func updateUIElements() {
        let user = users[imageIndex]
        imageView.image = user.profilePic
        nameLabel.text = user.name
        addressLabel.text = user.address
        
        swipeableView.user = user
        
        let nextUser = users[backgroundimageIndex]
        backgroundImageView.image = nextUser.profilePic
        backgroundNameLabel.text = nextUser.name
        backgroundAddressLabel.text = nextUser.address
        
        if imageIndex < users.count - 1 {
            imageIndex += 1
        } else {
            imageIndex = 0
        }
    }
    
    func setUpAndDisplayLoadingScreen() {
        self.loadingView = UIView(frame: self.view.frame)
        self.loadingActivityIndicator = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x - 25, y: self.view.center.y - 25, width: 50, height: 50))
        
        guard let loadingView = self.loadingView, let loadingActivityIndicator = loadingActivityIndicator, let loadingLabel = self.loadingLabel else { return }
        loadingLabel.isHidden = false
        loadingView.backgroundColor = AppearanceController.customOrangeColor
        loadingActivityIndicator.activityIndicatorViewStyle = .whiteLarge
        
        loadingView.addSubview(loadingActivityIndicator)
        loadingView.addSubview(loadingLabel)
        self.view.addSubview(loadingView)
        
        
        
        let centerXLoadingViewConstraint = NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYLoadingViewConstraint = NSLayoutConstraint(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        let centerXLoadingLabelConstraint = NSLayoutConstraint(item: loadingLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let bottomLoadingLabelConstraint = NSLayoutConstraint(item: loadingLabel, attribute: .bottom, relatedBy: .equal, toItem: self.loadingActivityIndicator, attribute: .top, multiplier: 1, constant: -25)
        
        self.view.addConstraints([centerXLoadingViewConstraint, centerYLoadingViewConstraint, centerXLoadingLabelConstraint,
                                  bottomLoadingLabelConstraint])
        
        loadingActivityIndicator.startAnimating()
    }
    
    func dismissLoadingScreen() {
        UIView.animate(withDuration: 0.8, animations: {
            self.loadingActivityIndicator?.alpha = 0
            self.loadingView?.alpha = 0
            self.loadingLabel.alpha = 0
        }) { (_) in
            self.loadingActivityIndicator?.removeFromSuperview()
            self.loadingView?.removeFromSuperview()
            self.loadingLabel.removeFromSuperview()
            self.loadingViewHasBeenDismissed = true
        }
    }
}

// MARK: - RWKSwipeableViewDelegate

extension MainViewController: RWKSwipeableViewDelegate {
    
    func swipeAnimationsFor(swipeableView: UIView, inSuperview superview: UIView) {
        if swipeableView.center.x > superview.center.x + 45 {
            rightAnimationFor(swipeableView: swipeableView, inSuperview: superview)
        } else if swipeableView.center.x < superview.center.x - 45 {
            leftAnimationFor(swipeableView: swipeableView, inSuperview: superview)
        } else {
            put(swipeableView: swipeableView, inCenterOf: superview)
            reset(swipeableView: swipeableView, inSuperview: superview)
        }
    }
    
    func rightAnimationFor(swipeableView: UIView, inSuperview superview: UIView) {
        let finishPoint = CGPoint(x: CGFloat(750), y: superview.center.y - 100)
        UIView.animate(withDuration: 0.7, animations: {
            swipeableView.center = finishPoint
            swipeableView.transform = CGAffineTransform(rotationAngle: self.degreesToRadians(degree: 90))
        }) { (complete) in
            
            self.reset(swipeableView: swipeableView, inSuperview: superview)
            self.updateUIElements()
            
            guard let swipeableView = swipeableView as? RWKSwipeableView, let currentUser = AuthenticationController.currentUser else { return }
            MatchController.add(currentUser: currentUser, toLikelistOf: swipeableView.user!)
        }
    }
    
    func leftAnimationFor(swipeableView: UIView, inSuperview superview: UIView) {
        let finishPoint = CGPoint(x: CGFloat(-700), y: superview.center.y - 100)
        UIView.animate(withDuration: 0.7, animations: {
            swipeableView.center = finishPoint
            
            swipeableView.transform = CGAffineTransform(rotationAngle: self.degreesToRadians(degree: -90))
        }) { (complete) in
            self.reset(swipeableView: swipeableView, inSuperview: superview)
            self.updateUIElements()
        }
    }
    
    
    func put(swipeableView: UIView, inCenterOf superview: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            swipeableView.center = self.view.center
            swipeableView.transform = CGAffineTransform(rotationAngle: 0.0)
        })
    }
    
    
    func reset(swipeableView: UIView, inSuperview: UIView) {
        let constraints = inSuperview.constraints
        swipeableView.removeFromSuperview()
        inSuperview.addSubview(swipeableView)
        inSuperview.addConstraints(constraints)
        self.view.bringSubview(toFront: self.navigationBarView)
        swipeableView.transform = CGAffineTransform(rotationAngle: 0.0)
        
        guard let swipeableView = swipeableView as? RWKSwipeableView else { return }
        let newUser = users[imageIndex]
        swipeableView.user = newUser
        
    }
    
    func degreesToRadians(degree: Double) -> CGFloat {
        return CGFloat(M_PI * (degree) / 180.0)
    }
    
}
