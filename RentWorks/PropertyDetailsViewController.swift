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

enum PropertyTask {
    case adding
    case editing
}

protocol PropertyDetailsContainerDelegate: class {
    func settingsUpdated()
}

class PropertyDetailsViewController: UIViewController, UpdatePropertySettingsDelegate {
    
    // MARK: outlets
    @IBOutlet weak var lblPropertySaveResult: UILabel!
    @IBOutlet weak var clctvwPropertyImages: UICollectionView!
    @IBOutlet weak var actIndCollectionView: UIActivityIndicatorView!
    
    var propertyDetailSettingsContainerTVC: PropertyDetailSettingsContainerTableViewController?
    
    // MARK: variables
    
    var propertyDetailsContainerDelegate: PropertyDetailsContainerDelegate?
    
    var selectedCellIndexPaths: [IndexPath] = []
    
    var property: Property? = nil
    var landlord: Landlord! = UserController.currentLandlord
    
    var propertyImages: [ProfileImage] = []
    
    var propertyTask = PropertyTask.editing
    
    var didSaveDetails = false
    
    enum SaveResults: String {
        case success = "Property Saved!"
        case failure = "Property Couldn't Save"
    }
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if propertyTask == PropertyTask.adding {
            guard let landlordID = UserController.currentUserID else { return }
            property = Property(landlordID: landlordID, landlord: landlord)
        }
        
        guard let property = property, let profileImages = property.profileImages?.array as? [ProfileImage] else { return }
        propertyImages = profileImages
        
        self.hideKeyboardWhenViewIsTapped()
        
        self.actIndCollectionView.layer.cornerRadius = self.actIndCollectionView.bounds.height / 4
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // buttons
    
    
    @IBAction func btnSubmitChanges_TouchedUpInside(_ sender: UIButton) {
        guard let delegate = propertyDetailsContainerDelegate else { return }
        delegate.settingsUpdated()
    }
    
    @IBAction func backNavigationButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: {
            
        })
    }

    // needs work: shouldn't add images till property has been saved in firebase
    @IBAction func btnDeletePictures_TouchedUpInside(_ sender: UIButton) {
        print("should delete \(selectedCellIndexPaths)")
        
        let imagesAtIndexPaths = selectedCellIndexPaths.flatMap({ propertyImages[$0.row] })
        propertyImages = propertyImages.filter({ !imagesAtIndexPaths.contains($0) })
        for i in 0 ..< imagesAtIndexPaths.count {
            let propertyImage = imagesAtIndexPaths[i]
            guard let imageURL = propertyImage.imageURL, let property = property, let propertyID = property.propertyID else { return }
            let profileImageRef = FIRStorage.storage().reference(forURL: imageURL)
            
            let context: NSManagedObjectContext = CoreDataStack.context
            context.delete(propertyImage)
            
            if i == (imagesAtIndexPaths.count - 1) {
                let newimageURLs = propertyImages.map({$0.imageURL!})
                PropertyController.deletePropertyImageURLsInFirebase(id: propertyID)
                PropertyController.updateCurrentPropertyInFirebase(id: propertyID, attributeToUpdate: UserController.kImageURLS, newValue: newimageURLs)
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
        
    // delegate save changes
    }
    
    func updatePropertySettingsWith(saveResult: String) {
        
        self.lblPropertySaveResult.text = saveResult
        self.lblPropertySaveResult.isHidden = false
    }
    
    // MARK: gestures
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
                
                self.view.endEditing(true)
                
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    // MARK: keyboard functions
    
    // needs work: content should be put in a scroll view and when you click on something it should activate the scroll view
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.propertyDetailContainterVC.rawValue {
            guard let property = property, let propertyDetailSettingsContainerTVC = segue.destination as? PropertyDetailSettingsContainerTableViewController else { return }
            propertyDetailsContainerDelegate = propertyDetailSettingsContainerTVC
            propertyDetailSettingsContainerTVC.parentVC = self
            propertyDetailSettingsContainerTVC.property = property
        }
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
        
        if selectedCellIndexPaths.contains(indexPath) {
            cell.layer.borderWidth = 5
            cell.layer.borderColor = UIColor.purple.cgColor
        } else {
            cell.layer.borderWidth = 0
        }
        
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
        if propertyTask == .adding {
            
        }
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
        self.actIndCollectionView.startAnimating()
        picker.dismiss(animated: true) {
            guard let property = self.property, let propertyID = property.propertyID, let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                return
            }
            PropertyController.savePropertyImagesToCoreDataAndFirebase(images: [image], landlord: self.landlord, forProperty: property, completion: { imageURL in
                log("image uploaded to \(imageURL)")
                guard let profileImageArray = property.profileImages?.array, let profileImages = profileImageArray as? [ProfileImage] else { return }
                let imageURLs = profileImages.map({$0.imageURL!})
                // needs work: update so you don't have to delete every time
                PropertyController.deletePropertyImageURLsInFirebase(id: propertyID)
                PropertyController.updateCurrentPropertyInFirebase(id: propertyID, attributeToUpdate: UserController.kImageURLS, newValue: imageURLs)
                self.propertyImages = profileImages
                self.clctvwPropertyImages.reloadData()
                self.actIndCollectionView.stopAnimating()
                // delegate submit changes?
                
//                self.updateSettingsChanged()
            })
//            UserController.userCreationPhotos.append(image) // I don't know what this was for so I'll leave it in case of errors
        }
    }
}
