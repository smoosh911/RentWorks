//
//  ViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 9/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UserMatchingDelegate, FirebaseUserDelegate {
    
    @IBOutlet weak var swipeableView: RWKSwipeableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundNameLabel: UILabel!
    @IBOutlet weak var backgroundAddressLabel: UILabel!
    
    var rotationAngle: CGFloat = 0.0
    var xFromCenter: CGFloat = 0.0
    var yFromCenter: CGFloat = 0.0
    var velocity: CGPoint = CGPoint.zero
    var previousX: CGFloat = 0.0
    var originalCenter: CGPoint = CGPoint.zero
    
    var constraints: [NSLayoutConstraint] = []
    
    var loadingView: UIView?
    var loadingActivityIndicator: UIActivityIndicatorView?
    
    
    var imageIndex = 0
    
    var users: [TestUser] = [] {
        didSet {
            setupViews()
        }
    }
    
    var backgroundimageIndex: Int {
        return imageIndex + 1 <= users.count - 1 ? imageIndex + 1 : 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpAndDisplayLoadingScreen()
        
        FirebaseController.delegate = self
        MatchController.delegate = self
        swipeableView.delegate = self
        
        thisIsATerribleFunction()
        
        FirebaseController.getAllFirebaseUsersAndTheirProfilePictures()
    }
    
    
    // FirebaseUserDelegate
    
    func firebaseUsersWereUpdated() {
        self.users = FirebaseController.users
        dismissLoadingScreen()
    }
    
    // UserMatchingDelegate
    
    func currentUserDidMatchWith(IDsOf users: [String]) {
        
        FirebaseController.fetchUsersFor(userIDs: users, completion: { (usersArray) in
            let unwrappedUsersArray = usersArray.flatMap({$0})
            
            let usersString = unwrappedUsersArray.flatMap({$0.name}).joined(separator: ", ")
            
            let message = usersArray.count == 1 ? "\(usersArray.first!) has matched with you!" : "\(usersString) have all matched with you!"
            let title = usersArray.count == 1 ? "You have a new match!" : "You have new matches!"
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            
            alertController.addAction(dismissAction)
//            self.present(alertController, animated: true, completion: {
            
//            })
        })
    }
   
    func thisIsATerribleFunction() {
        guard FBSDKAccessToken.current() != nil else { return }
        
        AuthenticationController.attemptToSignInToFirebase {
            
            // TODO: - Please change this function later. Once you have persistence, stop requesting your own information from Facebook each time, and just skip down to like the checkForExisting... or the observeLikesFor.... functions below.
            
            FacebookRequestController.requestCurrentUsers(information: [.name, .email], completion: { (dict) in
                guard let dict = dict, let currentUser = TestUser(facebookDictionary: dict as [String : Any]) else { return }
                FirebaseController.checkForExistingUserInformation(user: currentUser, completion: { (hasAccount, hasPhoto) in
                    FirebaseController.handleUserInformationScenariosFor(user: currentUser, hasAccount: hasAccount, hasPhoto: hasPhoto, completion: {
                        MatchController.observeLikesFor(user: currentUser)
                        // I can't remember why I made this function have a completion closure.
                    })
                })
            })
        }
    }
    
    
    // UI Related
    
    func updateLabelsWith(user: TestUser) {
        nameLabel.text = user.name
        addressLabel.text = user.address
        
        let nextUser = users[backgroundimageIndex]
        backgroundNameLabel.text = nextUser.name
        backgroundAddressLabel.text = nextUser.address
    }
    
    func imageFor(imageView: UIImageView, with imageArray: [TestUser], imageIndex: inout Int) {
        if imageIndex < imageArray.count - 1 {
            imageIndex += 1
        } else {
            imageIndex = 0
        }
        imageView.image = imageArray[imageIndex].profilePic
    }
    
    func setupViews() {
        
        guard users.count > 2 else { return }
        let user = users[imageIndex]
        imageView.image = user.profilePic
        backgroundImageView.image = users[backgroundimageIndex].profilePic
        swipeableView.user = user
        updateLabelsWith(user: user)
    }
    
    func setUpAndDisplayLoadingScreen() {
        self.loadingView = UIView(frame: self.view.frame)
        self.loadingActivityIndicator = UIActivityIndicatorView(frame: CGRect(x: self.view.center.x, y: self.view.center.y, width: 50, height: 50))
        
        guard let loadingView = self.loadingView, let loadingActivityIndicator = loadingActivityIndicator else { return }
        loadingView.backgroundColor = UIColor(red: 0.961, green: 0.482, blue: 0.220, alpha: 1.00)
        loadingActivityIndicator.activityIndicatorViewStyle = .whiteLarge
        
        
        loadingView.addSubview(loadingActivityIndicator)
        self.view.addSubview(loadingView)
        
        self.view.bringSubview(toFront: loadingView)
        loadingView.bringSubview(toFront: loadingActivityIndicator)
        
        
        let centerXLoadingViewConstraint = NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYLoadingViewConstraint = NSLayoutConstraint(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        let centerXIndicatorConstraint = NSLayoutConstraint(item: loadingActivityIndicator, attribute: .centerX, relatedBy: .equal, toItem: loadingView, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYIndicatorConstraint = NSLayoutConstraint(item: loadingActivityIndicator, attribute: .centerY, relatedBy: .equal, toItem: loadingView, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.view.addConstraints([centerXLoadingViewConstraint, centerYLoadingViewConstraint])
        loadingView.addConstraints([centerXIndicatorConstraint, centerYIndicatorConstraint])
        
        loadingActivityIndicator.startAnimating()
    }
    
    func dismissLoadingScreen() {
        UIView.animate(withDuration: 0.8, animations: {
            self.loadingActivityIndicator?.alpha = 0
            self.loadingView?.alpha = 0
        }) { (_) in
            self.loadingActivityIndicator?.removeFromSuperview()
            self.loadingView?.removeFromSuperview()
        }
    }
    
    
}

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
        let finishPoint = CGPoint(x: CGFloat(700), y: superview.center.y - 100)
        UIView.animate(withDuration: 0.7, animations: {
            swipeableView.center = finishPoint
            swipeableView.transform = CGAffineTransform(rotationAngle: self.degreesToRadians(degree: 90))
        }) { (complete) in
            
            self.reset(swipeableView: swipeableView, inSuperview: superview)
            self.imageFor(imageView: self.imageView, with: self.users, imageIndex: &self.imageIndex)
            self.backgroundImageView.image = self.users[self.backgroundimageIndex].profilePic
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
            self.imageFor(imageView: self.imageView, with: self.users, imageIndex: &self.imageIndex)
            self.backgroundImageView.image = self.users[self.backgroundimageIndex].profilePic
        }
    }
    
    
    func put(swipeableView: UIView, inCenterOf superview: UIView) {
        UIView.animate(withDuration: 0.3) {
            swipeableView.center = self.view.center
            swipeableView.transform = CGAffineTransform(rotationAngle: 0.0)
        }
    }
    
    
    func reset(swipeableView: UIView, inSuperview: UIView) {
        let constraints = inSuperview.constraints
        swipeableView.removeFromSuperview()
        inSuperview.addSubview(swipeableView)
        inSuperview.addConstraints(constraints)
        
        swipeableView.transform = CGAffineTransform(rotationAngle: 0.0)
        guard let swipeableView = swipeableView as? RWKSwipeableView else { return }
        let newUser = users[imageIndex]
        swipeableView.user = newUser
        updateLabelsWith(user: newUser)
    }
    
    func degreesToRadians(degree: Double) -> CGFloat {
        return CGFloat(M_PI * (degree) / 180.0)
    }
    
}
