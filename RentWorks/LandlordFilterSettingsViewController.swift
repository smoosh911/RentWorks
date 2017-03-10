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
    @IBOutlet weak var segCtrlCredit: UISegmentedControl!
    @IBOutlet weak var sldIncome: FilterSlider!
    @IBOutlet weak var segCtrlStudent: UISegmentedControl!
    @IBOutlet weak var segCtrlBankruptcy: UISegmentedControl!
    @IBOutlet weak var segCtrlMarital: UISegmentedControl!
    
    @IBOutlet weak var lblIncome: UILabel!
    @IBOutlet weak var lblCredit: UILabel!
    @IBOutlet weak var lblMarital: UILabel!
    @IBOutlet weak var lblBankruptcy: UILabel!
    @IBOutlet weak var lblStudent: UILabel!
    
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
        SettingsViewController.settingsDidChange = false;
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetBtnPressed(_ sender: Any) {
        segCtrlCredit.selectedSegmentIndex = 0
        lblCredit.text = segCtrlCredit.titleForSegment(at: segCtrlCredit.selectedSegmentIndex)
        
        let num = Int(sldIncome.minimumValue)
        sldIncome.value = sldIncome.minimumValue
        lblIncome.text = "$" + num.description + " +"
        
        segCtrlMarital.selectedSegmentIndex = 0
        lblMarital.text = segCtrlMarital.titleForSegment(at: segCtrlMarital.selectedSegmentIndex)
        
        segCtrlBankruptcy.selectedSegmentIndex = 0
        lblBankruptcy.text = segCtrlBankruptcy.titleForSegment(at: segCtrlBankruptcy.selectedSegmentIndex)
        
        segCtrlStudent.selectedSegmentIndex = 0
        lblStudent.text = segCtrlStudent.titleForSegment(at: segCtrlStudent.selectedSegmentIndex)
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
         lblCredit.text = segCtrlCredit.titleForSegment(at: segCtrlCredit.selectedSegmentIndex)
    }
    
    @IBAction func maritalIndexChanged(_ sender: UISegmentedControl) {
        lblMarital.text = segCtrlMarital.titleForSegment(at: segCtrlMarital.selectedSegmentIndex)
    }
    
    @IBAction func bankruptcyIndexChanged(_ sender: Any) {
         lblBankruptcy.text = segCtrlBankruptcy.titleForSegment(at: segCtrlBankruptcy.selectedSegmentIndex)
    }

    @IBAction func studentIndexChanged(_ sender: Any) {
         lblStudent.text = segCtrlStudent.titleForSegment(at: segCtrlStudent.selectedSegmentIndex)
    }
    
    @IBAction func incomeLevelChanged(_ sender: FilterSlider) {
        let num = Int(sender.value)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let numString = numberFormatter.string(from: NSNumber(value: num))
        
        lblIncome.text = "$" + numString! + " +"
    }
    
    // MARK: helper functions
    private func updateLandLordValues() {
        guard let landlord = UserController.currentLandlord, let id = landlord.id else {
            self.dismiss(animated: true, completion: nil)
            // TO DO: should let the user know they aren't logged in
            return
        }

        let creditRating = segCtrlCredit.titleForSegment(at: segCtrlCredit.selectedSegmentIndex)
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
    
        segCtrlCredit.selectedSegmentIndex = idx
        lblCredit.text = segCtrlCredit.titleForSegment(at: segCtrlCredit.selectedSegmentIndex)
        
        //TO DO: set other filter values here
        updateSettingsChanged()
    }
    
    private func updateSettingsChanged() {
        SettingsViewController.settingsDidChange = true
        UserController.renterFetchCount = 0
        PropertyController.resetStartAtForAllPropertiesInFirebase()
    }
}




