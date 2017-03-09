//
//  RenterFilterSettingsViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 1/29/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation
import FirebaseAuth
import ATHMultiSelectionSegmentedControl


protocol RenterFilterSettingsModalViewControllerDelegate {
    func viewDismissed()
}

protocol RenterFilterSettingsViewControllerDelegate: class {
    func updateSettings()
}

class RenterFilterSettingsViewController: UIViewController {
    
    // MARK: outlets
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var txtFldZipcode: UITextField!
    @IBOutlet weak var txtFldState: UITextField!
    @IBOutlet weak var sldRent: FilterSlider!
    @IBOutlet weak var segCtrlBeds: UISegmentedControl!
    @IBOutlet weak var segCtrlBaths: UISegmentedControl!
    @IBOutlet weak var segCtrlAllow: UISegmentedControl!
    @IBOutlet weak var segCtrlAmenities: UISegmentedControl!
    @IBOutlet weak var segCtrlOutside: UISegmentedControl!

    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblRent: UILabel!
    @IBOutlet weak var lblLooking: UILabel!
    @IBOutlet weak var lblAllowed: UILabel!
    @IBOutlet weak var lblNeed: UILabel!

    // MARK: variables
    weak var delegate: RenterFilterSettingsViewControllerDelegate?
    var modalViewDelegate: RenterFilterSettingsModalViewControllerDelegate?
    var settingsTVC: RenterSettingsContainerTableViewController?
    let renter = UserController.currentRenter
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        modalView.layer.cornerRadius = 10
        setCurrentLandlordFilters()
        let segmentedControl = MultiSelectionSegmentedControl(items: nil)
        segmentedControl.insertSegmentsWithTitles(["1", "2", "3", "4"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        modalViewDelegate?.viewDismissed()
    }
    
    // MARK: actions
    @IBAction func cancelBtnPressed(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetBtnPressed(_ sender: Any) {
        txtFldZipcode.text = ""
        txtFldState.text = ""
        lblLocation.text = ""
        
        let num = Int(sldRent.minimumValue)
        sldRent.value = sldRent.minimumValue
        lblRent.text = "$" + num.description + " /month"
        
        segCtrlBeds.selectedSegmentIndex = 0
        segCtrlBaths.selectedSegmentIndex = 0
        let bed = segCtrlBeds.titleForSegment(at: segCtrlBeds.selectedSegmentIndex)
        let bath = segCtrlBaths.titleForSegment(at: segCtrlBaths.selectedSegmentIndex)
        lblLooking.text = bed! + ", " + bath!
        
        segCtrlAllow.selectedSegmentIndex = 0
        lblAllowed.text = segCtrlAllow.titleForSegment(at: segCtrlAllow.selectedSegmentIndex)
        
        segCtrlAmenities.selectedSegmentIndex = 0
        segCtrlOutside.selectedSegmentIndex = 0
        let amenities = segCtrlAmenities.titleForSegment(at: segCtrlAmenities.selectedSegmentIndex)
        let outside = segCtrlOutside.titleForSegment(at: segCtrlOutside.selectedSegmentIndex)
        lblNeed.text = amenities! + ", " + outside!


    }
    
    @IBAction func applyFiltersBtnPressed(_ sender: Any) {
        if FIRAuth.auth()?.currentUser == nil {
            AlertManager.alert(withTitle: "Not Logged In", withMessage: "Must log in to use filters", dismissTitle: "OK", inViewController: self)
        } else {
            guard let renter = UserController.currentRenter, let _ = renter.id else { return }
            
            // update landlord filter settings and dismiss modal.
            updateRenterValues()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func zipCodeChanged(_ sender: Any) {
        setLocation()
    }
    
    @IBAction func stateChanged(_ sender: Any) {
        setLocation()
    }
 
    @IBAction func rentValueChanged(_ sender: FilterSlider) {
        let num = Int(sender.value)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let numString = numberFormatter.string(from: NSNumber(value: num))
        
        lblRent.text = "$" + numString! + " /month"
    }
    
    @IBAction func lookingBedIndexChanged(_ sender: Any) {
        setLooking()
    }
    
    @IBAction func lookingBathIndexChanged(_ sender: Any) {
        setLooking()
    }

    @IBAction func allowIndexChanged(_ sender: Any) {
        lblAllowed.text = segCtrlAllow.titleForSegment(at: segCtrlAllow.selectedSegmentIndex)
    }

    @IBAction func needAmenitiesIndexChanged(_ sender: Any) {
        setNeed()
    }
  
    @IBAction func needOutsideIndexChanged(_ sender: Any) {
        setNeed()
    }

    // MARK: helper functions
    private func setLocation() {
          lblLocation.text = txtFldZipcode.text! + (txtFldState.text != "" ? ", " + txtFldState.text! : "")
    }
    
    private func setLooking() {
        var bed = segCtrlBeds.titleForSegment(at: segCtrlBeds.selectedSegmentIndex)
        var bath = segCtrlBaths.titleForSegment(at: segCtrlBaths.selectedSegmentIndex)
        
        if (segCtrlBeds.selectedSegmentIndex == 4) {
            bed = "5+ Beds"
        }
        if (segCtrlBaths.selectedSegmentIndex == 4) {
            bath = "5+ Baths"
        }
        
        lblLooking.text = bed! + ", " + bath!
    }
    
    private func setNeed() {
        let amenities = segCtrlAmenities.titleForSegment(at: segCtrlAmenities.selectedSegmentIndex)
        let outside = segCtrlOutside.titleForSegment(at: segCtrlOutside.selectedSegmentIndex)
        
        lblNeed.text = amenities! + ", " + outside!
    }
    
    private func updateRenterValues() {
        guard let id = UserController.currentUserID, let renter = renter, let settingsTVC = settingsTVC else { return }
        
        let zipcode = settingsTVC.txtfldZipCode.text!
        
        renter.wantedZipCode = zipcode
        if UserController.currentUserID != "" {
            RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: settingsTVC.filterKeys.kZipCode.rawValue, newValue: zipcode)
        }
        
        self.delegate?.updateSettings()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setCurrentLandlordFilters() {
        guard let renter = UserController.currentRenter,
            let zipcode = renter.wantedZipCode,
            let city = renter.wantedCity,
            let state = renter.wantedState
            else {
                return
        }
        
        lblLocation.text = zipcode + (city != "" ? ", " + city + ", " + state : "")
        
        lblRent.text = String(renter.wantedPayment)
        sldRent.value = Float(renter.wantedPayment)
        
        let bed = renter.wantedBedroomCount
        let bath = renter.wantedBathroomCount
        lblLooking.text = String(bed) + " Bed, " + String(bath) + " Bath"
        segCtrlBeds.selectedSegmentIndex = bed-1
        segCtrlBaths.selectedSegmentIndex = Int(bath - 1)
        
        let pets = renter.wantsPetFriendly
        if (pets){
            segCtrlAllow.selectedSegmentIndex = 0
            lblAllowed.text = "Pets"
         }
        let smoking = renter.wantsSmoking
        if (smoking) {
            segCtrlAllow.selectedSegmentIndex = 1
            lblAllowed.text = "Smoking"
        }

//        let washer = renter.wantsWasherDryer
//        let dishwasher = renter.wantsDishwasher
//        let garage = renter.wantsGarage
//        let gym = renter.wantsGym
//        let pool = renter.wantsPool
        
        lblNeed.text = "washer"
        
        
        
        
        
        
        //TO DO: set other filter values here
    }
}
