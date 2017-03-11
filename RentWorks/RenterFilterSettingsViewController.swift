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
    
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        modalView.layer.cornerRadius = 10
        setCurrentRenterFilters()
        setUpMultiSegCtrl()
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
        
//        let zipcode = txtFldZipcode.text!
//        RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: (UserController.currentRenter?.wantedZipCode)!, newValue: zipcode)
//        
//        let state = txtFldState.text!
//        RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: (UserController.currentRenter?.wantedState)!, newValue: state)
        
//        let beds = segCtrlBeds.selectedSegmentIndex + 1
//        RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: String(renter.wantedBedroomCount), newValue: Int(beds))
        
//        let baths = segCtrlBaths.selectedSegmentIndex + 1
//         RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: renter., newValue: Double(baths))
//        
//        let allowedIndices = mulSegCtrlAllow.selectedSegmentIndices
//        if (allowedIndices.contains(0)){
//             RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: (UserController.currentRenter?.wantsPetFriendly)!, newValue: Bool(true))
//        }
//        if (allowedIndices.contains(1)) {
//            RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: (UserController.currentRenter?.wantsSmoking)!, newValue: true)
//        }
//        
//        let amenitiesIndices = multSegCtrlAmenities.selectedSegmentIndices
//        if (allowedIndices.contains(0)){
//            RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: (UserController.currentRenter?.wantsWasherDryer)!, newValue: true)
//        }
//        if (allowedIndices.contains(1)) {
//            RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: (UserController.currentRenter?.wantsDishwasher)!, newValue: true)
//        }
//        if (allowedIndices.contains(2)) {
//            RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: (UserController.currentRenter?.wantsGarage)!, newValue: true)
//        }
//        
//        let outsideIndices = multSegCtrlOutside.selectedSegmentIndices
//        if (allowedIndices.contains(0)){
//            RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: (UserController.currentRenter?.wantsPool)!, newValue: true)
//        }
//        if (allowedIndices.contains(1)) {
//            RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: (UserController.currentRenter?.wantsGym)!, newValue: true)
//        }
//        if (allowedIndices.contains(2)) {
//            RenterController.updateCurrentRenterInFirebase(id: id, attributeToUpdate: (UserController.currentRenter?.wantsBackyard)!, newValue: true)
//        }
        
//        self.delegate?.updateSettings()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setCurrentRenterFilters() {
        guard let renter = UserController.currentRenter,
            let zipcode = renter.wantedZipCode,
            let city = renter.wantedCity,
            let state = renter.wantedState
            else { return }
        
        lblLocation.text = zipcode + (city != "" ? ", " + city + ", " + state : "")
        lblRent.text = String(renter.wantedPayment)
        sldRent.value = Float(renter.wantedPayment)
        
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
        multiSelectionSegmentedControl(mulSegCtrlAllow, selectedIndices: mulSegCtrlAllow.selectedSegmentIndices)
        
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
        multiSelectionSegmentedControl(multSegCtrlAmenities, selectedIndices: multSegCtrlAmenities.selectedSegmentIndices)
        
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
        multiSelectionSegmentedControl(multSegCtrlOutside, selectedIndices: multSegCtrlOutside.selectedSegmentIndices)
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
                selectedIndicesLabels.append("\(allowedLabels[index]),")
            }
            lblAllowed.text = selectedIndicesLabels
            
        } else if (control == multSegCtrlAmenities) {
            var selectedIndicesLabels = ""
            
            for index in indices {
                selectedIndicesLabels.append("\(amenitiesLabels[index]),")
            }
            let outsideIndices = multSegCtrlOutside.selectedSegmentIndices
            for index in outsideIndices {
                selectedIndicesLabels.append("\(outsideLabels[index]),")
            }
            lblNeed.text = selectedIndicesLabels
            
        } else if (control == multSegCtrlOutside) {
            var selectedIndicesLabels = ""
            
            let amenitiesIndices = multSegCtrlAmenities.selectedSegmentIndices
            for index in amenitiesIndices {
                selectedIndicesLabels.append("\(amenitiesLabels[index]),")
            }
            for index in indices {
                selectedIndicesLabels.append("\(outsideLabels[index]),")
            }
            lblNeed.text = selectedIndicesLabels
        }
    }
}
