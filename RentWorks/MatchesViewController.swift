//
//  MatchesViewController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/14/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import MessageUI

class MatchesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MatchControllerDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: life cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MatchController.delegate = self
        MatchController.currentUserHasNewMatches = false
    }
    
    // MARK: helper functions
    
    func currentUserHasMatchesUpdated() {
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
    
    // MARK: table view
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 122
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        guard let cell = tableView.cellForRow(at: indexPath) as? MatchTableViewCell else { return }
//        let emailComposeVC = MFMailComposeViewController()
//        if MFMailComposeViewController.canSendMail() {
//            emailComposeVC.view.tintColor = AppearanceController.vengaYellowColor
//            if let renter = cell.renter {
//                guard let email = renter.email else { return }
//                emailComposeVC.setToRecipients([email])
//                emailComposeVC.setSubject("We matched on Venga!")
//            } else if let property = cell.property {
//                // Fix this fetching later to pull the landlord from CoreData when they actually have that relationship.
//                if let email = property.landlord?.email {
//                    emailComposeVC.setToRecipients([email])
//                    emailComposeVC.setSubject("We matched on Venga!")
//                } else {
//                    FirebaseController.getLandlordFor(property: property, completion: { (landlord) in
//                        guard let landlord = landlord, let email = landlord.email else { return }
//                        emailComposeVC.setToRecipients([email])
//                        emailComposeVC.setSubject("We matched on Venga!")
//                    })
//                }
//            }
//
//            present(emailComposeVC: emailComposeVC)
//        }
    }
    
    // these two below functions enable the table view cell swipe to delete or report
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
}
