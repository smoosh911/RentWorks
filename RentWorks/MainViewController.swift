//
//  ViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 9/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, RWKSwipeableViewDelegate {
    
    @IBOutlet weak var swipeableView: RWKSwipeableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var users: [TestUser] = [] {
        didSet {
            if users.count > 16 {
                setupViews()
            }
        }
    }
    
    var count = 0
    var originalCenter: CGPoint = CGPoint.zero {
        didSet {
            print(originalCenter)
        }
    }
    
    var rotationAngle: CGFloat = 0.0
    var xFromCenter: CGFloat = 0.0
    var yFromCenter: CGFloat = 0.0
    var velocity: CGPoint = CGPoint.zero
    var previousX: CGFloat = 0.0
    
    var imageIndex = 0 {
        didSet {
            print(imageIndex)
        }
    }
    
    var backgroundimageIndex: Int {
        return imageIndex + 1 <= users.count - 1 ? imageIndex + 1 : 0
    }
    
    var constraints: [NSLayoutConstraint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        AuthenticationController.checkFirebaseLoginStatus { (loggedIn) in
            if loggedIn == true {
                FirebaseController.fetchAllFirebaseUsers { (users) in
                    guard let users = users else { return }
                    for user in users {
                        FirebaseController.downloadProfileImage(forUser: user, completion: { (image) in
                            guard let image = image else { print("Could not download image"); return }
                            user.profilePic = image
                            self.setupViews()
                        })
                    }
                    self.users = users
                    self.setupViews()
                }
            } else {
                print("Not logged in")
            }
        }
        
        
        
        //        view.translatesAutoresizingMaskIntoConstraints = false
        //        constraints = self.view.constraints
        swipeableView.delegate = self
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
            MatchController.add(currentUser: currentUser, toMatchlistOf: swipeableView.user!)
            
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

