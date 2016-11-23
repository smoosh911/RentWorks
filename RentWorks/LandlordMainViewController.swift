//
//  LandlordMainViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordMainViewController: MainViewController {
    
    // MARK: outlets
    
    @IBOutlet weak var lblFrontCardCreditRating: UILabel!
    @IBOutlet weak var lblRenterBio: UILabel!
    
    @IBOutlet weak var lblBackCardCreditRating: UILabel!
    @IBOutlet weak var lblBackCardRenterBio: UILabel!
    
    // MARK: variables
    
    var currentCardRenter: Renter? = nil
    
    var filteredRenters: [Renter] = [] {
        didSet {
            if filteredRenters.count == 0 {
                super.swipeableView.isHidden = false
                super.backgroundView.isHidden = true
            } else {
                super.swipeableView.isHidden = false
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
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let desiredCreditRating = UserController.currentLandlord?.wantsCreditRating {
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
                if SettingsViewController.settingsDidChange {
                    SettingsViewController.settingsDidChange = false
                    filteredRenters = desiredCreditRating == "Any" ? FirebaseController.renters : FirebaseController.renters.filter({ $0.creditRating == desiredCreditRating})
                    if filteredRenters.isEmpty {
                        self.performSegue(withIdentifier: Identifiers.Segues.MoreCardsVC.rawValue, sender: self)
                    }
                    self.updateCardUI()
                }
            }
        }
    }
    
    // MARK: actions
    
    @IBAction func btnResetCards_TouchedUpInside(_ sender: Any) {
        UserController.eraseAllHasBeenViewedByForLandlordFromRenters(landlordID: UserController.currentUserID!, completion: {
            self.downloadMoreCards()
        })
    }
    
    // MARK: helper methods
    
    func updateCardUI() {
        if filteredRenters.count < 1 {
            downloadMoreCards()
        }
        
        if filteredRenters.isEmpty {
            super.backgroundView.isHidden = true
            super.swipeableView.isHidden = true
            return
        }
        
        currentCardRenter = filteredRenters.removeFirst()
        guard let renter = currentCardRenter else { return }
        
        UserController.addHasBeenViewdByLandlordToRenterInFirebase(renterID: renter.id!, landlordID: UserController.currentUserID!)
        
        var backCardRenter: Renter? = nil
        if !super.backgroundView.isHidden {
            backCardRenter = filteredRenters.first
        }
        
        guard let firstProfileImage = renter.profileImages?.firstObject as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePicture = UIImage(data: imageData as Data) else { return }
        
        lblFrontCardCreditRating.text = renter.creditRating
        imageView.image = profilePicture
        nameLabel.text = "\(renter.firstName ?? "No name available") \(renter.lastName ?? "")"
        lblRenterBio.text = renter.bio ?? "No bio yet!"
        
        guard let nextRenter = backCardRenter, let firstBackgroundProfileImage = nextRenter.profileImages?.firstObject as? ProfileImage, let backgroundImageData = firstBackgroundProfileImage.imageData, let backgroundProfilePicture = UIImage(data: backgroundImageData as Data) else { return }
        backgroundImageView.image = backgroundProfilePicture
        backgroundNameLabel.text = "\(nextRenter.firstName ?? "No name available") \(nextRenter.lastName ?? "")"
        lblBackCardRenterBio.text = nextRenter.bio ?? "No bio yet!"
        
        lblBackCardCreditRating.text = nextRenter.creditRating
        
//        resetData()
    }
    
    func downloadMoreCards() {
        if !FirebaseController.isFetchingNewRenters {
            FirebaseController.isFetchingNewRenters = true
            UserController.fetchRenters(numberOfRenters: 6, completion: {
                if let desiredCreditRating = UserController.currentLandlord?.wantsCreditRating {
                    let newFilteredRenters = desiredCreditRating == "Any" ? FirebaseController.renters : FirebaseController.renters.filter({ $0.creditRating == desiredCreditRating})
                    let uniqueRenters = newFilteredRenters.filter({ !self.filteredRenters.contains($0) })
                    if uniqueRenters.count > 0 {
                        self.filteredRenters.append(contentsOf: uniqueRenters)
                    }
                    if self.filteredRenters.count == 0 {
                        self.performSegue(withIdentifier: Identifiers.Segues.MoreCardsVC.rawValue, sender: self)
                    } else {
                        self.updateCardUI()
                    }
                }
                FirebaseController.isFetchingNewRenters = false
            })
        }
    }
}
