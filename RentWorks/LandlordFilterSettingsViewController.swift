//
//  LandlordFilterSettingsViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 2/11/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation
import FirebaseAuth

protocol LandlordFilterSettingsViewControllerDelegate {
    func modalViewDismissed()
}

class LandlordFilterSettingsViewController: UIViewController {
    
    // MARK: outlets
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var creditSegmentedControl: UISegmentedControl!
    @IBOutlet weak var incomeSlider: Slider!
    @IBOutlet weak var studentSegmentedControl: UISegmentedControl!
    @IBOutlet weak var bankruptcySegmentedControl: UISegmentedControl!
    @IBOutlet weak var maritalSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var maritalLabel: UILabel!
    @IBOutlet weak var bankruptcyLabel: UILabel!
    @IBOutlet weak var studentLabel: UILabel!
    
    @IBOutlet weak var anyCreditButton: UIButton!
    @IBOutlet weak var aPlusCreditButton: UIButton!
    @IBOutlet weak var aCreditButton: UIButton!
    @IBOutlet weak var bCreditButton: UIButton!
    @IBOutlet weak var otherCreditButton: UIButton!
    
    
    // NOTE FOR MIKE: I changed the buttons names to match the credit rating options in the user creation process. It might mess up some of the logic in the viewDidLoad if you try to find the index of say 'D' credit rating as this array does not have it anymore.
    
    
     // MARK: variables
    var creditRatings: [String] = ["Any", "A+", "A", "B", "Other"]
    var delegate: LandlordFilterSettingsViewControllerDelegate?
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalView.layer.cornerRadius = 10;
        setCurrentLandlordFilters()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let delegate = delegate {
            delegate.modalViewDismissed()
        }
    }
    
    // MARK: Actions
    @IBAction func btnCancel_TouchedUpInside(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetBtnPressed(_ sender: Any) {
        // reset values to inital value
        creditSegmentedControl.selectedSegmentIndex = 0
        creditLabel.text = creditSegmentedControl.titleForSegment(at: creditSegmentedControl.selectedSegmentIndex)
        
        let num = Int(incomeSlider.minimumValue)
        incomeSlider.value = incomeSlider.minimumValue
        incomeLabel.text = "$" + num.description + " +"
        
        maritalSegmentedControl.selectedSegmentIndex = 0
        maritalLabel.text = maritalSegmentedControl.titleForSegment(at: maritalSegmentedControl.selectedSegmentIndex)
        
        bankruptcySegmentedControl.selectedSegmentIndex = 0
        bankruptcyLabel.text = bankruptcySegmentedControl.titleForSegment(at: bankruptcySegmentedControl.selectedSegmentIndex)
        
        studentSegmentedControl.selectedSegmentIndex = 0
        studentLabel.text = studentSegmentedControl.titleForSegment(at: studentSegmentedControl.selectedSegmentIndex)
    }
    
    @IBAction func applyFiltersBtnPressed(_ sender: Any) {
        if FIRAuth.auth()?.currentUser == nil {
            AlertManager.alert(withTitle: "Not Logged In", withMessage: "Must log in to use filters", dismissTitle: "OK", inViewController: self)
        } else {
            guard let landlord = UserController.currentLandlord, let _ = landlord.id else { return }
            
            // update landlord filter settings and dismiss modal.
            updateLandLordValues()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func creditIndexChanged(_ sender: Any) {
         creditLabel.text = creditSegmentedControl.titleForSegment(at: creditSegmentedControl.selectedSegmentIndex)
    }
    
    @IBAction func maritalIndexChanged(_ sender: UISegmentedControl) {
        maritalLabel.text = maritalSegmentedControl.titleForSegment(at: maritalSegmentedControl.selectedSegmentIndex)
    }
    
    @IBAction func bankruptcyIndexChanged(_ sender: Any) {
         bankruptcyLabel.text = bankruptcySegmentedControl.titleForSegment(at: bankruptcySegmentedControl.selectedSegmentIndex)
    }

    @IBAction func studentIndexChanged(_ sender: Any) {
         studentLabel.text = studentSegmentedControl.titleForSegment(at: studentSegmentedControl.selectedSegmentIndex)
    }
    
    @IBAction func incomeLevelChanged(_ sender: Slider) {
        let num = Int(sender.value)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let numString = numberFormatter.string(from: NSNumber(value: num))
        
        incomeLabel.text = "$" + numString! + " +"
    }
    
    // MARK: helper functions
    private func updateLandLordValues() {
        guard let landlord = UserController.currentLandlord, let id = landlord.id else {
            self.dismiss(animated: true, completion: nil)
            // TO DO: should let the user know they aren't logged in
            return
        }
        
        //TO DO: check if index == 0 if this mean there is no filter? Might need to change depending on how filters work.
        // set value for credit rating
        let creditRating = creditSegmentedControl.titleForSegment(at: creditSegmentedControl.selectedSegmentIndex)
        landlord.wantsCreditRating = creditRating
        LandlordController.updateCurrentLandlordInFirebase(id: id, attributeToUpdate: UserController.kWantsCreditRating, newValue: creditRating!)
        
         //TO DO: set other filter values here
        
        updateSettingsChanged()
    }
    
    private func setCurrentLandlordFilters() {
        guard let landlord = UserController.currentLandlord,
            let desiredCreditRating = landlord.wantsCreditRating,
            let idx = creditRatings.index(of: desiredCreditRating) else {
                return
        }
        
        creditSegmentedControl.selectedSegmentIndex = idx
        creditLabel.text = creditSegmentedControl.titleForSegment(at: creditSegmentedControl.selectedSegmentIndex)
        
        //TO DO: set other filter values here
        
        updateSettingsChanged()
        
    }
    
    private func updateSettingsChanged() {
        SettingsViewController.settingsDidChange = true
        UserController.renterFetchCount = 0
        PropertyController.resetStartAtForAllPropertiesInFirebase()
    }
}




