//
//  PropertyMatchesViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/26/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class PropertyMatchesViewController: MatchesViewController, MatchTableViewCellDelegate {
    
    // MARK: variables
    
    var property: Property!
    var selectedCell: MatchTableViewCell?
    
    var matchedRentersForProperty: [Renter]! = []
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let currentProperty = property, let propertyID = currentProperty.propertyID, let matchedRenters = MatchController.matchedRentersForProperties[propertyID] else {
            return
        }
        matchedRentersForProperty = matchedRenters
        
        let oldPropertyMatchCount = UserDefaults.standard.integer(forKey: "\(Identifiers.UserDefaults.propertyMatchCount.rawValue)/\(propertyID)")
        
        if matchedRentersForProperty.count > oldPropertyMatchCount {
            UserDefaults.standard.set(matchedRentersForProperty.count, forKey: "\(Identifiers.UserDefaults.propertyMatchCount.rawValue)/\(propertyID)")
            if MatchController.propertyIDsWithMatches.contains(propertyID) {
                MatchController.propertyIDsWithMatches = MatchController.propertyIDsWithMatches.filter({$0 != propertyID})
            }
        }
    }

    // MARK: segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.reportUserVC.rawValue {
            if let destinationVC = segue.destination as? ReportUserViewController, let cell = selectedCell, let renter = cell.renter {
                destinationVC.userBeingReported = renter
            }
        } else if segue.identifier == Identifiers.Segues.CardDetailVC.rawValue {
            if let destinationVC = segue.destination as? LandlordCardDetailViewController, let cell = selectedCell, let renter = cell.renter {
                destinationVC.renter = renter
            }
        } else if segue.identifier == Identifiers.Segues.messagingVC.rawValue {
            if let destinationVC = segue.destination as? LandlordMessagingViewController, let cell = selectedCell, let renter = cell.renter {
                destinationVC.renter = renter
                destinationVC.property = property
            }
        }
    }
    
    // MARK: table view delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return matchedRentersForProperty.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell", for: indexPath) as? MatchTableViewCell else { return UITableViewCell() }
        
        let matchingRenter = matchedRentersForProperty[indexPath.row]
        cell.updateWith(renter: matchingRenter)
        cell.matchesDelegate = self
//        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let report = UITableViewRowAction(style: .normal, title: "Report", handler: { (action, index) in
            self.selectedCell = tableView.cellForRow(at: index) as? MatchTableViewCell
            self.performSegue(withIdentifier: Identifiers.Segues.reportUserVC.rawValue, sender: self)
        })
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete", handler: { (action, index) in
            self.selectedCell = tableView.cellForRow(at: index) as? MatchTableViewCell
            guard let cell = self.selectedCell, let renter = cell.renter, let renterID = renter.id, let propertyID = self.property.propertyID else { return }
            PropertyController.deletePropertyRenterMatchInFirebase(propertyID: propertyID, renterID: renterID)
            MatchController.matchedRentersForProperties[propertyID] = self.matchedRentersForProperty.filter({$0.id != renterID})
            self.matchedRentersForProperty = MatchController.matchedRentersForProperties[propertyID]
            tableView.beginUpdates()
            tableView.deleteRows(at: [index], with: .automatic)
            tableView.endUpdates()
        })
        
        return [delete, report]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? MatchTableViewCell else { return }
        self.selectedCell = cell
        performSegue(withIdentifier: Identifiers.Segues.messagingVC.rawValue, sender: self)
    }
    
    // MARK: match table view cell delegate
    
    func presentDetailView(selectedCell: MatchTableViewCell) {
        self.selectedCell = selectedCell
        performSegue(withIdentifier: Identifiers.Segues.CardDetailVC.rawValue, sender: self)
    }
}
