//
//  ViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 9/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, RWKSwipeableViewDelegate, MatchingDelegate, FirebaseUserDelegate {
    
    @IBOutlet weak var swipeableView: RWKSwipeableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var rotationAngle: CGFloat = 0.0
    var xFromCenter: CGFloat = 0.0
    var yFromCenter: CGFloat = 0.0
    var velocity: CGPoint = CGPoint.zero
    var previousX: CGFloat = 0.0
    
    var constraints: [NSLayoutConstraint] = []
    
    var count = 0
    
    var users: [TestUser] = [] {
        didSet {
            setupViews()
        }
    }
    
    var originalCenter: CGPoint = CGPoint.zero {
        didSet {
            print(originalCenter)
        }
    }
    
    var imageIndex = 0 {
        didSet {
            print(imageIndex)
        }
    }
    
    var backgroundimageIndex: Int {
        return imageIndex + 1 <= users.count - 1 ? imageIndex + 1 : 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        FirebaseController.delegate = self
        MatchController.delegate = self
        swipeableView.delegate = self
        
        thisIsATerribleFunction()
        
        FirebaseController.getAllFirebaseUsersAndTheirProfilePictures()
        //        view.translatesAutoresizingMaskIntoConstraints = false
        //        constraints = self.view.constraints
    }
    
    func firebaseUsersWereUpdated() {
        self.users = FirebaseController.users
    }
    func currentUserDidMatchWith(IDsOf users: [String]) {
        
        FirebaseController.fetchUsersFor(userIDs: users, completion: { (usersArray) in
            let unwrappedUsersArray = usersArray.flatMap({$0})
            
            let usersString = unwrappedUsersArray.flatMap({$0.name}).joined(separator: ", ")
            
            let message = usersArray.count == 1 ? "\(usersArray.first!) has matched with you!" : "\(usersString) have all matched with you!"
            let title = usersArray.count == 1 ? "You have a new match!" : "You have new matches!"
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            
            alertController.addAction(dismissAction)
            self.present(alertController, animated: true, completion: {
                //
            })
        })
    }
    
    func setupViews() {
        
        //        swipeableView.layer.borderWidth = 0.2
        //        swipeableView.layer.borderColor = UIColor.black.cgColor
        //        swipeableView.backgroundColor = UIColor.lightGray
        guard users.count > 2 else { return }
        imageView.image = users[0].profilePic
        backgroundImageView.image = users[1].profilePic
        imageIndex = 1
        swipeableView.user = users.first!
        imageView.contentMode = .scaleAspectFit
        backgroundImageView.contentMode = .scaleAspectFit
    }
    
    func thisIsATerribleFunction() {
        guard FBSDKAccessToken.current() != nil else { return }
        
        AuthenticationController.attemptToSignInToFirebase {
            
            // TODO: - Please change this function later. Once you have persistence, stop requesting your own information from Facebook each time, and just skip down to like the checkForExisting... or the observeLikesFor.... functions below.
            
            FacebookRequestController.requestCurrentUsers(information: [.name, .email], completion: { (dict) in
                guard let dict = dict, let currentUser = TestUser(dictionary: dict as [String : Any]) else { return }
                FirebaseController.checkForExistingUserInformation(user: currentUser, completion: { (hasAccount, hasPhoto) in
                    FirebaseController.handleUserInformationScenariosFor(user: currentUser, hasAccount: hasAccount, hasPhoto: hasPhoto, completion: {
                        MatchController.observeLikesFor(user: currentUser)
                        // I can't remember why I made this function have a completion closure.
                    })
                })
            })
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: AnyObject) {
        leftAnimationFor(swipeableView: swipeableView, inSuperview: self.view)
    }
    
    @IBAction func checkButtonTapped(_ sender: AnyObject) {
        rightAnimationFor(swipeableView: swipeableView, inSuperview: self.view)
    }
    
    func imageFor(imageView: UIImageView, with imageArray: [TestUser], imageIndex: inout Int) {
        if imageIndex < imageArray.count - 1 {
            imageIndex += 1
        } else {
            imageIndex = 0
        }
        imageView.image = imageArray[imageIndex].profilePic
    }
    
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
        swipeableView.user = users[imageIndex]
        
    }
    
    func degreesToRadians(degree: Double) -> CGFloat {
        return CGFloat(M_PI * (degree) / 180.0)
    }
}

