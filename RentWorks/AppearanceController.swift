//
//  AppearanceController.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/6/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation


class AppearanceController {
    
    static func appearanceFor(nextButton: UIButton) {
        nextButton.layer.cornerRadius = 5
        nextButton.layer.borderWidth = 0.2
        nextButton.layer.borderColor = UIColor.white.cgColor
    }
    
    static func appearanceFor(selectionButtons: [UIButton]) {
        for button in selectionButtons {
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.gray.cgColor
        }
    }
    
    static func appearanceFor(textFields: [UITextField]) {
        for textField in textFields {
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.gray.cgColor
        }
    }
    
    
}
