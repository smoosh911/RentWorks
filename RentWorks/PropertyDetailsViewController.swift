//
//  PropertyDetailsViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class PropertyDetailsViewController: UIViewController {
    
    // MARK: outlets
    
    @IBOutlet weak var btnMessages: UIButton!
    
    @IBOutlet weak var txtfldPropertyAddress: UITextField!
    @IBOutlet weak var txtfldDateAvailable: UITextField!
    
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var sldRent: UISlider!
    
    @IBOutlet weak var stpBedrooms: UIStepper!
    @IBOutlet weak var lblBedroomCount: UILabel!
    
    @IBOutlet weak var stpBathrooms: UIStepper!
    @IBOutlet weak var lblBathroomCount: UILabel!
    
    @IBOutlet weak var swtPets: UISwitch!
    @IBOutlet weak var swtSmoking: UISwitch!
    
//    @IBOutlet weak var txtfldFeatures: UITextField!
    @IBOutlet weak var txtfldZipCode: UITextField!
    
    @IBOutlet weak var clctvwPropertyImages: UICollectionView!
    
    @IBOutlet weak var starImageView1: UIImageView!
    @IBOutlet weak var starImageView2: UIImageView!
    @IBOutlet weak var starImageView3: UIImageView!
    @IBOutlet weak var starImageView4: UIImageView!
    @IBOutlet weak var starImageView5: UIImageView!
    
    // MARK: variables
    
    var property: Property! = nil
    var landlord: Landlord! = UserController.currentLandlord
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let propertyDetailKeys = UserController.PropertyDetailValues.self
        let propertyDetailsDict = UserController.getPropertyDetailsDictionary(property: property)
        
        for detail in propertyDetailsDict {
            switch detail.key {
            case propertyDetailKeys.kAddress.rawValue:
                let address = detail.value as! String
                txtfldPropertyAddress.text = address
                break
            case propertyDetailKeys.kAvailableDate.rawValue:
                let availableDate = detail.value as! Double
                txtfldDateAvailable.text = "\(availableDate)"
                break
            case propertyDetailKeys.kBedroomCount.rawValue:
                let bedroomCount = detail.value as! Int
                stpBedrooms.value = Double(bedroomCount)
                lblBedroomCount.text = "\(stpBedrooms.value)"
                break
            case propertyDetailKeys.kBathroomCount.rawValue:
                let bathroomCount = detail.value as! Double
                stpBathrooms.value = bathroomCount
                lblBathroomCount.text = "\(stpBathrooms.value)"
                break
            case propertyDetailKeys.kMonthlyPayment.rawValue:
                sldRent.value = Float(detail.value as! Int)
                let price = "\(Int(sldRent.value))"
                lblPrice.text = price
                break
            case propertyDetailKeys.kPetsAllowed.rawValue:
                let petsAllowed = detail.value as! Bool
                swtPets.isOn = petsAllowed
                break
//            case propertyDetailKeys.kPropertyFeatures.rawValue:
//                let features = detail.value as! String
//                txtfldFeatures.text = features
//                break
            case propertyDetailKeys.kSmokingAllowed.rawValue:
                let smokingAllowed = detail.value as! Bool
                swtSmoking.isOn = smokingAllowed
                break
            case propertyDetailKeys.kStarRating.rawValue:
                let rating = detail.value as! Double
                updateStars(starImageViews: [starImageView1, starImageView2, starImageView3, starImageView4, starImageView5], for: rating)
                break
            case propertyDetailKeys.kZipCode.rawValue:
                let zipcode = detail.value as! String
                txtfldZipCode.text = zipcode
                break
            default:
                log("no details")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setMatchesButtonImage()
    }

    // MARK: actions

    // slider

    @IBAction func sldRent_ValueChanged(_ sender: UISlider) {
        let price = "\(Int(sender.value))"
        lblPrice.text = price
    }

    @IBAction func sldRent_TouchedUpInsideAndOutside(_ sender: UISlider) {
        let price = Int(sender.value)
        guard let id = property.propertyID else { return }
//        let priceString = "\(Int(sender.value))"
        property.monthlyPayment = Int64(sender.value)
        UserController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kMonthlyPayment, newValue: price)
        // UserController.saveToPersistentStore()
    }
    
    // steppers
    
    @IBAction func stpBedrooms_ValueChanged(_ sender: UIStepper) {
        let bedroomCount = Int64(sender.value)
        guard let id = property.propertyID else { return }
        
        let countString = "\(bedroomCount)"
        lblBedroomCount.text = countString
        property.bedroomCount = bedroomCount
        UserController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kBedroomCount, newValue: bedroomCount)
        // UserController.saveToPersistentStore()
    }
    
    @IBAction func stpBathrooms_ValueChanged(_ sender: UIStepper) {
        let bathroomCount = sender.value
        guard let id = property.propertyID else { return }
        let countString = "\(bathroomCount)"
        lblBathroomCount.text = countString
        property.bathroomCount = bathroomCount
        UserController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kBathroomCount, newValue: bathroomCount)
        // UserController.saveToPersistentStore()
    }
    
    // switches
    
    @IBAction func swtPet_ValueChanged(_ sender: UISwitch) {
        let petsAllowed = sender.isOn
        guard let id = property.propertyID else { return }
        
//        let boolString = "\(petsAllowed)"
        property.petFriendly = petsAllowed
        UserController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kPetsAllowed, newValue: petsAllowed)
        // UserController.saveToPersistentStore()
    }
    
    @IBAction func swtSmoking_ValueChanged(_ sender: UISwitch) {
        let smokingAllowed = sender.isOn
        guard let id = property.propertyID else { return }
        
//        let boolString = "\(smokingAllowed)"
        property.smokingAllowed = smokingAllowed
        UserController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kSmokingAllowed, newValue: smokingAllowed)
        // UserController.saveToPersistentStore()
    }
    
    // buttons
    
    @IBAction func btnSubmitChanges_TouchedUpInside(_ sender: UIButton) {
        guard let id = property.propertyID else { return }
        
        // needs work: add property features
//        let propertyFeatures = txtfldFeatures.text!
        let zipcode = txtfldZipCode.text!
        
//        property.wantedPropertyFeatures = propertyFeatures
        property.zipCode = zipcode
//        UserController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kPropertyFeatures, newValue: propertyFeatures)
        UserController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kZipCode, newValue: zipcode)
        // UserController.saveToPersistentStore()
    }
    
    // MARK: helper methods
    
    func setMatchesButtonImage() {
        DispatchQueue.main.async {
            MatchController.currentUserHasNewMatches ? self.btnMessages.setImage(#imageLiteral(resourceName: "ChatBubbleFilled"), for: .normal) : self.btnMessages.setImage(#imageLiteral(resourceName: "ChatBubble"), for: .normal)
        }
    }
    
    @IBAction func backNavigationButtonTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func updateStars(starImageViews: [UIImageView], for rating: Double) {
        
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

}

extension PropertyDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return property.profileImages!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.CollectionViewCells.PropertyImageCell.rawValue, for: indexPath) as! PropertyImageCollectionViewCell
        
        guard let profileImage = property.profileImages?[indexPath.row] as? ProfileImage, let image = UIImage(data: profileImage.imageData as! Data) else { return cell }
        
        cell.imgProperty.image = image
        
        return cell
    }
}
