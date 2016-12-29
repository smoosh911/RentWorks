//
//  AppInformationSelectionViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 12/18/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class AppInformationSelectionViewController: UIViewController {
    
    // MARK: variables
    
    var name: String!
    var URL: URL!
    
    // MARK: outlets
    
    @IBOutlet weak var wbvwMain: UIWebView!
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = name
        let request = URLRequest(url: URL)
        wbvwMain.loadRequest(request)
    }
    
    // MARK: actions
    
    @IBAction func btnDone_TouchedUpInside(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
