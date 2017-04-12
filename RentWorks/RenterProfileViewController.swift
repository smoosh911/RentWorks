//
//  RenterProfileViewController.swift
//  RentWorks
//
//  Created by Eric Clinger on 3/20/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

class RenterProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    class View: UIView {
        override func layoutSubviews() {
            super.layoutSubviews()
        }
    }
    
    //MARK IBOutlets
    
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var profileNavBarView: UIView!
    @IBAction func renterProfileCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    //MARK Variables
    
    let accountArray = ["Edit Profile","Change Password","Credit Score"]
    
    let aboutArray = ["Contact Us","Privacy Policy","Terms of Service"]
    
    let lastArray = ["Log Out"]
    
    
    //MARK Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return accountArray.count
        case 1:
            return aboutArray.count
        case 2:
            return lastArray.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        var currentOption: String
        
        switch indexPath.section {
        case 0:
            currentOption = accountArray[indexPath.row]
        case 1:
            currentOption = aboutArray[indexPath.row]
        case 2:
            currentOption = lastArray[indexPath.row]
        default:
            currentOption = ""
        }
        
        cell.textLabel!.text = currentOption
        if(indexPath.section == 0 || indexPath.section == 1)
        {
            cell.accessoryType = .disclosureIndicator
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "ACCOUNT"
        case 1:
            return "ABOUT US"
        case 2:
            return ""
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected row: \(indexPath.row) in section \(indexPath.section)")
        if indexPath.row == 0 && indexPath.section == 2
        {
            let manager = FBSDKLoginManager()
            manager.logOut()
            
            do {
                try FIRAuth.auth()?.signOut()
            } catch let error as NSError {
                log(error)
                }
            
            for renter in MatchController.matchedRentersForProperties {
                UserDefaults.standard.set(0, forKey: "\(Identifiers.UserDefaults.propertyMatchCount.rawValue)/\(renter.key)")
            }
            UserDefaults.standard.set(0, forKey: Identifiers.UserDefaults.renterMatchCount.rawValue)
            MatchController.isObservingCurrentUserLikeEndpoint = false
            MatchController.matchedProperties = []
            MatchController.matchedRentersForProperties = [:]
            UserController.propertyFetchCount = 0
            UserController.renterFetchCount = 0
            
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC")
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    
    //MARK Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //modalView.layer.cornerRadius = 10
        //profileNavBarView.layer.cornerRadius = 10
        profileNavBarView.roundCorners(corners: [.topRight, .topLeft], radius: 10)
        
    }
    override func viewDidLayoutSubviews() {
        profileNavBarView.roundCorners(corners: [.topRight, .topLeft], radius: 10)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
