//
//  ReportUserViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 12/18/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import MessageUI

class ReportUserViewController: UIViewController, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: variables
    
    let reportOptions: [String] = ["Inappropriate Emails", "Inappropriate Photoes", "Unprofessional Offline Behavior", "Spamming", "Other"]
    
    var userBeingReported: Any!
    var userReporting: Any!
    
    var propertyBeingReported: Property?
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let renter = UserController.currentRenter {
            self.userReporting = renter
        } else if let landlord = UserController.currentLandlord {
            self.userReporting = landlord
        }
    }
    
    // MARK: actions
    
    @IBAction func btnCancel_TouchedUpInside(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            
        })
    }
    
    // MARK: email helper functions
    
    func createEmailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        sendMailErrorAlert.addAction(dismissAction)
        
        present(emailErrorAlert: sendMailErrorAlert)
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
    
    private func composeLandlordEmail(subjectLine: String, landlord: Landlord, property: Property, mailComposeVC: MFMailComposeViewController) {
        guard let firstName = landlord.firstName, let lastName = landlord.lastName, let propertyAddress = property.address, let propertyID = property.propertyID else { return }
        let messageBody = "The landlord \(firstName) \(lastName) is displaying inappropriate content on the property address \(propertyAddress) and ID \(propertyID).\n\n Detailed description of inappropriate content:"
        mailComposeVC.setToRecipients([Identifiers.RentWorksAdmin.complaintsEmail.rawValue])
        mailComposeVC.setSubject(subjectLine)
        mailComposeVC.setMessageBody(messageBody, isHTML: false)
        present(emailComposeVC: mailComposeVC)
    }
    
    // MARK: table view
    
    // delegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // needs work: refactor to take in dictionary
        let reportOption = reportOptions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.TableViewCells.ReportUser.rawValue, for: indexPath)
        
        cell.textLabel!.text = reportOption
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let mailComposeVC = MFMailComposeViewController()
        
        let subjectLine = reportOptions[indexPath.row]
        
        guard MFMailComposeViewController.canSendMail() else { createEmailErrorAlert(); return }
        mailComposeVC.view.tintColor = AppearanceController.vengaYellowColor
        
        if let renter = userBeingReported as? Renter {
            guard let firstName = renter.firstName, let lastName = renter.lastName, let renterID = renter.id else { return }
            
            let messageBody = "The renter \(firstName) \(lastName) with ID \(renterID) is being inappropriate.\n\n Detailed description of inappropriate content:"
            mailComposeVC.setToRecipients([Identifiers.RentWorksAdmin.complaintsEmail.rawValue])
            mailComposeVC.setSubject(subjectLine)
            mailComposeVC.setMessageBody(messageBody, isHTML: false)
            present(emailComposeVC: mailComposeVC)
        } else if let landlord = userBeingReported as? Landlord, let property = propertyBeingReported {
            composeLandlordEmail(subjectLine: subjectLine, landlord: landlord, property: property, mailComposeVC: mailComposeVC)
        }
    }
    
    // datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportOptions.count
    }
}
