//
//  RenterMatchesViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 12/18/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class RenterMatchesViewController: MatchesViewController {
    
    // MARK: variables
    
    var renter: Renter!
    var selectedCell: MatchTableViewCell?
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let oldRenterMatchCount = UserDefaults.standard.integer(forKey: Identifiers.UserDefaults.renterMatchCount.rawValue)
        
        if MatchController.matchedProperties.count > oldRenterMatchCount {
            UserDefaults.standard.set(MatchController.matchedProperties.count, forKey: Identifiers.UserDefaults.renterMatchCount.rawValue)
            MatchController.currentUserHasNewMatches = false
        }
    }
    
    // MARK: segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.reportUserVC.rawValue {
            if let destinationVC = segue.destination as? ReportUserViewController, let cell = selectedCell, let property = cell.property, let landlordID = property.landlordID {
                LandlordController.getLandlordWithID(landlordID: landlordID, completion: { (landlord) in
                    guard let landlord = landlord else { return }
                    destinationVC.userBeingReported = landlord
                    destinationVC.propertyBeingReported = property
                })
            }
        }
    }
    
    // MARK: table view delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MatchController.matchedProperties.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell", for: indexPath) as? MatchTableViewCell else { return UITableViewCell() }
        
        let matchingProperty = MatchController.matchedProperties[indexPath.row]
        cell.updateWith(property: matchingProperty)
        
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let report = UITableViewRowAction(style: .normal, title: "Report", handler: { (action, index) in
            self.selectedCell = tableView.cellForRow(at: index) as? MatchTableViewCell
            self.performSegue(withIdentifier: Identifiers.Segues.reportUserVC.rawValue, sender: self)
        })
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: { (action, index) in
            self.selectedCell = tableView.cellForRow(at: index) as? MatchTableViewCell
            guard let cell = self.selectedCell, let property = cell.property, let propertyID = property.propertyID, let renterID = self.renter.id else { return }
            RenterController.deleteRenterPropertyMatchInFirebase(propertyID: propertyID, renterID: renterID)
            MatchController.matchedProperties = MatchController.matchedProperties.filter({$0.propertyID != propertyID})
            tableView.beginUpdates()
            tableView.deleteRows(at: [index], with: .automatic)
            tableView.endUpdates()
        })
        
        return [delete, report]
    }
}
