//
//  AppInformationViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 12/18/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class AppInformationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: variables
    
    private var optionsDict: [String: String] = ["EULA": Identifiers.RentWorksAdmin.EULA_URL.rawValue, "Privacy Policy": Identifiers.RentWorksAdmin.PrivacyPolicyURL.rawValue, "DropDown and Image slide show MIT": Identifiers.RentWorksAdmin.MIT_URL.rawValue, "Acknowledgments": Identifiers.RentWorksAdmin.Acknowledgments.rawValue]
    private var options: [Option] = []
    private var selectedOption: Option?
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for option in optionsDict {
            let urlFromString = URL(string: option.value)
            var optionObj: Option?
            if let url = urlFromString {
                optionObj = Option(name: option.key, URL: url)
            } else {
                optionObj = Option(name: option.key, URL: nil)
            }
            options.append(optionObj!)
        }
    }
    
    // MARK: actions
    
    @IBAction func btnDone_TouchedUpInside(_ sender: UIButton) {
        self.dismiss(animated: true) {
            
        }
    }
    
    // MARK: segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Identifiers.Segues.appInfoSelectionVC.rawValue {
            if let destinationVC = segue.destination as? AppInformationSelectionViewController, let option = selectedOption {
                destinationVC.name = option.name
                destinationVC.URL = option.URL
            }
        }
    }
    
    // MARK: table view
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.TableViewCells.AppInfo.rawValue, for: indexPath)
        let option = options[indexPath.row]
        cell.textLabel?.text = option.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let option = options[indexPath.row]
        selectedOption = option
        if ((selectedOption?.URL) != nil) {
            performSegue(withIdentifier: Identifiers.Segues.appInfoSelectionVC.rawValue, sender: self)
        } else {
            AlertManager.alert(withTitle: "No URL", withMessage: "We don't have this information available yet. Please check in later.", dismissTitle: "Cancel", inViewController: self)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    private class Option {
        var name: String!
        var URL: URL?
        
        init(name: String, URL: URL? = nil) {
            self.name = name
            self.URL = URL
        }
    }
}
