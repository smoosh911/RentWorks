//
//  LandlordPropertyFeaturesViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordPropertyFeaturesViewController: UIViewController {

    var features = [String]()
    
    let buttonPressedColor = AppearanceController.buttonPressedColor
    
    @IBOutlet weak var laundryButton: UIButton!
    @IBOutlet weak var garageButton: UIButton!
    @IBOutlet weak var poolButton: UIButton!
    @IBOutlet weak var gymButton: UIButton!
    @IBOutlet weak var dishwasherButton: UIButton!
    @IBOutlet weak var backyardButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AccountCreationController.addNextVCToLandlordPageVCDataSource(landlordVC: self)
        
        nextButton.isHidden = true
        
        nextButton.slideFromRight()
        
        laundryButton.layer.cornerRadius = 15
        garageButton.layer.cornerRadius = 15
        poolButton.layer.cornerRadius = 15
        gymButton.layer.cornerRadius = 15
        dishwasherButton.layer.cornerRadius = 15
        backyardButton.layer.cornerRadius = 15
    }

    override func viewWillDisappear(_ animated: Bool) {
        saveWantedFeaturesToAccountCreationDictionary()
    }
    
    @IBAction func laundryButtonTapped(_ sender: AnyObject) {
        let laundry = UserController.PropertyFeatures.laundry.rawValue
        if features.contains(laundry), let index = features.index(of: laundry) {
            features.remove(at: index)
            laundryButton.setTitleColor(.white, for: .normal)
            laundryButton.backgroundColor = AppearanceController.customOrangeColor
        } else {
            features.append(laundry)
            laundryButton.setTitleColor(buttonPressedColor, for: .normal)
            laundryButton.backgroundColor = AppearanceController.viewButtonPressedColor
            
        }
    }
    
    @IBAction func garageButtonTapped(_ sender: AnyObject) {
        let garage = UserController.PropertyFeatures.garage.rawValue
        if features.contains(garage), let index = features.index(of: garage) {
            features.remove(at: index)
            garageButton.setTitleColor(.white, for: .normal)
            garageButton.backgroundColor = AppearanceController.customOrangeColor
        } else {
            features.append(garage)
            garageButton.setTitleColor(buttonPressedColor, for: .normal)
            garageButton.backgroundColor = AppearanceController.viewButtonPressedColor
        }
    }
    
    @IBAction func poolButtonTapped(_ sender: AnyObject) {
        let pool = UserController.PropertyFeatures.pool.rawValue
        if features.contains(pool), let index = features.index(of: pool) {
            features.remove(at: index)
            poolButton.setTitleColor(.white, for: .normal)
            poolButton.backgroundColor = AppearanceController.customOrangeColor
        } else {
            features.append(pool)
            poolButton.setTitleColor(buttonPressedColor, for: .normal)
            poolButton.backgroundColor = AppearanceController.viewButtonPressedColor
        }
    }
    
    @IBAction func gymButtonTapped(_ sender: AnyObject) {
        let gym = UserController.PropertyFeatures.gym.rawValue
        if features.contains(gym), let index = features.index(of: gym) {
            features.remove(at: index)
            gymButton.setTitleColor(.white, for: .normal)
            gymButton.backgroundColor = AppearanceController.customOrangeColor
        } else {
            features.append(gym)
            gymButton.setTitleColor(buttonPressedColor, for: .normal)
            gymButton.backgroundColor = AppearanceController.viewButtonPressedColor
        }
    }
    
    @IBAction func dishwasherButtonTapped(_ sender: AnyObject) {
        let dishwasher = UserController.PropertyFeatures.dishwasher.rawValue
        if features.contains(dishwasher), let index = features.index(of: dishwasher) {
            features.remove(at: index)
            dishwasherButton.setTitleColor(.white, for: .normal)
            dishwasherButton.backgroundColor = AppearanceController.customOrangeColor
        } else {
            features.append(dishwasher)
            dishwasherButton.setTitleColor(buttonPressedColor, for: .normal)
            dishwasherButton.backgroundColor = AppearanceController.viewButtonPressedColor
        }
    }
    
    @IBAction func backyardButtonTapped(_ sender: UIButton) {
        let backyard = UserController.PropertyFeatures.backyard.rawValue
        if features.contains(backyard), let index = features.index(of: backyard) {
            features.remove(at: index)
            backyardButton.setTitleColor(.white, for: .normal)
            backyardButton.backgroundColor = AppearanceController.customOrangeColor
        } else {
            features.append(backyard)
            backyardButton.setTitleColor(buttonPressedColor, for: .normal)
            backyardButton.backgroundColor = AppearanceController.viewButtonPressedColor
        }
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        saveWantedFeaturesToAccountCreationDictionary()
        AccountCreationController.pageRightFrom(landlordVC: self)
    }
    
    func saveWantedFeaturesToAccountCreationDictionary() {
        let featureString = features.joined(separator: ", ")
        UserController.addAttributeToUserDictionary(attribute: [UserController.kPropertyFeatures: featureString])
    }
    
    // MARK: - Navigation

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }


}
