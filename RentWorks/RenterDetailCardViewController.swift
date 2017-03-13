//
//  RenterDetailCardViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 12/29/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import ImageSlideshow

class RenterDetailCardViewController: DetailCardViewController {
    
    // MARK: outlets
    
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblBed: UILabel!
    @IBOutlet weak var lblBath: UILabel!
    @IBOutlet weak var lblCityState: UILabel!
    @IBOutlet weak var lblDateAvailable: UILabel!
    
    // MARK: variables
    
    var property: Property?
    
    var propertyFeaturesCollectionViewItems: [String] = []
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getExtraProfileImages()
        updateUI()
        
        guard let property = self.property else {
            return
        }
        propertyFeaturesCollectionViewItems = getFeaturesArray(forProperty: property)
    }
    
    // MARK: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.cardDetailContainerVC.rawValue {
            if let destinationVC = segue.destination as? RenterCardDetailsContainerViewController, let property = property {
                destinationVC.property = property
            }
        } else if segue.identifier == Identifiers.Segues.reportUserVC.rawValue {
            if let destinationVC = segue.destination as? ReportUserViewController, let property = self.property, let landlordID = property.landlordID {
                LandlordController.getLandlordWithID(landlordID: landlordID, completion: { (landlord) in
                    guard let landlord = landlord else { return }
                    destinationVC.userBeingReported = landlord
                    destinationVC.propertyBeingReported = property
                })
            }
        }
    }
    
    // MARK: helper functions
    
    private func updateUI() {
        guard let property = property else { return }
        
        lblAddress.text = property.address
        lblPrice.text = "$\(property.monthlyPayment)"
        
        lblBed.text = "\(property.bedroomCount) Bed"
        lblBath.text = "\(property.bathroomCount) Bath"
        lblCityState.text = "\(property.city!), \(property.state!)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        lblDateAvailable.text = "Available \(dateFormatter.string(from: property.availableDate! as Date))"
        
        guard let profileImages = property.profileImages else {
            log("no profile images to view")
            return
        }
        
        var profilePicImageSources: [ImageSource] = []
        for profileImage in profileImages {
            if let firstProfileImage = profileImage as? ProfileImage, let imageData = firstProfileImage.imageData, let profilePic = UIImage(data: imageData as Data) {
                let imageSource = ImageSource(image: profilePic)
                profilePicImageSources.append(imageSource)
            } else {
                log("ERROR: couldn't load a profile image")
            }
        }
        
        imgSlideShow.setImageInputs(profilePicImageSources)
        imgSlideShow.contentScaleMode = .scaleAspectFill
    }
    
    private func getExtraProfileImages() {
        guard let property = property, let propertyID = property.propertyID else {
            log("ERROR: couldn't get renter ID")
            return
        }
        PropertyController.fetchAllPropertyImagesFromFirebase(forPropertyID: propertyID) { (property) in
            if property != nil {
                self.property = property
                self.updateUI()
            }
        }
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

extension RenterDetailCardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.propertyFeaturesCollectionViewItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "propertyFeatureCell", for: indexPath as IndexPath) as! TagCollectionViewCell
        
        cell.tagLabel.text = self.propertyFeaturesCollectionViewItems[indexPath.item]
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
        let tagString = propertyFeaturesCollectionViewItems[indexPath.item]
        let cellSize: CGSize = tagString.size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18.0)])
        return cellSize
    }
    
}
