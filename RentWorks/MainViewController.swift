//
//  ViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 9/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainViewController: UIViewController, MatchControllerDelegate {
    
    // MARK: - Front swipeableView outlets
    
    @IBOutlet weak var swipeableView: RWKSwipeableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
//    @IBOutlet weak var petFriendlyImageView: UIImageView!
//    @IBOutlet weak var smokingAllowedImageView: UIImageView!
//    
//    @IBOutlet weak var starImageView1: UIImageView!
//    @IBOutlet weak var starImageView2: UIImageView!
//    @IBOutlet weak var starImageView3: UIImageView!
//    @IBOutlet weak var starImageView4: UIImageView!
//    @IBOutlet weak var starImageView5: UIImageView!
    
    // MARK: - Outlets for backgroundView that acts as a faux swipeableView
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundNameLabel: UILabel!
    
//    @IBOutlet weak var backgroundPetFriendlyImageview: UIImageView!
//    @IBOutlet weak var backgroundSmokingAllowedImageView: UIImageView!
//    
//    @IBOutlet weak var backgroundStarImageView1: UIImageView!
//    @IBOutlet weak var backgroundStarImageView2: UIImageView!
//    @IBOutlet weak var backgroundStarImageView3: UIImageView!
//    @IBOutlet weak var backgroundStarImageView4: UIImageView!
//    @IBOutlet weak var backgroundStarImageView5: UIImageView!
    
    // MARK: - Other outlets
    
    @IBOutlet weak var vwFilters: UIView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var matchesButton: UIButton!
    @IBOutlet weak var imgvwNewMessagesBlip: UIImageView!
    
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
    var previousVCWasCardsLoadingVC = false
    
    var users: [Any] = []
    
    var matchingUsersAlertController: UIAlertController?
    
    let paddingConstant: CGFloat = -94.0 // this is for the swiping animations in the extension below
    
    // MARK: View life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FBSDKAccessToken.current() != nil { print(FBSDKAccessToken.current().expirationDate) }
        
        self.backgroundView.isHidden = true
        
        swipeableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        MatchController.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupViews()
    }
    
    // MARK: actions
    
    @IBAction func btnProfile_TouchedUpInside(_ sender: Any) {
//        do {
//            try FIRAuth.auth()?.signOut()
//        } catch let e {
//            log(e)
//        }
        
        if FIRAuth.auth()?.currentUser == nil {
            performSegue(withIdentifier: Identifiers.Segues.signUpProfileVC.rawValue, sender: self)
        } else {
            performSegue(withIdentifier: Identifiers.Segues.profileVC.rawValue, sender: self)
        }
    }
    
    // MARK: helper 
    
    func setMatchesButtonImage() {
        DispatchQueue.main.async {
            if MatchController.currentUserHasNewMatches {
                self.imgvwNewMessagesBlip.isHidden = false
            } else {
                self.imgvwNewMessagesBlip.isHidden = true
            }
        }
    }
    
    // MARK: - UI Related
    // needs work: this fuction occurs multiple times in code
//    func updateStars(starImageViews: [UIImageView], for rating: Double) {
//        
//        switch rating {
//        case 1:
//            starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
//            starImageViews[1].image = #imageLiteral(resourceName: "Star")
//            starImageViews[2].image = #imageLiteral(resourceName: "Star")
//            starImageViews[3].image = #imageLiteral(resourceName: "Star")
//            starImageViews[4].image = #imageLiteral(resourceName: "Star")
//            
//        case 2:
//            starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
//            starImageViews[1].image = #imageLiteral(resourceName: "StarFilled")
//            starImageViews[2].image = #imageLiteral(resourceName: "Star")
//            starImageViews[3].image = #imageLiteral(resourceName: "Star")
//            starImageViews[4].image = #imageLiteral(resourceName: "Star")
//        case 3:
//            starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
//            starImageViews[1].image = #imageLiteral(resourceName: "StarFilled")
//            starImageViews[2].image = #imageLiteral(resourceName: "StarFilled")
//            starImageViews[3].image = #imageLiteral(resourceName: "Star")
//            starImageViews[4].image = #imageLiteral(resourceName: "Star")
//        case 4:
//            starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
//            starImageViews[1].image = #imageLiteral(resourceName: "StarFilled")
//            starImageViews[2].image = #imageLiteral(resourceName: "StarFilled")
//            starImageViews[3].image = #imageLiteral(resourceName: "StarFilled")
//            starImageViews[4].image = #imageLiteral(resourceName: "Star")
//        case 5:
//            starImageViews[0].image = #imageLiteral(resourceName: "StarFilled")
//            starImageViews[1].image = #imageLiteral(resourceName: "StarFilled")
//            starImageViews[2].image = #imageLiteral(resourceName: "StarFilled")
//            starImageViews[3].image = #imageLiteral(resourceName: "StarFilled")
//            starImageViews[4].image = #imageLiteral(resourceName: "StarFilled")
//        default:
//            _ = starImageViews.map({$0.image = #imageLiteral(resourceName: "Star")})
//        }
//    }
    
    // set corner radius of views and image views
    func setupViews() {
        
        let path = UIBezierPath(roundedRect:imageView.bounds,
                                byRoundingCorners:[.topRight, .topLeft],
                                cornerRadii: CGSize(width: 10, height:  10))
        
        let maskLayer = CAShapeLayer()
        let maskLayer2 = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        maskLayer2.path = path.cgPath
        
        imageView.layer.mask = maskLayer
        backgroundImageView.layer.mask = maskLayer2
        
        swipeableView.layer.cornerRadius = 10
        backgroundView.layer.cornerRadius = 10
        
        vwFilters.layer.cornerRadius = vwFilters.frame.width / 2
    }
    
    // MARK: matchcontroller delegate
    
    func currentUserHasMatchesUpdated() { // overriden and implemented in child controllers
        setMatchesButtonImage()
    }
}

// MARK: - RWKSwipeableViewDelegate

extension MainViewController: RWKSwipeableViewDelegate {
    internal func updateCardUI() {
        
    }
    
    internal func swipableView(_ swipableView: RWKSwipeableView, didSwipeOn cardEntity: Any) {
        
    }

    // MARK: - Animations
    
    func beingDragged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        let label = gesture.view!
        
        let swipeSpeed: CGFloat = 1.3
        let rotationSpeedBuffer: CGFloat = 800.0 // the higher the number the slower the rotation
        
        label.center = CGPoint(x: self.view.bounds.width / 2 + translation.x * swipeSpeed, y: self.view.bounds.height / 2 + paddingConstant)
        
        let xFromCenter = label.center.x - self.view.bounds.width / 2.0
        
        var transform = CGAffineTransform.identity
        transform = transform.rotated(by: xFromCenter / rotationSpeedBuffer)
        
        label.transform = transform
    }
    
    func swipeLeftCompleteTransform(view: UIView) {
        let rotationSpeedBuffer: CGFloat = 800.0 // the higher the number the slower the rotation
        let xEndPoint: CGFloat = 500.0 // this is where the card will animate to when the user lets go
        
        view.center = CGPoint(x: self.view.bounds.width / 2 - xEndPoint, y: self.view.bounds.height / 2 + paddingConstant)
        
        let xFromCenter = view.center.x - self.view.bounds.width / 2.0
        
        var anitransform = CGAffineTransform.identity
        anitransform = anitransform.rotated(by: xFromCenter / rotationSpeedBuffer)
        
        view.transform = anitransform
    }
    
    func swipeRightCompleteTransform(view: UIView) {
        let rotationSpeedBuffer: CGFloat = 800.0 // the higher the number the slower the rotation
        let xEndPoint: CGFloat = 500.0 // this is where the card will animate to when the user lets go
        
        view.center = CGPoint(x: self.view.bounds.width / 2 + xEndPoint, y: self.view.bounds.height / 2 + paddingConstant)
        let xFromCenter = view.center.x - self.view.bounds.width / 2.0
        
        var anitransform = CGAffineTransform.identity
        anitransform = anitransform.rotated(by: xFromCenter / rotationSpeedBuffer)
        
        view.transform = anitransform
    }
    
    func resetFrontCardTransform(view: UIView) {
        var endTransform = CGAffineTransform.identity
        
        endTransform = endTransform.rotated(by: 0.0)
        endTransform = endTransform.scaledBy(x: 1.0, y: 1.0)
        
        view.transform = endTransform
        
        view.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2 + paddingConstant)
    }
}
