//
//  LandlordMainViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordMainViewController: MainViewController {
    
    @IBOutlet weak var lblFrontCardCreditRating: UILabel!
    @IBOutlet weak var lblBackCardCreditRating: UILabel!
    
    var wantsCreditRating = ""
    var filteredRenters: [Renter] = [] {
        didSet {
            if filteredRenters.count == 0 {
                super.backgroundView.isHidden = true
                super.swipeableView.isHidden = true
            } else if filteredRenters.count == 1 {
                super.backgroundView.isHidden = true
            } else {
                super.backgroundView.isHidden = false
            }
        }
    }
    
    var cardsAreLoading = false {
        didSet {
            if cardsAreLoading {
                let storyboard = UIStoryboard(name: "LandlordMain", bundle: nil)
                let mainVC = storyboard.instantiateViewController(withIdentifier: "cardLoadingVC")
                self.present(mainVC, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let desiredCreditRating = UserController.currentLandlord?.wantsCreditRating {
            wantsCreditRating = desiredCreditRating
            filteredRenters = desiredCreditRating == "Any" ? FirebaseController.renters : FirebaseController.renters.filter({ $0.creditRating == desiredCreditRating})
            if filteredRenters.isEmpty {
                self.performSegue(withIdentifier: Identifiers.Segues.MoreCardsVC.rawValue, sender: self)
            }
            self.updateCardUI()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if super.previousVCWasCardsLoadingVC {
            super.previousVCWasCardsLoadingVC = false
        } else {
            if let desiredCreditRating = UserController.currentLandlord?.wantsCreditRating {
                if wantsCreditRating != desiredCreditRating {
                    wantsCreditRating = desiredCreditRating
                    filteredRenters = desiredCreditRating == "Any" ? FirebaseController.renters : FirebaseController.renters.filter({ $0.creditRating == desiredCreditRating})
                    if filteredRenters.isEmpty {
                        self.performSegue(withIdentifier: Identifiers.Segues.MoreCardsVC.rawValue, sender: self)
                    }
                    self.updateCardUI()
                }
            }
        }
    }
    
    func updateCardUI() {
        
        if filteredRenters.isEmpty {
            return
        }
        
        let renter = filteredRenters[imageIndex]
        var backCardRenter: Renter? = nil
        if !super.backgroundView.isHidden {
            backCardRenter = filteredRenters[backgroundimageIndex]
        }
        
        guard let firstProfileImage = renter.profileImages?.firstObject as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePicture = UIImage(data: imageData as Data) else { return }
        
        lblFrontCardCreditRating.text = renter.creditRating
        imageView.image = profilePicture
        nameLabel.text = "\(renter.firstName ?? "No name available") \(renter.lastName ?? "")"
        //        addressLabel.text = renter.bio ?? "No bio yet!"
        
        guard let nextRenter = backCardRenter, let firstBackgroundProfileImage = nextRenter.profileImages?.firstObject as? ProfileImage, let backgroundImageData = firstBackgroundProfileImage.imageData, let backgroundProfilePicture = UIImage(data: backgroundImageData as Data) else { return }
        backgroundImageView.image = backgroundProfilePicture
        backgroundNameLabel.text = "\(nextRenter.firstName ?? "No name available") \(nextRenter.lastName ?? "")"
        backgroundAddressLabel.text = nextRenter.bio ?? "No bio yet!"
        
        lblBackCardCreditRating.text = nextRenter.creditRating
        
        resetData()
    }
}
