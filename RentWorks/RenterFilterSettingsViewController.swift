//
//  RenterFilterSettingsViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 1/29/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation
import FirebaseAuth
//import FilterMultiSelectionSegmentedControl

protocol RenterFilterSettingsModalViewControllerDelegate {
    func viewDismissed()
}

protocol RenterFilterSettingsViewControllerDelegate: class {
    func updateSettings()
}

class RenterFilterSettingsViewController: UIViewController, FilterMultiSelectionSegmentedControlDelegate {
    
    // MARK: outlets
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var txtFldZipcode: UITextField!
    @IBOutlet weak var txtFldState: UITextField!
    @IBOutlet weak var sldRent: FilterSlider!
    @IBOutlet weak var segCtrlBeds: UISegmentedControl!
    @IBOutlet weak var segCtrlBaths: UISegmentedControl!

    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblRent: UILabel!
    @IBOutlet weak var lblLooking: UILabel!
    @IBOutlet weak var lblAllowed: UILabel!
    @IBOutlet weak var lblNeed: UILabel!

    @IBOutlet weak var mulSegCtrlAllow: FilterMultiSelectionSegmentedControl!
    @IBOutlet weak var multSegCtrlAmenities: FilterMultiSelectionSegmentedControl!
    @IBOutlet weak var multSegCtrlOutside: FilterMultiSelectionSegmentedControl!
    
    // MARK: variables
    weak var delegate: RenterFilterSettingsViewControllerDelegate?
    var modalViewDelegate: RenterFilterSettingsModalViewControllerDelegate?
    let renter = UserController.currentRenter
    
    let allowedLabels: [String] = ["Pets", "Smoking"]
    let amenitiesLabels: [String] = ["Washer/Dryer","Dishwasher", "Garage"]
    let outsideLabels: [String] = ["Pool","Gym", "Backyard"]
    
    var filterSettingsDict: [String: Any]?
    let filterKeys = UserController.RenterFilters.self
    
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        modalView.layer.cornerRadius = 10
        setUpMultiSegCtrl()
        setCurrentRenterFilters()
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
   
        mulSegCtrlAllow.selectedSegmentIndices = []
        multSegCtrlAmenities.selectedSegmentIndices = []
        multSegCtrlOutside.selectedSegmentIndices = []
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
    
    private func updateRenterValues() {
        guard let renter = UserController.currentRenter, let id = renter.id else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        let zipcode = txtFldZipcode.text!
        renter.wantedZipCode = zipcode
        RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kZipCode.rawValue, newValue: zipcode)
        
        let state = txtFldState.text!
        renter.wantedState = state;
        RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kState.rawValue, newValue: state)
        
        let rent = sldRent.value
        renter.wantedPayment = Int64(rent)
        RenterController.updateCurrentRenterInFirebase(id: UserController.currentUserID!, attributeToUpdate: filterKeys.kMonthlyPayment.rawValue, newValue: rent)
        
        let beds = segCtrlBeds.selectedSegmentIndex + 1
        renter.wantedBedroomCount = Int64(beds)
        RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kBedroomCount.rawValue, newValue: beds)
        
        let baths = segCtrlBaths.selectedSegmentIndex + 1
        renter.wantedBathroomCount = Double(baths)
        RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kBathroomCount.rawValue, newValue: baths)
        
        let allowedIndices = mulSegCtrlAllow.selectedSegmentIndices
        if (allowedIndices.contains(0)){
            renter.wantsPetFriendly = true
            RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kPetsAllowed.rawValue, newValue: true)
        }
        if (allowedIndices.contains(1)) {
            renter.wantsSmoking = true;
            RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: filterKeys.kSmokingAllowed.rawValue, newValue: true)
        }
    
        updateSettingsChanged()
        //UserController.saveToPersistentStore()
    }
    
    private func setCurrentRenterFilters() {
        guard let renter = UserController.currentRenter,
            let zipcode = renter.wantedZipCode,
            let city = renter.wantedCity,
            let state = renter.wantedState
            else { return }
        
        lblLocation.text = zipcode + (city != "" ? ", " + city + ", " + state : "")
        txtFldZipcode.text = zipcode
        txtFldState.text = state
        
        let rent = renter.wantedPayment
        lblRent.text = "$" + String(rent) + " /month"
        sldRent.value = Float(rent)
        
        let bed = renter.wantedBedroomCount
        let bath = renter.wantedBathroomCount
        lblLooking.text = String(bed) + " Bed, " + String(bath) + " Bath"
        segCtrlBeds.selectedSegmentIndex = bed-1
        segCtrlBaths.selectedSegmentIndex = Int(bath - 1)
        
        var allowedIndices = [Int]()
        if (renter.wantsPetFriendly){
            allowedIndices.append(0)
         }
        if (renter.wantsSmoking) {
           allowedIndices.append(1)
        }
        mulSegCtrlAllow.selectedSegmentIndices = allowedIndices
        multiSelectionSegmentedControl(mulSegCtrlAllow, selectedIndices: allowedIndices)

        var amenititesIndices = [Int]()
        if(renter.wantsWasherDryer) {
            amenititesIndices.append(0)
        }
        if(renter.wantsDishwasher) {
            amenititesIndices.append(1)
        }
        if(renter.wantsGarage) {
            amenititesIndices.append(2)
        }
        multSegCtrlAmenities.selectedSegmentIndices = amenititesIndices
        multiSelectionSegmentedControl(multSegCtrlAmenities, selectedIndices: amenititesIndices)
        
        var outsideIndices = [Int]()
        if(renter.wantsGym) {
           outsideIndices.append(0)
        }
        if(renter.wantsPool) {
            outsideIndices.append(1)
        }
        if(renter.wantsBackyard) {
            outsideIndices.append(2)
        }
        multSegCtrlOutside.selectedSegmentIndices = outsideIndices
        multiSelectionSegmentedControl(multSegCtrlOutside, selectedIndices: outsideIndices)
    }
    
    //MARK: ATHMultiSelectionSegmentedControl
    func setUpMultiSegCtrl() {
        mulSegCtrlAllow.insertSegmentsWithTitles(allowedLabels)
        mulSegCtrlAllow.delegate = self
        mulSegCtrlAllow.tintColor = UIColor(red:0.95, green:0.96, blue:0.97, alpha:1.0)
        
        multSegCtrlAmenities.insertSegmentsWithTitles(amenitiesLabels)
        multSegCtrlAmenities.delegate = self
        multSegCtrlAmenities.tintColor = UIColor(red:0.95, green:0.96, blue:0.97, alpha:1.0)
        
        multSegCtrlOutside.insertSegmentsWithTitles(outsideLabels)
        multSegCtrlOutside.delegate = self
        multSegCtrlOutside.tintColor = UIColor(red:0.95, green:0.96, blue:0.97, alpha:1.0)
    }
    
    func multiSelectionSegmentedControl(_ control: FilterMultiSelectionSegmentedControl, selectedIndices indices: [Int]) {
        if (control == mulSegCtrlAllow) {
            var selectedIndicesLabels = ""
            for index in indices {
                selectedIndicesLabels.append("\(allowedLabels[index]), ")
            }
            lblAllowed.text = selectedIndicesLabels
            
        } else if (control == multSegCtrlAmenities) {
            var selectedIndicesLabels = ""
            
            for index in indices {
                selectedIndicesLabels.append("\(amenitiesLabels[index]) ")
            }
            let outsideIndices = multSegCtrlOutside.selectedSegmentIndices
            for index in outsideIndices {
                selectedIndicesLabels.append("\(outsideLabels[index]) ")
            }
            lblNeed.text = selectedIndicesLabels
            
        } else if (control == multSegCtrlOutside) {
            var selectedIndicesLabels = ""
            
            let amenitiesIndices = multSegCtrlAmenities.selectedSegmentIndices
            for index in amenitiesIndices {
                selectedIndicesLabels.append("\(amenitiesLabels[index]) ")
            }
            for index in indices {
                selectedIndicesLabels.append("\(outsideLabels[index]) ")
            }
            lblNeed.text = selectedIndicesLabels
        }
    }
    
    //MARK: delegate
    func updateSettings() {
        updateSettingsChanged()
    }
    
    private func updateSettingsChanged() {
        SettingsViewController.settingsDidChange = true
        UserController.propertyFetchCount = 0
        if UserController.currentUserID != "" {
            RenterController.resetStartAtForRenterInFirebase(renterID: renter!.id!)
        } else {
            PropertyController.getFirstPropertyID(completion: { (propertyID) in
                self.renter?.startAt = propertyID
            })
        }
    }

}
