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
    
    // MARK: - Other outlets
    
    @IBOutlet weak var matchesButton: UIButton!
    
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
//    var loadingViewHasBeenDismissed = false
    var previousVCWasCardsLoadingVC = false
    
    var users: [Any] = []
    
    var matchingUsersAlertController: UIAlertController?
    
    // needs work possibly: make sure there isn't a redundant amount of backgroundview.ishidden calls
    var imageIndex = 0 {
        didSet{
            if UserController.currentUserType == "renter"{
                if FirebaseController.properties.count < 2 {
                    self.backgroundView.isHidden = true
                } else {
                    self.backgroundView.isHidden = false
                }
            } else if UserController.currentUserType == "landlord" {
                if FirebaseController.renters.count < 2 {
                    self.backgroundView.isHidden = true
                } else {
                    self.backgroundView.isHidden = false
                }
            }
        }
    }
    var backgroundimageIndex: Int {
        if UserController.currentUserType == "renter"{
            return imageIndex + 1 <= FirebaseController.properties.count - 1 ? imageIndex + 1 : 0
        } else if UserController.currentUserType == "landlord" {
            return imageIndex + 1 <= FirebaseController.renters.count - 1 ? imageIndex + 1 : 0
        } else {
            return 0
        }
    }
    
    // MARK: View life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if FBSDKAccessToken.current() != nil { print(FBSDKAccessToken.current().expirationDate) }
        
        self.backgroundView.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        FirebaseController.delegate = self
        MatchController.delegate = self
        swipeableView.delegate = self
        setupViews()
        
//        if UserController.currentUserType == "renter" {
//            updateUIElementsForPropertyCards()
//        } else if UserController.currentUserType == "landlord" {
//            updateUIElementsForRenterCards()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setMatchesButtonImage()
        self.navigationController?.setNavigationBarHidden(true, animated: false)

    }
    
    // MARK: - FirebaseUserDelegate
    
    func propertiesWereUpdated() {
//        updateUIElementsForPropertyCards()
    }
    
    func rentersWereUpdated() {
//        updateUIElementsForRenterCards()
    }
    
    // MARK: - UserMatchingDelegate
    
    func currentUserHasMatches() {
        setMatchesButtonImage()
        MatchController.delegate = self
    }
    
    func setMatchesButtonImage() {
        DispatchQueue.main.async {
            MatchController.currentUserHasNewMatches ? self.matchesButton.setImage(#imageLiteral(resourceName: "ChatBubbleFilled"), for: .normal) : self.matchesButton.setImage(#imageLiteral(resourceName: "ChatBubble"), for: .normal)
        }
    }
    
    // MARK: - UI Related
    
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
    
    // set corner radius of views and image views
    func setupViews() {
        
        swipeableView.layer.cornerRadius = 15
        imageView.layer.cornerRadius = 15
        
        backgroundImageView.layer.cornerRadius = 15
        backgroundView.layer.cornerRadius = 15
    }
}

// MARK: - RWKSwipeableViewDelegate

extension MainViewController: RWKSwipeableViewDelegate {

    // MARK: - Animations
    
    func beingDragged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        let label = gesture.view!
        
        let swipeSpeed: CGFloat = 1.3
        let paddingFromBottomOfScreen: CGFloat = 20.0
        let rotationSpeedBuffer: CGFloat = 800.0 // the higher the number the slower the rotation
        
        label.center = CGPoint(x: self.view.bounds.width / 2 + translation.x * swipeSpeed, y: self.view.bounds.height / 2 + paddingFromBottomOfScreen)
        
        let xFromCenter = label.center.x - self.view.bounds.width / 2.0
        
        var transform = CGAffineTransform.identity
        transform = transform.rotated(by: xFromCenter / rotationSpeedBuffer)
        
        label.transform = transform
    }
    
    func swipeLeftCompleteTransform(view: UIView) {
        let paddingFromBottomOfScreen: CGFloat = 20.0
        let rotationSpeedBuffer: CGFloat = 800.0 // the higher the number the slower the rotation
        let xEndPoint: CGFloat = 500.0 // this is where the card will animate to when the user lets go
        
        view.center = CGPoint(x: self.view.bounds.width / 2 - xEndPoint, y: self.view.bounds.height / 2 + paddingFromBottomOfScreen)
        
        let xFromCenter = view.center.x - self.view.bounds.width / 2.0
        
        var anitransform = CGAffineTransform.identity
        anitransform = anitransform.rotated(by: xFromCenter / rotationSpeedBuffer)
        
        view.transform = anitransform
    }
    
    func swipeRightCompleteTransform(view: UIView) {
        let paddingFromBottomOfScreen: CGFloat = 20.0
        let rotationSpeedBuffer: CGFloat = 800.0 // the higher the number the slower the rotation
        let xEndPoint: CGFloat = 500.0 // this is where the card will animate to when the user lets go
        
        view.center = CGPoint(x: self.view.bounds.width / 2 + xEndPoint, y: self.view.bounds.height / 2 + paddingFromBottomOfScreen)
        let xFromCenter = view.center.x - self.view.bounds.width / 2.0
        
        var anitransform = CGAffineTransform.identity
        anitransform = anitransform.rotated(by: xFromCenter / rotationSpeedBuffer)
        
        view.transform = anitransform
        
        likeUser()
    }
    
    func resetFrontCardTransform(view: UIView) {
        let paddingFromBottomOfScreen: CGFloat = 20.0
        
        var endTransform = CGAffineTransform.identity
        
        endTransform = endTransform.rotated(by: 0.0)
        endTransform = endTransform.scaledBy(x: 1.0, y: 1.0)
        
        view.transform = endTransform
        
        view.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2 + paddingFromBottomOfScreen)
    }
    
    // MARK: - update data
    
    func updateUIElementsForPropertyCards() {
        // needs work: should have to check usertype in future. Only doing this becasue this function is called by the firebasecontrolelr delegate when properties is updated and I update properties for other perposes as a land lord
        if UserController.currentUserType == UserController.UserCreationType.landlord.rawValue {
            return
        }
        
        if !(FirebaseController.properties.count > 0) {
            return
        }
        
        let property = FirebaseController.properties[imageIndex]
        
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
        
        guard let firstBackgroundProfileImage = nextProperty.profileImages?.firstObject as? ProfileImage, let backgroundImageData = firstBackgroundProfileImage.imageData, let backgroundProfilePicture = UIImage(data: backgroundImageData as Data), let backgroundPropertyAddress = nextProperty.address else { return }
        
        self.backgroundView.isHidden = false
        
        backgroundImageView.image = backgroundProfilePicture
        backgroundNameLabel.text = nextProperty.propertyDescription ?? "No description available"
        backgroundAddressLabel.text = backgroundPropertyAddress
        
        backgroundBedroomCountLabel.text = "\(nextProperty.bedroomCount)"
        backgroundBathroomCountLabel.text = nextProperty.bathroomCount.isInteger ? "\(Int(nextProperty.bathroomCount))" : "\(nextProperty.bathroomCount)"
        
        backgroundPetFriendlyImageview.image = nextProperty.petFriendly ? #imageLiteral(resourceName: "Paw") : #imageLiteral(resourceName: "NoPaw")
        backgroundSmokingAllowedImageView.image = nextProperty.smokingAllowed ? #imageLiteral(resourceName: "SmokingAllowed") : #imageLiteral(resourceName: "NoSmokingAllowed")
        
        update(starImageViews: [backgroundStarImageView1, backgroundStarImageView2, backgroundStarImageView3, backgroundStarImageView4, backgroundStarImageView5], for: nextProperty.rentalHistoryRating)
        
        resetData()
    }
    
    func likeUser() {
        if UserController.currentUserType == "renter" {
            guard let property = swipeableView.property else { return }
            MatchController.addCurrentRenter(toLikelistOf: property)
        } else if UserController.currentUserType == "landlord" {
            guard let renter = swipeableView.renter else { return }
            MatchController.addCurrentLandlord(toLikelistOf: renter)
        }
    }
    
    func resetData() {
        if UserController.currentUserType == "renter" {
            let property = FirebaseController.properties[imageIndex]
            swipeableView.property = property
            swipeableView.renter = nil
            if imageIndex < FirebaseController.properties.count - 1 {
                imageIndex += 1
            } else {
                imageIndex = 0
            }
        } else if UserController.currentUserType == "landlord" {
            let renter = FirebaseController.renters[imageIndex]
            swipeableView.renter = renter
            swipeableView.property = nil
            if imageIndex < FirebaseController.renters.count - 1 {
                imageIndex += 1
            } else {
                imageIndex = 0
            }
        }
    }
}
