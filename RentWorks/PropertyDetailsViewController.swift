//
//  PropertyDetailsViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import CoreData
import Photos
import FirebaseStorage

class PropertyDetailsViewController: UIViewController {
    
    // MARK: outlets
    
    @IBOutlet weak var lblPropertySaveResult: UILabel!
    
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
    
    var propertyImages: [ProfileImage] = []
    
    var propertyTask: PropertyTask = PropertyTask.editing
    
    var selectedCellIndexPaths: [IndexPath] = []
    
    enum SaveResults: String {
        case success = "Property Saved!"
        case failure = "Property Couldn't Save"
    }
        
    enum PropertyTask {
        case adding
        case editing
    }
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if propertyTask == PropertyTask.adding {
//            property = NSEntityDescription.insertNewObject(forEntityName: "Property", into: CoreDataStack.context) as! Property
            guard let landlordID = UserController.currentUserID else { return }
            property = Property(landlordID: landlordID, landlord: landlord)
        }
        
        guard let property = property, let profileImages = property.profileImages?.array as? [ProfileImage] else { return }
        propertyImages = profileImages
        
        let propertyDetailsDict = UserController.getPropertyDetailsDictionary(property: property)
        updatePropertyDetails(propertyDetailsDict: propertyDetailsDict)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        self.updateSettingsChanged()
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
        self.updateSettingsChanged()
    }
    
    @IBAction func stpBathrooms_ValueChanged(_ sender: UIStepper) {
        let bathroomCount = sender.value
        guard let id = property.propertyID else { return }
        let countString = "\(bathroomCount)"
        lblBathroomCount.text = countString
        property.bathroomCount = bathroomCount
        UserController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kBathroomCount, newValue: bathroomCount)
        // UserController.saveToPersistentStore()
        self.updateSettingsChanged()
    }
    
    // switches
    
    @IBAction func swtPet_ValueChanged(_ sender: UISwitch) {
        let petsAllowed = sender.isOn
        guard let id = property.propertyID else { return }
        
//        let boolString = "\(petsAllowed)"
        property.petFriendly = petsAllowed
        UserController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kPetsAllowed, newValue: petsAllowed)
        // UserController.saveToPersistentStore()
        self.updateSettingsChanged()
    }
    
    @IBAction func swtSmoking_ValueChanged(_ sender: UISwitch) {
        let smokingAllowed = sender.isOn
        guard let id = property.propertyID else { return }
        
//        let boolString = "\(smokingAllowed)"
        property.smokingAllowed = smokingAllowed
        UserController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kSmokingAllowed, newValue: smokingAllowed)
        // UserController.saveToPersistentStore()
        self.updateSettingsChanged()
    }
    
    // buttons
    
    @IBAction func btnSubmitChanges_TouchedUpInside(_ sender: UIButton) {
        guard let id = property.propertyID, let address = txtfldPropertyAddress.text, let zipcode = txtfldZipCode.text else { return }
        property.address = address
        property.zipCode = zipcode
        if propertyTask == PropertyTask.editing {
            // needs work: add property features
            //        let propertyFeatures = txtfldFeatures.text!
//            let zipcode = txtfldZipCode.text!
            
            //        property.wantedPropertyFeatures = propertyFeatures
//            property.zipCode = zipcode
            //        UserController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kPropertyFeatures, newValue: propertyFeatures)
            UserController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kZipCode, newValue: zipcode)
            UserController.updateCurrentPropertyInFirebase(id: id, attributeToUpdate: UserController.kAddress, newValue: address)
            self.lblPropertySaveResult.text = SaveResults.success.rawValue
            self.lblPropertySaveResult.isHidden = false
            // UserController.saveToPersistentStore()
        } else {
            UserController.createPropertyInFirebase(property: property, completion: { success in
                self.lblPropertySaveResult.text = success ? SaveResults.success.rawValue : SaveResults.failure.rawValue
                self.lblPropertySaveResult.isHidden = false
                FirebaseController.properties.append(self.property)
                self.propertyTask = PropertyTask.editing
            })
        }
        self.updateSettingsChanged()
    }
    
    @IBAction func btnDeletePictures_TouchedUpInside(_ sender: UIButton) {
        print("should delete \(selectedCellIndexPaths)")
        
        let imagesAtIndexPaths = selectedCellIndexPaths.flatMap({ propertyImages[$0.row] })
        propertyImages = propertyImages.filter({ !imagesAtIndexPaths.contains($0) })
        for i in 0 ..< imagesAtIndexPaths.count {
            let propertyImage = imagesAtIndexPaths[i]
            guard let imageURL = propertyImage.imageURL, let propertyID = property.propertyID else { return }
            let profileImageRef = FIRStorage.storage().reference(forURL: imageURL)
            
            let context: NSManagedObjectContext = CoreDataStack.context
            context.delete(propertyImage)
            
            if i == (imagesAtIndexPaths.count - 1) {
                let newimageURLs = propertyImages.map({$0.imageURL!})
                UserController.deletePropertyImageURLsInFirebase(id: propertyID)
                UserController.updateCurrentPropertyInFirebase(id: propertyID, attributeToUpdate: UserController.kImageURLS, newValue: newimageURLs)
            }
            
            profileImageRef.delete(completion: { (error) in
                if (error != nil) {
                    log("ERROR: Couldn't delete image. \(error)")
                }
            })
        }
        
        clctvwPropertyImages.deleteItems(at: selectedCellIndexPaths)
        selectedCellIndexPaths = []
        log("succesfully deleted images \(selectedCellIndexPaths)")
        self.updateSettingsChanged()
    }
    
    // MARK: helper methods
    
    @IBAction func backNavigationButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {
            
        })
    }
    
    private func updatePropertyDetails (propertyDetailsDict: [String: Any]) {
        let propertyDetailKeys = UserController.PropertyDetailValues.self
        
        for detail in propertyDetailsDict {
            switch detail.key {
            case propertyDetailKeys.kAddress.rawValue:
                let address = detail.value as! String
                txtfldPropertyAddress.text = address
                break
            case propertyDetailKeys.kAvailableDate.rawValue:
                guard let timeInterval = detail.value as? TimeInterval else { break }
                let availableDate = Date(timeIntervalSince1970: timeInterval)
                
                txtfldDateAvailable.text = "\(availableDate.description)"
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
    
    internal func updateSettingsChanged() {
        SettingsViewController.settingsDidChange = true
        UserController.renterFetchCount = 0
        UserController.resetStartAtForAllPropertiesInFirebase()
    }
}

// MARK: collection view

extension PropertyDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return propertyImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.CollectionViewCells.PropertyImageCell.rawValue, for: indexPath) as! PropertyImageCollectionViewCell
        let profileImage = propertyImages[indexPath.row]
        
        guard let image = UIImage(data: profileImage.imageData as! Data) else { return cell }
        
        cell.imgProperty.image = image
        cell.indexPath = indexPath
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PropertyImageCollectionViewCell
        if selectedCellIndexPaths.contains(indexPath) {
            cell.layer.borderWidth = 0
            selectedCellIndexPaths = selectedCellIndexPaths.filter({$0 != indexPath})
            print(selectedCellIndexPaths)
        } else {
            cell.layer.borderWidth = 5
            cell.layer.borderColor = UIColor.purple.cgColor
            selectedCellIndexPaths.append(indexPath)
            print(selectedCellIndexPaths)
        }
    }
}

// MARK: add images

extension PropertyDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        checkPhotoLibraryPermission { (success) in
            if success {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                
                let alert = UIAlertController(title: "Select Photo Location", message: nil, preferredStyle: .actionSheet)
                alert.view.tintColor = .black
                
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) -> Void in
                        imagePicker.sourceType = .photoLibrary
                        DispatchQueue.main.async {
                            self.present(imagePicker, animated: true, completion: nil)
                        }
                    }))
                }
                
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (_) -> Void in
                        imagePicker.sourceType = .camera
                        DispatchQueue.main.async {
                            self.present(imagePicker, animated: true, completion: nil)
                        }
                    }))
                }
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            completion(true)
        case .denied:
            completion(false)
        case .restricted :
            completion(false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization() { status in
                switch status {
                case .authorized:
                    completion(true)
                case .denied, .restricted:
                    completion(false)
                default:
                    completion(false)
                    break
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            guard let propertyID = self.property.propertyID, let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            UserController.savePropertyImagesToCoreDataAndFirebase(images: [image], landlord: self.landlord, forProperty: self.property, completion: { imageURL in
                log("image uploaded to \(imageURL)")
                guard let profileImageArray = self.property.profileImages?.array, let profileImages = profileImageArray as? [ProfileImage] else { return }
                let imageURLs = profileImages.map({$0.imageURL!})
                // needs work: update so you don't have to delete every time
                UserController.deletePropertyImageURLsInFirebase(id: propertyID)
                UserController.updateCurrentPropertyInFirebase(id: propertyID, attributeToUpdate: UserController.kImageURLS, newValue: imageURLs)
                self.propertyImages = profileImages
                self.clctvwPropertyImages.reloadData()
                self.updateSettingsChanged()
            })
//            UserController.userCreationPhotos.append(image) // I don't know what this was for so I'll leave it in case of errors
        }
    }
}
