

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
            textField.tintColor = customOrangeColor
//            textField.layer.borderWidth = 0.6
//            textField.layer.cornerRadius = 5
        }
    }
    
    static func appearanceFor(navigationController: UINavigationController?) {
        
        navigationController?.presentTransparentNavigationBar()
    }
    
    static let customOrangeColor = UIColor(red: 0.961, green: 0.482, blue: 0.220, alpha: 1.00)
    
    static let viewButtonPressedColor = UIColor(red: 0.807, green: 0.391, blue: 0.000, alpha: 1.00)
    
    // For the credit rating labels, because the text isn't a part of the button, the slight change in color must be done manually.
    static let buttonPressedColor = UIColor(red: 0.911, green: 0.920, blue: 0.920, alpha: 1.00)
    
}


extension UINavigationController {
    
    public func presentTransparentNavigationBar() {
        navigationBar.setBackgroundImage(UIImage(), for:UIBarMetrics.default)
        navigationBar.isTranslucent = true
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
