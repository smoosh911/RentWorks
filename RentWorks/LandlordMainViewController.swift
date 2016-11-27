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
    @IBOutlet weak var lblRenterOccupation: UILabel!
    
    @IBOutlet weak var lblBackCardCreditRating: UILabel!
    @IBOutlet weak var lblBackCardRenterOccupation: UILabel!
    
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
            if SettingsViewController.settingsDidChange {
                SettingsViewController.settingsDidChange = false
                filteredRenters = getFilteredRenters()
                if filteredRenters.isEmpty && UserController.renterFetchCount == 1 {
                    self.performSegue(withIdentifier: Identifiers.Segues.MoreCardsVC.rawValue, sender: self)
                }
                self.updateCardUI()
            }
        }
    }
    
    // MARK: actions
    
    @IBAction func btnResetCards_TouchedUpInside(_ sender: Any) {
        UserController.eraseAllHasBeenViewedByForLandlordFromRenters(landlordID: UserController.currentUserID!, completion: {
            self.downloadMoreCards()
        })
    }
    
    // MARK: rwkswipabelview delegate
    
    override func updateCardUI() {
        
        // needs work: this if statement should be in the next if statement
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
        swipeableView.renter = renter
        
        var backCardRenter: Renter? = nil
        if !super.backgroundView.isHidden {
            backCardRenter = filteredRenters.first
        }
        
        guard let firstProfileImage = renter.profileImages?.firstObject as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePicture = UIImage(data: imageData as Data) else { return }
        
        lblFrontCardCreditRating.text = renter.creditRating
        imageView.image = profilePicture
        nameLabel.text = "\(renter.firstName ?? "No name available") \(renter.lastName ?? "")"
        lblRenterOccupation.text = renter.occupation ?? "No listed occupation"
        
        guard let nextRenter = backCardRenter, let firstBackgroundProfileImage = nextRenter.profileImages?.firstObject as? ProfileImage, let backgroundImageData = firstBackgroundProfileImage.imageData, let backgroundProfilePicture = UIImage(data: backgroundImageData as Data) else { return }
        backgroundImageView.image = backgroundProfilePicture
        backgroundNameLabel.text = "\(nextRenter.firstName ?? "No name available") \(nextRenter.lastName ?? "")"
        lblBackCardRenterOccupation.text = nextRenter.occupation ?? "No listed occupation"
        
        lblBackCardCreditRating.text = nextRenter.creditRating
    }
    
    override func swipableView(_ swipableView: RWKSwipeableView, didSwipeOn cardEntity: Any) {
        guard let renter = cardEntity as? Renter, let renterID = renter.id, let landlordID = UserController.currentUserID else { return }
        UserController.addHasBeenViewedByLandlordToRenterInFirebase(renterID: renterID, landlordID: landlordID)
    }
    
    // MARK: helper methods
    
    func downloadMoreCards() {
        if !FirebaseController.isFetchingNewRenters {
            if UserController.renterFetchCount == 1 { // if fetch count is one here then the last card in the database has already been pulled
                performSegue(withIdentifier: Identifiers.Segues.MoreCardsVC.rawValue, sender: self)
                return
            }
            FirebaseController.isFetchingNewRenters = true
            UserController.fetchRenters(numberOfRenters: 6, completion: {
                FirebaseController.isFetchingNewRenters = false
                let newFilteredRenters = self.getFilteredRenters()
                let uniqueRenters = newFilteredRenters.filter({ !self.filteredRenters.contains($0) })
                if uniqueRenters.count > 0 {
                    self.filteredRenters.append(contentsOf: uniqueRenters)
                }
                if newFilteredRenters.count == 0 && UserController.propertyFetchCount > 1 {
                    self.downloadMoreCards()
                } else {
                    self.updateCardUI()
                }
            })
        }
    }
    
    func getFilteredRenters() -> [Renter] {
        let filtered = FirebaseController.renters
        if FirebaseController.renters.count > 0 {
            FirebaseController.renters.removeAll()
        }
        
        return filtered
    }
}
