//
//  LandlordAddPhotosViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordAddPhotosViewController: UIViewController, PhotoSelectedDelegate {

    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserController.photoSelectedDelegate = self
        nextButton.isHidden = true
    }
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        if UserController.userCreationPhotos.count > 0 {
            self.performSegue(withIdentifier: "toPropertyAvailableVC", sender: nil)
        } else {
            presentAddPhotoAlert()
        }
    }
    
    func photoWasSelected() {
        nextButton.slideFromRight()
    }
    
    func presentAddPhotoAlert() {
        let alert = UIAlertController(title: "Hold on a second!", message: "Please add at least one photo of your property!", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(dismissAction)
        alert.view.tintColor = AppearanceController.customOrangeColor
        self.present(alert, animated: true, completion: nil)

    }
}
