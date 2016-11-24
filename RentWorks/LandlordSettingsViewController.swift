//
//  LandlordSettingsViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import CoreData

class LandlordSettingsViewController: SettingsViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pkrCreditRating: UIPickerView!
    
    var creditRatingPickerViewContent = ["Any","A","B","C","D","F"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pkrCreditRating.dataSource = self
        pkrCreditRating.delegate = self
        lblUserName.text = "\(UserController.currentLandlord!.firstName!) \(UserController.currentLandlord!.lastName!)"
        if let desiredCreditRating = UserController.currentLandlord?.wantsCreditRating {
            let ratingIndex = creditRatingPickerViewContent.index(of: desiredCreditRating)
            pkrCreditRating.selectRow(ratingIndex!, inComponent: 0, animated: false)
        }
    }
    
    // MARK: picker view delegate
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let rowValue = creditRatingPickerViewContent[row]
        if UserController.currentUserID == nil {
            return
        }
        UserController.currentLandlord?.wantsCreditRating = rowValue
        UserController.updateCurrentLandlordInFirebase(id: UserController.currentUserID!, attributeToUpdate: UserController.kWantsCreditRating, newValue: rowValue)
        UserController.saveToPersistentStore()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return creditRatingPickerViewContent[row]
    }
    
    // MARK: picker view datasource
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return creditRatingPickerViewContent.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
//    @IBAction func txtfldCreditRating_EditingChanged(_ sender: Any) {
//        let context = CoreDataStack.context
//        if UserController.currentLandlord == nil {
//            UserController.getCurrentLandlordFromCoreData(completion: { (landLordExists) in
//                
//            })
//        }
//        UserController.currentLandlord?.wantsCreditRating = txtfldCreditRating.text!
//    }
    
}
