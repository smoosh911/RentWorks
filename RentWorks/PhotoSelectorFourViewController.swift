//
//  PhotoSelectorFourViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/18/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorFourViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Actions
    
    @IBOutlet var selectPhotoButton: UIButton!
    @IBOutlet var selectedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedImageView.clipsToBounds = true
        selectedImageView.layer.cornerRadius = 10
        self.view.layer.cornerRadius = 10
    }
        
    @IBAction func selectPhotoButtonTapped(_ sender: AnyObject) {
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
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                
                self.selectPhotoButton?.setTitle("", for: UIControlState())
                self.selectedImageView?.image = image
                UserController.userCreationPhotos.append(image)
            }
        }
    }
}
