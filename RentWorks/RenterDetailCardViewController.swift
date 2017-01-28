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
    
    // MARK: variables
    
    var property: Property?
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getExtraProfileImages()
        updateUI()
    }
    
    // MARK: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.cardDetailContainerVC.rawValue {
            if let destinationVC = segue.destination as? RenterCardDetailsContainerViewController, let property = property {
                destinationVC.property = property
            }
        }
    }
    
    // MARK: helper functions
    
    private func updateUI() {
        guard let property = property else { return }
        
        let starViews: [UIImageView] = [super.starImageView1, super.starImageView2, super.starImageView3, super.starImageView4, super.starImageView5]
        
        super.updateStars(starImageViews: starViews, for: property.rentalHistoryRating)
        
        lblAddress.text = property.address
        lblPrice.text = "$\(property.monthlyPayment)"
        
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
}
