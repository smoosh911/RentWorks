//
//  AlertManager.swift
//  RentWorks
//
//  Created by Michael Perry on 12/2/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

// needs work: all alerts should use the alert manager to minimize code
class AlertManager {
    
    static func alert(withTitle title: String, withMessage message: String, dismissTitle: String, inViewController targetVC: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.view.tintColor = .black
        
        let dismissAction = UIAlertAction(title: dismissTitle, style: .cancel, handler: nil)
        
        alert.addAction(dismissAction)
        targetVC.present(alert, animated: true, completion: nil)
    }
}
