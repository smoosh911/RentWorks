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
    
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }
    
    func setupViews() {
        self.selectPhotoButton = UIButton(frame: self.view.frame)
        self.selectedImageView = UIImageView(frame: self.view.frame )
        guard let selectPhotoButton = self.selectPhotoButton, let selectedImageView = selectedImageView else { return }
        selectPhotoButton.setTitle("Add Photo", for: .normal)
        selectPhotoButton.tintColor = .white
        selectPhotoButton.addTarget(self, action: #selector(selectPhotoButtonTapped), for: .touchUpInside)
        
        selectedImageView.contentMode = .scaleAspectFill
        selectedImageView.clipsToBounds = true
        
        self.view.addSubview(selectedImageView)
        self.view.addSubview(selectPhotoButton)
        self.view.bringSubview(toFront: selectPhotoButton)
        
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
    
    func selectPhotoButtonTapped() {
        
        
        checkPhotoLibraryPermission { (success) in
            if success {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                
                let alert = UIAlertController(title: "Select Photo Location", message: nil, preferredStyle: .actionSheet)
                
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
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            selectPhotoButton?.setTitle("", for: UIControlState())
            selectedImageView?.image = image
            UserController.userCreationPhotos.append(image)
        }
    }
}
