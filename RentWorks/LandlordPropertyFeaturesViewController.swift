//
//  LandlordPropertyFeaturesViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class LandlordPropertyFeaturesViewController: UIViewController {

    var features: [String] = [String]()
    
    let buttonPressedColor = AppearanceController.buttonPressedColor
    
    @IBOutlet weak var laundryButton: UIButton!
    @IBOutlet weak var garageButton: UIButton!
    @IBOutlet weak var poolButton: UIButton!
    @IBOutlet weak var gymButton: UIButton!
    @IBOutlet weak var dishwasherButton: UIButton!
    @IBOutlet weak var backyardButton: UIButton!
//    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AccountCreationController.addNextVCToLandlordPageVCDataSource(landlordVC: self)
        
//        nextButton.isHidden = true
        
//        nextButton.slideFromRight()
        
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
        let laundry = UserController.kWasherDryer
        if features.contains(laundry), let index = features.index(of: laundry) {
            features.remove(at: index)
            laundryButton.backgroundColor = AppearanceController.vengaYellowColor
        } else {
            features.append(laundry)
            laundryButton.backgroundColor = AppearanceController.viewButtonPressedColor
            
        }
    }
    
    @IBAction func garageButtonTapped(_ sender: AnyObject) {
        let garage = UserController.kGarage
        if features.contains(garage), let index = features.index(of: garage) {
            features.remove(at: index)
            garageButton.backgroundColor = AppearanceController.vengaYellowColor
        } else {
            features.append(garage)
            garageButton.backgroundColor = AppearanceController.viewButtonPressedColor
        }
    }
    
    @IBAction func poolButtonTapped(_ sender: AnyObject) {
        let pool = UserController.kDishwasher
        if features.contains(pool), let index = features.index(of: pool) {
            features.remove(at: index)
            poolButton.backgroundColor = AppearanceController.vengaYellowColor
        } else {
            features.append(pool)
            poolButton.backgroundColor = AppearanceController.viewButtonPressedColor
        }
    }
    
    @IBAction func gymButtonTapped(_ sender: AnyObject) {
        let gym = UserController.kBackyard
        if features.contains(gym), let index = features.index(of: gym) {
            features.remove(at: index)
            gymButton.backgroundColor = AppearanceController.vengaYellowColor
        } else {
            features.append(gym)
            gymButton.backgroundColor = AppearanceController.viewButtonPressedColor
        }
    }
    
    @IBAction func dishwasherButtonTapped(_ sender: AnyObject) {
        let dishwasher = UserController.kPool
        if features.contains(dishwasher), let index = features.index(of: dishwasher) {
            features.remove(at: index)
            dishwasherButton.backgroundColor = AppearanceController.vengaYellowColor
        } else {
            features.append(dishwasher)
            dishwasherButton.backgroundColor = AppearanceController.viewButtonPressedColor
        }
    }
    
    @IBAction func backyardButtonTapped(_ sender: UIButton) {
        let backyard = UserController.kGym
        if features.contains(backyard), let index = features.index(of: backyard) {
            features.remove(at: index)
            backyardButton.backgroundColor = AppearanceController.vengaYellowColor
        } else {
            features.append(backyard)
            backyardButton.backgroundColor = AppearanceController.viewButtonPressedColor
        }
    }

//    @IBAction func nextButtonTapped(_ sender: UIButton) {
//        saveWantedFeaturesToAccountCreationDictionary()
//        AccountCreationController.pageRightFrom(landlordVC: self)
//    }
    
    func saveWantedFeaturesToAccountCreationDictionary() {
        var washerDryer = false
        var garage = false
        var dishwasher = false
        var backyard = false
        var pool = false
        var gym = false
        
        for feature in features {
            switch feature {
            case UserController.kWasherDryer:
                washerDryer = true
                break
            case UserController.kGarage:
                garage = true
                break
            case UserController.kDishwasher:
                dishwasher = true
                break
            case UserController.kBackyard:
                backyard = true
                break
            case UserController.kPool:
                pool = true
                break
            case UserController.kGym:
                gym = true
                break
            default:
                break
            }
        }
        
        UserController.addAttributeToUserDictionary(attribute: [UserController.kWasherDryer: washerDryer])
        UserController.addAttributeToUserDictionary(attribute: [UserController.kGarage: garage])
        UserController.addAttributeToUserDictionary(attribute: [UserController.kDishwasher: dishwasher])
        UserController.addAttributeToUserDictionary(attribute: [UserController.kBackyard: backyard])
        UserController.addAttributeToUserDictionary(attribute: [UserController.kPool: pool])
        UserController.addAttributeToUserDictionary(attribute: [UserController.kGym: gym])
    }
    
    // MARK: - Navigation

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }


}
