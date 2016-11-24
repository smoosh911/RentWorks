//
//  RenterMainViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class RenterMainViewController: MainViewController {
    
    // MARK: outlets
    
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var bedroomCountLabel: UILabel!
    @IBOutlet weak var bedroomImageView: UIImageView!
    @IBOutlet weak var bathroomCountLabel: UILabel!
    @IBOutlet weak var bathroomImageView: UIImageView!
    
    @IBOutlet weak var lblBackgroundPrice: UILabel!
    @IBOutlet weak var backgroundBedroomCountLabel: UILabel!
    @IBOutlet weak var backgroundBedroomImageView: UIImageView!
    @IBOutlet weak var backgroundBathroomCountLabel: UILabel!
    @IBOutlet weak var backgroundBathroomImageView: UIImageView!
    
    @IBOutlet weak var matchesButton: UIButton!
    
    // MARK: variables
    
    let filterKeys = UserController.RenterFilters.self
    
    var filteredProperties: [Property] = [] {
        didSet {
            if filteredProperties.count == 0 {
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
        filteredProperties = getFilteredProperties()
        
        if filteredProperties.isEmpty {
            self.performSegue(withIdentifier: Identifiers.Segues.MoreCardsVC.rawValue, sender: self)
        }
        self.updateCardUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setMatchesButtonImage()
        if super.previousVCWasCardsLoadingVC {
            super.previousVCWasCardsLoadingVC = false
        } else {
            if SettingsViewController.settingsDidChange {
                SettingsViewController.settingsDidChange = false
                filteredProperties = getFilteredProperties()
                if filteredProperties.isEmpty {
                    self.performSegue(withIdentifier: Identifiers.Segues.MoreCardsVC.rawValue, sender: self)
                }
                self.updateCardUI()
            }
        }
    }
    
    // MARK: actions
    
    @IBAction func btnResetCards_TouchedUpInside(_ sender: UIButton) {
        UserController.eraseAllHasBeenViewedByForLandlordFromRenters(landlordID: UserController.currentUserID!, completion: {
            self.downloadMoreCards()
        })
    }
    
    // MARK: UI fuctions
    
    func updateCardUI() {
        // needs work: should have to check usertype in future. Only doing this becasue this function is called by the firebasecontrolelr delegate when properties is updated and I update properties for other perposes as a land lord
        
        if filteredProperties.isEmpty {
            self.swipeableView.isHidden = true
            self.backgroundView.isHidden = true
            downloadMoreCards()
            return
        }
        
        let property = filteredProperties.removeFirst()
        swipeableView.property = property
        var backCardProperty: Property? = nil
        if filteredProperties.count > 0 {
            backCardProperty = filteredProperties.first
        }
        
        guard let firstProfileImage = property.profileImages?.firstObject as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePicture = UIImage(data: imageData as Data), let address = property.address else { return }
        
        imageView.image = profilePicture
        nameLabel.text = address
        lblPrice.text = "$\(property.monthlyPayment)"
        
        bedroomCountLabel.text = "\(property.bedroomCount)"
        bathroomCountLabel.text = property.bathroomCount.isInteger ? "\(Int(property.bathroomCount))" : "\(property.bathroomCount)"
        
        petFriendlyImageView.image = property.petFriendly ? #imageLiteral(resourceName: "Paw") : #imageLiteral(resourceName: "NoPaw")
        smokingAllowedImageView.image = property.smokingAllowed ? #imageLiteral(resourceName: "SmokingAllowed") : #imageLiteral(resourceName: "NoSmokingAllowed")
        
        updateStars(starImageViews: [starImageView1, starImageView2, starImageView3, starImageView4, starImageView5], for: property.rentalHistoryRating)
        
        guard let nextProperty = backCardProperty, let firstBackgroundProfileImage = nextProperty.profileImages?.firstObject as? ProfileImage, let backgroundImageData = firstBackgroundProfileImage.imageData, let backgroundProfilePicture = UIImage(data: backgroundImageData as Data)  else { return }
        
        let backgroundPrice = "$\(nextProperty.monthlyPayment)"
        
        backgroundImageView.image = backgroundProfilePicture
        backgroundNameLabel.text = nextProperty.address
        lblBackgroundPrice.text = backgroundPrice
        
        backgroundBedroomCountLabel.text = "\(nextProperty.bedroomCount)"
        backgroundBathroomCountLabel.text = nextProperty.bathroomCount.isInteger ? "\(Int(nextProperty.bathroomCount))" : "\(nextProperty.bathroomCount)"
        
        backgroundPetFriendlyImageview.image = nextProperty.petFriendly ? #imageLiteral(resourceName: "Paw") : #imageLiteral(resourceName: "NoPaw")
        backgroundSmokingAllowedImageView.image = nextProperty.smokingAllowed ? #imageLiteral(resourceName: "SmokingAllowed") : #imageLiteral(resourceName: "NoSmokingAllowed")
        
        updateStars(starImageViews: [backgroundStarImageView1, backgroundStarImageView2, backgroundStarImageView3, backgroundStarImageView4, backgroundStarImageView5], for: nextProperty.rentalHistoryRating)
    }
    
    func setMatchesButtonImage() {
        DispatchQueue.main.async {
            MatchController.currentUserHasNewMatches ? self.matchesButton.setImage(#imageLiteral(resourceName: "ChatBubbleFilled"), for: .normal) : self.matchesButton.setImage(#imageLiteral(resourceName: "ChatBubble"), for: .normal)
        }
    }
    
    // MARK: - UserMatchingDelegate
    
    func currentUserHasMatches() {
        setMatchesButtonImage()
    }
    
    // MARK: helper methods
    
    func downloadMoreCards() {
        if !FirebaseController.isFetchingNewProperties {
            FirebaseController.isFetchingNewProperties = true
            UserController.fetchProperties(numberOfProperties: 6, completion: {
                FirebaseController.isFetchingNewProperties = false
                
                let newFilteredProperties = self.getFilteredProperties()
                let uniqueProperties = newFilteredProperties.filter({ !self.filteredProperties.contains($0) })
                if uniqueProperties.count > 0 {
                    self.filteredProperties.append(contentsOf: uniqueProperties)
                }
                if self.filteredProperties.count == 0 {
                    self.performSegue(withIdentifier: Identifiers.Segues.MoreCardsVC.rawValue, sender: self)
                } else {
                    self.updateCardUI()
                }
            })
        }
    }
    
    func getFilteredProperties() -> [Property] {
        let filterSettingsDict = UserController.getRenterFiltersDictionary()
        
        let desiredBathroomCount = filterSettingsDict[filterKeys.kBathroomCount.rawValue] as! Double
        let desiredBedroomCount = Int64(filterSettingsDict[filterKeys.kBedroomCount.rawValue] as! Int)
        let desiredPayment = Int64(filterSettingsDict[filterKeys.kMonthlyPayment.rawValue] as! Int)
        let desiredPetsAllowed = filterSettingsDict[filterKeys.kPetsAllowed.rawValue] as! Bool
        let desiredSmokingAllowed = filterSettingsDict[filterKeys.kSmokingAllowed.rawValue] as! Bool
        let desiredPropertyFeatures = filterSettingsDict[filterKeys.kPropertyFeatures.rawValue] as! String
        let desiredZipcode = filterSettingsDict[filterKeys.kZipCode.rawValue] as! String
        
        let filtered = FirebaseController.properties.filter({ $0.bathroomCount == desiredBathroomCount && $0.bedroomCount == desiredBedroomCount && $0.monthlyPayment <= desiredPayment && $0.petFriendly == desiredPetsAllowed && $0.smokingAllowed == desiredSmokingAllowed && $0.zipCode == desiredZipcode})
        
        return filtered
    }
}
