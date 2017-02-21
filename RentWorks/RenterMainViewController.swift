//
//  RenterMainViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import FirebaseAuth

class RenterMainViewController: MainViewController, RenterFilterSettingsModalViewControllerDelegate {
    
    // MARK: outlets
    
    @IBOutlet weak var vwLoadingNewCards: UIView!
    @IBOutlet weak var vwNoMoreCards: UIView!
    
    @IBOutlet weak var clctvwFrontCardPropertyFeatures: UICollectionView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var bedroomCountLabel: UILabel!
//    @IBOutlet weak var bedroomImageView: UIImageView!
    @IBOutlet weak var bathroomCountLabel: UILabel!
//    @IBOutlet weak var bathroomImageView: UIImageView!
    @IBOutlet weak var lblCityState: UILabel!
    
    @IBOutlet weak var clctvwBackCardPropertyFeatures: UICollectionView!
    @IBOutlet weak var lblBackgroundPrice: UILabel!
    @IBOutlet weak var backgroundBedroomCountLabel: UILabel!
//    @IBOutlet weak var backgroundBedroomImageView: UIImageView!
    @IBOutlet weak var backgroundBathroomCountLabel: UILabel!
//    @IBOutlet weak var backgroundBathroomImageView: UIImageView!
    @IBOutlet weak var lblBackCityState: UILabel!
    
    // MARK: variables
    
//    let filterKeys = UserController.RenterFilters.self
    var currentCardProperty: Property? = nil
    
    var frontCardPropertyFeaturesCollectionViewItems: [String] = []
    
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
                vwLoadingNewCards.isHidden = false
                vwNoMoreCards.isHidden = true
            } else {
                vwLoadingNewCards.isHidden = true
            }
        }
    }
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MatchController.observeLikesForCurrentRenter()
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
                self.updateCardUI()
            }
        }
    }
    
    // MARK: actions
    
    @IBAction func btnResetCards_TouchedUpInside(_ sender: UIButton) {
        RenterController.eraseAllHasBeenViewedByForRenterFromProperties(renterID: UserController.currentUserID!, completion: {
            guard let renter = UserController.currentRenter, let renterID = renter.id else { return }
            UserController.propertyFetchCount = 0
            RenterController.resetStartAtForRenterInFirebase(renterID: renterID)
            self.updateCardUI()
        })
    }
    
    @IBAction func btnViewDetails_TouchedUpInside(_ sender: Any) {
//        performSegue(withIdentifier: Identifiers.Segues.CardDetailVC.rawValue, sender: self)
    }
    
    @IBAction func btnMatches_TouchedUpInside(_ sender: Any) {
        if UIApplication.shared.isRegisteredForRemoteNotifications && FIRAuth.auth()?.currentUser != nil {
            performSegue(withIdentifier: Identifiers.Segues.renterMatchesVC.rawValue, sender: self)
        } else if FIRAuth.auth()?.currentUser == nil {
            AlertManager.alert(withTitle: "Not Logged In", withMessage: "Please sign in to use messaging", dismissTitle: "OK", inViewController: self)
        } else {
            AlertManager.alert(withTitle: "Notification Disabled", withMessage: "Please enable notifications in order to use messages", dismissTitle: "OK", inViewController: self)
        }
        
    }
    
    // MARK: Swipableview delegate
    
    override func updateCardUI() {
        // needs work: should have to check usertype in future. Only doing this becasue this function is called by the firebasecontrolelr delegate when properties is updated and I update properties for other perposes as a land lord
        
        if filteredProperties.isEmpty {
            self.swipeableView.isHidden = true
            self.backgroundView.isHidden = true
            downloadMoreCards()
            return
        }
        
        currentCardProperty = filteredProperties.removeFirst()
        guard let property = currentCardProperty else { return }
        swipeableView.property = property
        
        var backCardProperty: Property? = nil
        if !super.backgroundView.isHidden {
            backCardProperty = filteredProperties.first
        }
        
        guard let address = property.address, let renterID = UserController.currentUserID, let propertyID = property.propertyID else {
            filteredProperties = filteredProperties.filter({$0.propertyID! != property.propertyID!})
            return
        }
        
        var profilePicture: UIImage?
        if let firstProfileImage = property.profileImages?.firstObject as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePic = UIImage(data: imageData as Data) {
            profilePicture = profilePic
        } else {
            log("ERROR: couldn't load a profile image")
        }
        
        if UserController.currentUserID != "" {
            RenterController.updateCurrentRenterInFirebase(id: renterID, attributeToUpdate: UserController.kStartAt, newValue: propertyID)
        }
        
        imageView.image = profilePicture
        nameLabel.text = address
        lblPrice.text = "$\(property.monthlyPayment)"
        
        bedroomCountLabel.text = "\(property.bedroomCount) Bed"
        bathroomCountLabel.text = property.bathroomCount.isInteger ? "\(Int(property.bathroomCount)) Bath" : "\(property.bathroomCount) Bath"
        
        lblCityState.text = "\(property.city ?? "")\(property.state == "" ? "" : ",") \(property.state ?? "")"
        
        frontCardPropertyFeaturesCollectionViewItems = getFeaturesArray(forProperty: property)
        clctvwFrontCardPropertyFeatures.reloadData()
        
//        petFriendlyImageView.image = property.petFriendly ? #imageLiteral(resourceName: "Paw") : #imageLiteral(resourceName: "NoPaw")
//        smokingAllowedImageView.image = property.smokingAllowed ? #imageLiteral(resourceName: "SmokingAllowed") : #imageLiteral(resourceName: "NoSmokingAllowed")
        
//        updateStars(starImageViews: [starImageView1, starImageView2, starImageView3, starImageView4, starImageView5], for: property.rentalHistoryRating)
        
        guard let nextProperty = backCardProperty else {
            
            filteredProperties = filteredProperties.filter({$0.propertyID! != backCardProperty?.propertyID!})
            return
        }
        
        var backgroundProfilePicture: UIImage?
        if let firstBackgroundProfileImage = nextProperty.profileImages?.firstObject as? ProfileImage, let backgroundImageData = firstBackgroundProfileImage.imageData, let backgroundProfilePic = UIImage(data: backgroundImageData as Data) {
            backgroundProfilePicture = backgroundProfilePic
        } else {
            log("ERROR: couldn't load a profile image")
        }
        
        let backgroundPrice = "$\(nextProperty.monthlyPayment)"
        
        backgroundImageView.image = backgroundProfilePicture
        backgroundNameLabel.text = nextProperty.address
        lblBackgroundPrice.text = backgroundPrice
        
        backgroundBedroomCountLabel.text = "\(nextProperty.bedroomCount)"
        backgroundBathroomCountLabel.text = nextProperty.bathroomCount.isInteger ? "\(Int(nextProperty.bathroomCount))" : "\(nextProperty.bathroomCount)"
        
//        backgroundPetFriendlyImageview.image = nextProperty.petFriendly ? #imageLiteral(resourceName: "Paw") : #imageLiteral(resourceName: "NoPaw")
//        backgroundSmokingAllowedImageView.image = nextProperty.smokingAllowed ? #imageLiteral(resourceName: "SmokingAllowed") : #imageLiteral(resourceName: "NoSmokingAllowed")
        
//        updateStars(starImageViews: [backgroundStarImageView1, backgroundStarImageView2, backgroundStarImageView3, backgroundStarImageView4, backgroundStarImageView5], for: nextProperty.rentalHistoryRating)
    }
    
    override func swipableView(_ swipableView: RWKSwipeableView, didSwipeOn cardEntity: Any) {
        
        if FIRAuth.auth()?.currentUser == nil {
            AlertManager.alert(withTitle: "Not Logged In", withMessage: "Please sign in to use start swiping", dismissTitle: "OK", inViewController: self)
            return
        }
        
        guard let property = cardEntity as? Property, let propertyID = property.propertyID, let renterID = UserController.currentUserID else { return }
        PropertyController.addHasBeenViewedByRenterToPropertyInFirebase(propertyID: propertyID, renterID: renterID)
    }
    
    func swipableView(_ swipableView: RWKSwipeableView, didAccept cardEntity: Any) {
        if FIRAuth.auth()?.currentUser == nil {
            return
        }
        guard let renter = UserController.currentRenter, let property = cardEntity as? Property else { return }
        MatchController.addCurrentRenter(renter: renter, toLikelistOf: property)
    }
    
    func swipableView(_ swipableView: RWKSwipeableView, didReject cardEntity: Any) {
        if FIRAuth.auth()?.currentUser == nil {
            return
        }
        guard let property = cardEntity as? Property, let propertyID = property.propertyID, let renter = UserController.currentRenter, let renterID = renter.id else { return }
        RenterController.reject(propertyID: propertyID, forRenterID: renterID)
    }
    
    // MARK: segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.renterMatchesVC.rawValue {
            if let destinationVC = segue.destination as? RenterMatchesViewController, let renter = UserController.currentRenter {
                destinationVC.renter = renter
            }
        } else if segue.identifier == Identifiers.Segues.reportUserVC.rawValue {
            if let destinationVC = segue.destination as? ReportUserViewController, let property = currentCardProperty, let landlordID = property.landlordID {
                LandlordController.getLandlordWithID(landlordID: landlordID, completion: { (landlord) in
                    guard let landlord = landlord else { return }
                    destinationVC.userBeingReported = landlord
                    destinationVC.propertyBeingReported = property
                })
            }
        } else if segue.identifier == Identifiers.Segues.CardDetailVC.rawValue {
            if let destinationVC = segue.destination as? RenterDetailCardViewController, let property = currentCardProperty {
                destinationVC.property = property
            }
        } else if segue.identifier == Identifiers.Segues.filterVC.rawValue {
            if let destinationVC = segue.destination as? RenterFilterSettingsViewController {
                destinationVC.modalViewDelegate = self
            }
        }
    }
    
    // MARK: helper methods
    
    internal func viewDismissed() {
        if SettingsViewController.settingsDidChange {
            SettingsViewController.settingsDidChange = false
            self.updateCardUI()
        }
    }
    
    func downloadMoreCards() {
        if !FirebaseController.isFetchingNewProperties {
            if super.previousVCWasCardsLoadingVC {
                super.previousVCWasCardsLoadingVC = false
            } else if UserController.propertyFetchCount == 1 { // if fetch count is one here then the last card in the database has already been pulled
//                performSegue(withIdentifier: Identifiers.Segues.MoreCardsVC.rawValue, sender: self)
                vwNoMoreCards.isHidden = false
                return
            }
            FirebaseController.isFetchingNewProperties = true
            cardsAreLoading = true
            PropertyController.fetchProperties(numberOfProperties: FirebaseController.cardDownloadCount, completion: {
                FirebaseController.isFetchingNewProperties = false
                self.cardsAreLoading = false
                
                let newFilteredProperties = self.getFilteredProperties()
                let uniqueProperties = newFilteredProperties.filter({ !self.filteredProperties.contains($0) })
                if uniqueProperties.count > 0 {
                    self.filteredProperties.append(contentsOf: uniqueProperties)
                }
                if newFilteredProperties.count == 0 && UserController.propertyFetchCount > 1 {
                    self.downloadMoreCards()
//                    return
                } else {
                    self.updateCardUI()
                }
            })
        }
    }
    
    func getFilteredProperties() -> [Property] {
//        let filterSettingsDict = UserController.getRenterFiltersDictionary()
//        
//        guard let desiredBathroomCount = filterSettingsDict[filterKeys.kBathroomCount.rawValue] as? Double,
//            let desiredBedroomCount = filterSettingsDict[filterKeys.kBedroomCount.rawValue] as? Int64,
//            let desiredPayment = filterSettingsDict[filterKeys.kMonthlyPayment.rawValue] as? Int64,
//            let desiredPetsAllowed = filterSettingsDict[filterKeys.kPetsAllowed.rawValue] as? Bool,
//            let desiredSmokingAllowed = filterSettingsDict[filterKeys.kSmokingAllowed.rawValue] as? Bool,
////            let desiredPropertyFeatures = filterSettingsDict[filterKeys.kPropertyFeatures.rawValue] as? String,
//            let desiredZipcode = filterSettingsDict[filterKeys.kZipCode.rawValue] as? String else {
//                return [Property]()
//        }
//        
//        let filtered = FirebaseController.properties.filter({ $0.bathroomCount == desiredBathroomCount && $0.bedroomCount == desiredBedroomCount && $0.monthlyPayment <= desiredPayment && $0.petFriendly == desiredPetsAllowed && $0.smokingAllowed == desiredSmokingAllowed && $0.zipCode == desiredZipcode})
        
        let filtered = FirebaseController.properties
        if FirebaseController.properties.count > 0 {
            FirebaseController.properties.removeAll()
        }
        
        return filtered
    }
    
    private func getFeaturesArray(forProperty property: Property) -> [String] {
        
        var collectionViewItems: [String] = []
        
        if property.petFriendly {
            collectionViewItems.append("Pets")
        }
        
        if property.smokingAllowed {
            collectionViewItems.append("Smoking")
        }
        
        if property.washerDryer {
            collectionViewItems.append("Washer/Dryer")
        }
        
        if property.dishwasher {
            collectionViewItems.append("Dishwasher")
        }
        
        if property.gym {
            collectionViewItems.append("Gym")
        }
        
        if property.backyard {
            collectionViewItems.append("Backyard")
        }
        
        if property.airConditioning {
            collectionViewItems.append("Air Conditioning")
        }
        
        if property.garage {
            collectionViewItems.append("Garage")
        }
        
        if property.heating {
            collectionViewItems.append("Heating")
        }
        
        if property.kitchen {
            collectionViewItems.append("Kitchen")
        }
        
        if property.livingRoom {
            collectionViewItems.append("Living Room")
        }
        
        if property.pool {
            collectionViewItems.append("Pool")
        }
        
        if property.storage {
            collectionViewItems.append("Storage")
        }
        
        if property.wifi {
            collectionViewItems.append("Wifi")
        }
        
        return collectionViewItems
    }
}

extension RenterMainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.frontCardPropertyFeaturesCollectionViewItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "propertyFeatureCell", for: indexPath as IndexPath) as! TagCollectionViewCell
        
        cell.tagLabel.text = self.frontCardPropertyFeaturesCollectionViewItems[indexPath.item]
        cell.tagLabel.sizeToFit()
        cell.backgroundColor = UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)
        cell.layer.cornerRadius = 3
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize{
        let tagString = frontCardPropertyFeaturesCollectionViewItems[indexPath.item]
        let cellSize: CGSize = tagString.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18.0)])
        return cellSize
    }

}
