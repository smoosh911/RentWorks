//
//  PropertiesViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class PropertiesViewController: UIViewController {
    
    @IBOutlet weak var tblvwProperties: UITableView!
    
    // MARK: variables
    
    var properties: [Property] = []
    var selectedCell: PropertyTableViewCell? = nil
    
    let landlordID = UserController.currentUserID
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        properties = FirebaseController.properties.filter({ $0.landlordID == landlordID})
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tblvwProperties.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        properties = FirebaseController.properties.filter({ $0.landlordID == landlordID})
        tblvwProperties.reloadData()
    }
    
    // MARK: actions
    
    @IBAction func editPropertyButtonTapped(_ sender: UIButton) {
        guard let contentView = sender.superview, let cell = contentView.superview as? PropertyTableViewCell else { return }
        
        self.selectedCell = cell
        
        self.performSegue(withIdentifier: Identifiers.Segues.editPropertyDetailsVC.rawValue, sender: self)
    }
    
    @IBAction func btnAdd_TouchedUpInside(_ sender: Any) {
        self.performSegue(withIdentifier: Identifiers.Segues.addPropertyVC.rawValue, sender: self)
    }
    
    // MARK: segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.editPropertyDetailsVC.rawValue {
            guard let destinationVC = segue.destination as? PropertyDetailsViewController, let cell = selectedCell else { return }
            destinationVC.propertyTask = PropertyTask.editing
            destinationVC.property = cell.property
        } else if segue.identifier == Identifiers.Segues.addPropertyVC.rawValue {
            guard let destinationVC = segue.destination as? PropertyDetailsViewController else { return }
            destinationVC.propertyTask = PropertyTask.adding
        } else if segue.identifier == Identifiers.Segues.mainVC.rawValue {
            guard let destinationVC = segue.destination as? LandlordMainViewController, let cell = selectedCell else { return }
            destinationVC.property = cell.property
        }
    }
}

extension PropertiesViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // needs work: refactor to take in dictionary
        let property = properties[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.TableViewCells.PropertyCell.rawValue, for: indexPath) as! PropertyTableViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        let today = Date()
        
        if let availableDate = property.availableDate {
            let laterDay = availableDate.laterDate(today)
            
            if laterDay == today {
                cell.imgBlipPropertyAvailableIndicator.image = #imageLiteral(resourceName: "popup-green-blip-icon")
            } else {
                cell.imgBlipPropertyAvailableIndicator.image = #imageLiteral(resourceName: "popup-gray-blip-icon")
            }
        }

        cell.property = property
        cell.addressLabel.text = property.address
//        cell.availableDate.text = dateFormatter.string(from: property.availableDate as! Date)
//        cell.monthlyPayment.text = "\(property.monthlyPayment)"
        
        guard let profileImage = property.profileImages?.firstObject as? ProfileImage, let image = UIImage(data: profileImage.imageData as! Data) else { return cell }
        
        cell.imgProperty.image = image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedCell = tableView.cellForRow(at: indexPath) as? PropertyTableViewCell
        self.performSegue(withIdentifier: Identifiers.Segues.mainVC.rawValue, sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit", handler: { (action, index) in
            self.selectedCell = tableView.cellForRow(at: index) as? PropertyTableViewCell
            self.performSegue(withIdentifier: Identifiers.Segues.editPropertyDetailsVC.rawValue, sender: self)
        })
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: { (action, index) in
            self.selectedCell = tableView.cellForRow(at: index) as? PropertyTableViewCell
            guard let cell = self.selectedCell, let propertyID = cell.property.propertyID else { return }
            PropertyController.deletePropertyInFirebase(propertyID: propertyID)
            FirebaseController.properties = self.properties.filter({$0.propertyID != propertyID})
            self.properties = FirebaseController.properties.filter({ $0.landlordID == self.landlordID})
            tableView.beginUpdates()
            tableView.deleteRows(at: [index], with: .automatic)
            tableView.endUpdates()
        })
        
        return [delete, edit]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! PropertiesHeaderCell
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    // MARK: datasource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
