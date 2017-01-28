//
//  LandlordDetailCardViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 12/31/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import ImageSlideshow

class LandlordCardDetailViewController: DetailCardViewController {
    
    // MARK: outlets
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCreditRating: UILabel!
    @IBOutlet weak var lblOccupation: UILabel!
    
    // MARK: variables
    
    var renter: Renter?
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getExtraProfileImages()
        updateUI()
    }
    
    // MARK: segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.cardDetailContainerVC.rawValue {
            if let destinationVC = segue.destination as? LandlordCardDetailContainterViewController, let renter = renter {
                destinationVC.renter = renter
            }
        }
    }
    
    // MARK: helper functions
    
    private func updateUI() {
        guard let renter = renter, let firstName = renter.firstName, let lastName = renter.lastName else { return }
        
        let starViews: [UIImageView] = [super.starImageView1, super.starImageView2, super.starImageView3, super.starImageView4, super.starImageView5]
        
        super.updateStars(starImageViews: starViews, for: renter.starRating)
        
        lblName.text = "\(firstName) \(lastName)"
        lblCreditRating.text = renter.creditRating
        lblOccupation.text = renter.currentOccupation
        
        guard let profileImages = renter.profileImages else {
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
        guard let renter = renter, let renterID = renter.id else {
            log("ERROR: couldn't get renter ID")
            return
        }
        RenterController.fetchRenterFromFirebaseFor(renterID: renterID) { (renter) in
            if renter != nil {
                self.renter = renter
                self.updateUI()
            }
        }
    }
}
