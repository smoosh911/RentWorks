//
//  RenterWantedFeaturesViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/19/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class RenterWantedFeaturesViewController: UIViewController {
    var features = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func laundryButtonTapped(_ sender: AnyObject) {
        let laundry = UserController.PropertyFeatures.laundry.rawValue
        if features.contains(laundry), let index = features.index(of: laundry) {
            features.remove(at: index)
        } else {
            features.append(laundry)
        }
    }
    
    @IBAction func garageButtonTapped(_ sender: AnyObject) {
        let garage = UserController.PropertyFeatures.garage.rawValue
        if features.contains(garage), let index = features.index(of: garage) {
            features.remove(at: index)
        } else {
            features.append(garage)
        }
    }
    
    @IBAction func poolButtonTapped(_ sender: AnyObject) {
        let pool = UserController.PropertyFeatures.pool.rawValue
        if features.contains(pool), let index = features.index(of: pool) {
            features.remove(at: index)
        } else {
            features.append(pool)
        }
    }
    
    @IBAction func gymButtonTapped(_ sender: AnyObject) {
        let gym = UserController.PropertyFeatures.gym.rawValue
        if features.contains(gym), let index = features.index(of: gym) {
            features.remove(at: index)
        } else {
            features.append(gym)
        }
    }
    
    @IBAction func dishwasherButtonTapped(_ sender: AnyObject) {
        let dishwasher = UserController.PropertyFeatures.dishwasher.rawValue
        if features.contains(dishwasher), let index = features.index(of: dishwasher) {
            features.remove(at: index)
        } else {
            features.append(dishwasher)
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let featureString = features.joined(separator: ", ")
        
        UserController.addAttributeToUserDictionary(attribute: [UserController.UserDictionaryKeys.kPropertyFeatures: featureString])
        print(UserController.temporaryUserCreationDictionary)
        
    }
    
}
