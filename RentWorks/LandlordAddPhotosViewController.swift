//
//  LandlordAddPhotosViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordAddPhotosViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func nextButtonTapped(_ sender: AnyObject) {
        if UserController.userCreationPhotos.count > 0 {
            self.performSegue(withIdentifier: "toPropertyAvailableVC", sender: nil)
        } else {
            presentAddPhotoAlert()
        }
    }
    
    
    func presentAddPhotoAlert() {
        let alert = UIAlertController(title: "Hold on a second!", message: "Please add at least one photo of your property!", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        alert.addAction(dismissAction)
        alert.view.tintColor = AppearanceController.customOrangeColor
        self.present(alert, animated: true, completion: nil)

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
