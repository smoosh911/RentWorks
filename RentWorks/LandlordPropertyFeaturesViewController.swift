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
    
    @IBOutlet weak var laundryButton: UIButton!
    @IBOutlet weak var garageButton: UIButton!
    @IBOutlet weak var poolButton: UIButton!
    @IBOutlet weak var gymButton: UIButton!
    @IBOutlet weak var dishwasherButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func laundryButtonTapped(_ sender: AnyObject) {
        let laundry = UserController.PropertyFeatures.laundry.rawValue
        if features.contains(laundry), let index = features.index(of: laundry) {
            features.remove(at: index)
            laundryButton.setTitleColor(.white, for: .normal)
        } else {
            features.append(laundry)
            laundryButton.setTitleColor(.green, for: .normal)
        }
    }
    
    @IBAction func garageButtonTapped(_ sender: AnyObject) {
        let garage = UserController.PropertyFeatures.garage.rawValue
        if features.contains(garage), let index = features.index(of: garage) {
            features.remove(at: index)
            garageButton.setTitleColor(.white, for: .normal)
        } else {
            features.append(garage)
            garageButton.setTitleColor(.green, for: .normal)
        }
    }
    
    @IBAction func poolButtonTapped(_ sender: AnyObject) {
        let pool = UserController.PropertyFeatures.pool.rawValue
        if features.contains(pool), let index = features.index(of: pool) {
            features.remove(at: index)
            poolButton.setTitleColor(.white, for: .normal)
        } else {
            features.append(pool)
            poolButton.setTitleColor(.green, for: .normal)
        }
    }
    
    @IBAction func gymButtonTapped(_ sender: AnyObject) {
        let gym = UserController.PropertyFeatures.gym.rawValue
        if features.contains(gym), let index = features.index(of: gym) {
            features.remove(at: index)
            gymButton.setTitleColor(.white, for: .normal)
        } else {
            features.append(gym)
            gymButton.setTitleColor(.green, for: .normal)
        }
    }
    
    @IBAction func dishwasherButtonTapped(_ sender: AnyObject) {
        let dishwasher = UserController.PropertyFeatures.dishwasher.rawValue
        if features.contains(dishwasher), let index = features.index(of: dishwasher) {
            features.remove(at: index)
            dishwasherButton.setTitleColor(.white, for: .normal)
        } else {
            features.append(dishwasher)
            dishwasherButton.setTitleColor(.green, for: .normal)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let featureString = features.joined(separator: ", ")
        
        UserController.addAttributeToUserDictionary(attribute: [UserController.kPropertyFeatures: featureString])
        print(UserController.temporaryUserCreationDictionary)

    }


}
