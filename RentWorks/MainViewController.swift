//
//  ViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 9/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UserMatchingDelegate, FirebaseUserDelegate {
    
    
    // MARK: - Front swipeableView outlets
    
    @IBOutlet weak var swipeableView: RWKSwipeableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var bedroomCountLabel: UILabel!
    @IBOutlet weak var bedroomImageView: UIImageView!
    @IBOutlet weak var bathroomCountLabel: UILabel!
    @IBOutlet weak var bathroomImageView: UIImageView!
    @IBOutlet weak var petFriendlyImageView: UIImageView!
    @IBOutlet weak var smokingAllowedImageView: UIImageView!
    
    @IBOutlet weak var starImageView1: UIImageView!
    @IBOutlet weak var starImageView2: UIImageView!
    @IBOutlet weak var starImageView3: UIImageView!
    @IBOutlet weak var starImageView4: UIImageView!
    @IBOutlet weak var starImageView5: UIImageView!
    
    
    // MARK: - Outlets for backgroundView that acts as a faux swipeableView
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundNameLabel: UILabel!
    @IBOutlet weak var backgroundAddressLabel: UILabel!
    
    
    @IBOutlet weak var backgroundBedroomCountLabel: UILabel!
    @IBOutlet weak var backgroundBedroomImageView: UIImageView!
    @IBOutlet weak var backgroundBathroomCountLabel: UILabel!
    @IBOutlet weak var backgroundBathroomImageView: UIImageView!
    @IBOutlet weak var backgroundPetFriendlyImageview: UIImageView!
    @IBOutlet weak var backgroundSmokingAllowedImageView: UIImageView!
    
    @IBOutlet weak var backgroundStarImageView1: UIImageView!
    @IBOutlet weak var backgroundStarImageView2: UIImageView!
    @IBOutlet weak var backgroundStarImageView3: UIImageView!
    @IBOutlet weak var backgroundStarImageView4: UIImageView!
    @IBOutlet weak var backgroundStarImageView5: UIImageView!
    
    
    
    @IBOutlet weak var navigationBarView: UIView!
    
    // MARK: - Properties

    var rotationAngle: CGFloat = 0.0
    var xFromCenter: CGFloat = 0.0
    var yFromCenter: CGFloat = 0.0
    var velocity: CGPoint = CGPoint.zero
    var previousX: CGFloat = 0.0
    var originalCenter: CGPoint = CGPoint.zero
    
    var constraints: [NSLayoutConstraint] = []
    
    var loadingView: UIView?
    var loadingActivityIndicator: UIActivityIndicatorView?
    var loadingViewHasBeenDismissed = false
    
    var users: [Any] = []
    
    
    var matchingUsersAlertController: UIAlertController?
    
    
    
    @IBOutlet weak var loadingLabel: UILabel!
    
    
    var imageIndex = 0
    var backgroundimageIndex: Int {
        if UserController.currentUserType == "renter"{
        return imageIndex + 1 <= FirebaseController.properties.count - 1 ? imageIndex + 1 : 0
        } else if UserController.currentUserType == "landlord" {
            return imageIndex + 1 <= FirebaseController.renters.count - 1 ? imageIndex + 1 : 0
        } else {
            return 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpAndDisplayLoadingScreen()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        FirebaseController.delegate = self
        MatchController.delegate = self
        swipeableView.delegate = self
        setupViews()
        
        if UserController.currentUserType == "renter" {
            UserController.fetchAllProperties()
            
            users = FirebaseController.properties
        } else if UserController.currentUserType == "landlord" {
            UserController.fetchAllRenters()
        }
    }
    
    
    // MARK: - FirebaseUserDelegate
    
    func propertiesWereUpdated() {
        dismissLoadingScreen()
        updateUIElementsForPropertyCards()
    }
    
    func rentersWereUpdated() {
        dismissLoadingScreen()
        updateUIElementsForRenterCards()
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
                
                var usersArray: [TestUser] = []
                
                for id in userIDs {
                    //                    let user = users.filter({$0.id == id})
                    //                    guard let unwrappedUser = user.first else { return }
                    //                    usersArray.append(unwrappedUser)
                }
                
                // WARNING: - This will change once the list of all users who have historically matched get a separate endpoint in Firebase.
                MatchController.allMatches = usersArray
                
                let usersString = usersArray.flatMap({$0.name}).joined(separator: ", ")
                
                let message = usersArray.count == 1 ? "\(usersArray[0].name) has matched with you!" : "\(usersString) have all matched with you!"
                let title = usersArray.count == 1 ? "You have a new match!" : "You have new matches!"
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                let showMatchVCAction = UIAlertAction(title: "Take me to my matches", style: .default, handler: { (_) in
                    self.performSegue(withIdentifier: "toMatchesVC", sender: self)
                })
                
                alertController.addAction(dismissAction)
                alertController.addAction(showMatchVCAction)
                
                alertController.view.tintColor = AppearanceController.customOrangeColor
                
                self.matchingUsersAlertController = alertController
                //                FirebaseController.downloadAndAddProfileImages(forUsers: usersArray, completion: nil)
                if !alertController.isBeingPresented {
                    self.present(alertController, animated: true, completion: nil)
                    print("Did present matchAlert")
                }
                
            }
        } else {
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (_) in
                self.presentMatchAlertController(for: userIDs)
            })
        }
    }
    
    
    // MARK: - UI Related
    
    func updateUIElementsForPropertyCards() {
        let property = FirebaseController.properties[imageIndex]
        
        print(property.propertyID)
        
        guard let firstProfileImage = property.profileImages?.firstObject as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePicture = UIImage(data: imageData as Data), let address = property.address else { return }
        
        
        imageView.image = profilePicture
        nameLabel.text = property.propertyDescription ?? "No description available"
        addressLabel.text = address
        
        bedroomCountLabel.text = "\(property.bedroomCount)"
        bathroomCountLabel.text = property.bathroomCount.isInteger ? "\(Int(property.bathroomCount))" : "\(property.bathroomCount)"
        
        petFriendlyImageView.image = property.petFriendly ? #imageLiteral(resourceName: "Paw") : #imageLiteral(resourceName: "NoPaw")
        smokingAllowedImageView.image = property.smokingAllowed ? #imageLiteral(resourceName: "SmokingAllowed") : #imageLiteral(resourceName: "NoSmokingAllowed")
        
        update(starImageViews: [starImageView1, starImageView2, starImageView3, starImageView4, starImageView5], for: property.rentalHistoryRating)
        
        let nextProperty = FirebaseController.properties[backgroundimageIndex]
        
        guard  let firstBackgroundProfileImage = nextProperty.profileImages?.firstObject as? ProfileImage, let backgroundImageData = firstBackgroundProfileImage.imageData, let backgroundProfilePicture = UIImage(data: backgroundImageData as Data), let backgroundPropertyAddress = nextProperty.address else { return }
        backgroundImageView.image = backgroundProfilePicture
        backgroundNameLabel.text = nextProperty.propertyDescription ?? "No description available"
        backgroundAddressLabel.text = backgroundPropertyAddress
        
        backgroundBedroomCountLabel.text = "\(nextProperty.bedroomCount)"
        backgroundBathroomCountLabel.text = nextProperty.bathroomCount.isInteger ? "\(Int(nextProperty.bathroomCount))" : "\(nextProperty.bathroomCount)"
        
        backgroundPetFriendlyImageview.image = nextProperty.petFriendly ? #imageLiteral(resourceName: "Paw") : #imageLiteral(resourceName: "NoPaw")
        backgroundSmokingAllowedImageView.image = nextProperty.smokingAllowed ? #imageLiteral(resourceName: "SmokingAllowed") : #imageLiteral(resourceName: "NoSmokingAllowed")

        update(starImageViews: [backgroundStarImageView1, backgroundStarImageView2, backgroundStarImageView3, backgroundStarImageView4, backgroundStarImageView5], for: nextProperty.rentalHistoryRating)
        if imageIndex < FirebaseController.properties.count - 1 {
            imageIndex += 1
        } else {
            imageIndex = 0
        }
        
    }
    
    func update(starImageViews: [UIImageView], for rating: Double) {
        
            switch rating {
            case 1:
                starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
                starImageViews[1].image = #imageLiteral(resourceName: "Star")
                starImageViews[2].image = #imageLiteral(resourceName: "Star")
                starImageViews[3].image = #imageLiteral(resourceName: "Star")
                starImageViews[4].image = #imageLiteral(resourceName: "Star")
                
            case 2:
                starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
                starImageViews[1].image = #imageLiteral(resourceName: "StarFilled")
                starImageViews[2].image = #imageLiteral(resourceName: "Star")
                starImageViews[3].image = #imageLiteral(resourceName: "Star")
                starImageViews[4].image = #imageLiteral(resourceName: "Star")
            case 3:
                starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
                starImageViews[1].image = #imageLiteral(resourceName: "StarFilled")
                starImageViews[2].image = #imageLiteral(resourceName: "StarFilled")
                starImageViews[3].image = #imageLiteral(resourceName: "Star")
                starImageViews[4].image = #imageLiteral(resourceName: "Star")
            case 4:
                starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
                starImageViews[1].image = #imageLiteral(resourceName: "StarFilled")
                starImageViews[2].image = #imageLiteral(resourceName: "StarFilled")
                starImageViews[3].image = #imageLiteral(resourceName: "StarFilled")
                starImageViews[4].image = #imageLiteral(resourceName: "Star")
            case 5:
                starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
                starImageViews[1].image = #imageLiteral(resourceName: "StarFilled")
                starImageViews[2].image = #imageLiteral(resourceName: "StarFilled")
                starImageViews[3].image = #imageLiteral(resourceName: "StarFilled")
                starImageViews[4].image = #imageLiteral(resourceName: "StarFilled")
            default:
                _ = starImageViews.map({$0.image = #imageLiteral(resourceName: "Star")})
            }
        
    }
    
    
    func updateUIElementsForRenterCards() {
        let renter = FirebaseController.renters[imageIndex]
        
        guard let firstProfileImage = renter.profileImages?.firstObject as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePicture = UIImage(data: imageData as Data) else { return }
        
        
        imageView.image = profilePicture
        nameLabel.text = "\(renter.firstName ?? "No name available") \(renter.lastName ?? "")"
        addressLabel.text = renter.bio ?? "No bio yet!"
        
        let nextRenter = FirebaseController.renters[backgroundimageIndex]
        
        guard  let firstBackgroundProfileImage = nextRenter.profileImages?.firstObject as? ProfileImage, let backgroundImageData = firstBackgroundProfileImage.imageData, let backgroundProfilePicture = UIImage(data: backgroundImageData as Data) else { return }
        backgroundImageView.image = backgroundProfilePicture
        backgroundNameLabel.text = "\(nextRenter.firstName ?? "No name available") \(nextRenter.lastName ?? "")"
        backgroundAddressLabel.text = nextRenter.bio ?? "No bio yet!"
        
        if imageIndex < FirebaseController.renters.count - 1 {
            imageIndex += 1
        } else {
            imageIndex = 0
        }
        
    }

    
    func setupViews() {
        
        swipeableView.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 15
        
        backgroundImageView.layer.cornerRadius = 15
        backgroundView.layer.cornerRadius = 15
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
        
        loadingLabel.minimumScaleFactor = 0.5
        
        let centerXLoadingViewConstraint = NSLayoutConstraint(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYLoadingViewConstraint = NSLayoutConstraint(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        let centerXLoadingLabelConstraint = NSLayoutConstraint(item: loadingLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        let bottomLoadingLabelConstraint = NSLayoutConstraint(item: loadingLabel, attribute: .bottom, relatedBy: .equal, toItem: self.loadingActivityIndicator, attribute: .top, multiplier: 1, constant: -25)
        let leadingLoadingLabelConstraint = NSLayoutConstraint(item: loadingLabel, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 20)
        let trailingLoadingLabelConstraint = NSLayoutConstraint(item: loadingLabel, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -20)
        
        
        self.view.addConstraints([centerXLoadingViewConstraint, centerYLoadingViewConstraint, centerXLoadingLabelConstraint, bottomLoadingLabelConstraint, leadingLoadingLabelConstraint, trailingLoadingLabelConstraint])
        
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
            
            if UserController.currentUserType == "renter" {
                self.updateUIElementsForPropertyCards()
            } else if UserController.currentUserType == "landlord" {
                self.updateUIElementsForRenterCards()
            }
            
            guard let swipeableView = swipeableView as? RWKSwipeableView else { return }

            if UserController.currentUserType == "renter" {
                guard let property = swipeableView.property else { return }
                MatchController.addCurrentRenter(toLikelistOf: property)
            } else if UserController.currentUserType == "landlord" {
                guard let renter = swipeableView.renter else { return }
                MatchController.addCurrentLandlord(toLikelistOf: renter)
            }
            
        }
    }
    
    func leftAnimationFor(swipeableView: UIView, inSuperview superview: UIView) {
        let finishPoint = CGPoint(x: CGFloat(-750), y: superview.center.y - 100)
    
        UIView.animate(withDuration: 0.7, animations: {
            swipeableView.center = finishPoint
            
            
            swipeableView.transform = CGAffineTransform(rotationAngle: self.degreesToRadians(degree: -90))
        }) { (complete) in
            
            
            
            if UserController.currentUserType == "renter" {
                self.updateUIElementsForPropertyCards()
            } else if UserController.currentUserType == "landlord" {
                self.updateUIElementsForRenterCards()
            }
            self.reset(swipeableView: swipeableView, inSuperview: superview)
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
        
        if UserController.currentUserType == "renter" {
            let property = FirebaseController.properties[imageIndex]
            swipeableView.property = property
            swipeableView.renter = nil
        } else if UserController.currentUserType == "landlord" {
            let renter = FirebaseController.renters[imageIndex]
            swipeableView.renter = renter
            swipeableView.property = nil
        }
        
        
    }
    
    func degreesToRadians(degree: Double) -> CGFloat {
        return CGFloat(M_PI * (degree) / 180.0)
    }
    
}
