

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
            textField.layer.borderColor = UIColor.white.cgColor
            textField.tintColor = UIColor.white
            textField.layer.borderWidth = 0.6
            textField.layer.cornerRadius = 5
        }
    }
    
    static func appearanceFor(navigationController: UINavigationController?) {
        
        navigationController?.presentTransparentNavigationBar()
    }
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
