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
    
    var properties: [Property] = UserController.currentLandlord?.property?.array as! [Property]
    var selectedCell: PropertyTableViewCell? = nil
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // needs work: don't get properties all over again
        UserController.fetchAllProperties()
        let landlordID = UserController.currentUserID
        properties = FirebaseController.properties.filter({ $0.landlordID == landlordID})
        if properties.count == 0 {
            properties = UserController.currentLandlord?.property?.array as! [Property]
        }
    }
    
    // MARK: segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.ToPropertyDetailsVC.rawValue {
            guard let destinationVC = segue.destination as? PropertyDetailsViewController, let cell = selectedCell else { return }
            
            destinationVC.property = cell.property
        }
    }
    
    @IBAction func backNavigationButtonTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

extension PropertiesViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // needs work: refactor to take in dictionary
        let property = properties[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.Cells.PropertyCell.rawValue, for: indexPath) as! PropertyTableViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        cell.property = property
        cell.addressLabel.text = property.address
        cell.availableDate.text = dateFormatter.string(from: property.availableDate as! Date)
        cell.monthlyPayment.text = "\(property.monthlyPayment)"
        
        guard let profileImage = property.profileImages?.firstObject as? ProfileImage, let image = UIImage(data: profileImage.imageData as! Data) else { return cell }
        
        cell.imgProperty.image = image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = tableView.cellForRow(at: indexPath) as? PropertyTableViewCell
        
        performSegue(withIdentifier: Identifiers.Segues.ToPropertyDetailsVC.rawValue, sender: self)
    }
    
    // MARK: datasource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return properties.count
    }

    
}