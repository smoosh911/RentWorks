

//
//  AppearanceController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/13/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

class AppearanceController {
    
    static func appearanceFor(textFields: [UITextField]) {
        for textField in textFields {
//            textField.layer.borderColor = UIColor.white.cgColor
            textField.tintColor = vengaOrangeColor
//            textField.layer.borderWidth = 0.6
//            textField.layer.cornerRadius = 5
        }
    }
    
    static func appearanceFor(navigationController: UINavigationController?) {
        
        navigationController?.presentTransparentNavigationBar()
    }
    
    static let vengaYellowColor = UIColor(red: 0.976, green: 0.937, blue: 0.110, alpha: 1.00)
    
    static let vengaOrangeColor = UIColor(displayP3Red: 0.906, green: 0.510, blue: 0.255, alpha: 1.0)
    
    static let viewButtonPressedColor = UIColor(displayP3Red: 0.844, green: 0.467, blue: 0.252, alpha: 1.00)
    
    // For the credit rating labels, because the text isn't a part of the button, the slight change in color must be done manually.
    
    static let buttonPressedColor = UIColor(red: 0.911, green: 0.920, blue: 0.920, alpha: 1.00)
}


extension UINavigationController {
    
    public func presentTransparentNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for:UIBarMetrics.default)
        navigationBar.isTranslucent = true
        navigationBar.tintColor = .white
        navigationBar.shadowImage = UIImage()
        setNavigationBarHidden(false, animated:true)
    }
    
    public func hideTransparentNavigationBar() {
        setNavigationBarHidden(true, animated:false)
        navigationBar.setBackgroundImage(UINavigationBar.appearance().backgroundImage(for: UIBarMetrics.default), for:UIBarMetrics.default)
        navigationBar.isTranslucent = UINavigationBar.appearance().isTranslucent
        navigationBar.shadowImage = UINavigationBar.appearance().shadowImage
    }
}
