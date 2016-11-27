//
//  MatchesViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/14/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import MessageUI

class MatchesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UserMatchingDelegate, ContactEmailDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MatchController.delegate = self
        MatchController.currentUserHasNewMatches = false
        
        let oldRenterMatchCount = UserDefaults.standard.integer(forKey: Identifiers.UserDefaults.renterMatchCount.rawValue)
        
        if MatchController.matchedProperties.count > oldRenterMatchCount {
            UserDefaults.standard.set(MatchController.matchedProperties.count, forKey: Identifiers.UserDefaults.renterMatchCount.rawValue)
            MatchController.currentUserHasNewMatches = false
        }
    }
    
    func currentUserHasMatches() {
        self.tableView.reloadData()
    }
    
    @IBAction func backNavigationButtonTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func present(emailComposeVC: MFMailComposeViewController) {
        emailComposeVC.mailComposeDelegate = self
        self.present(emailComposeVC, animated: true, completion: nil)
    }
    
    func present(emailErrorAlert: UIAlertController) {
        self.present(emailErrorAlert, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserController.currentUserType == "renter" {
            return MatchController.matchedProperties.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "matchCell", for: indexPath) as? MatchTableViewCell else { return UITableViewCell() }
        
        if UserController.currentUserType == "renter" {
            let matchingProperty = MatchController.matchedProperties[indexPath.row]
            cell.updateWith(property: matchingProperty)
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
}
