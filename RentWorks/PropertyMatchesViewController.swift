//
//  PropertyMatchesViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/26/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class PropertyMatchesViewController: MatchesViewController {
    
    var property: Property!
    var matchedRentersForProperty: [Renter]! = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return matchedRentersForProperty.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell", for: indexPath) as? MatchTableViewCell else { return UITableViewCell() }
        
        let matchingRenter = matchedRentersForProperty[indexPath.row]
        cell.updateWith(renter: matchingRenter)
        cell.delegate = self
        
        return cell
    }
}
