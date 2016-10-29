//
//  UIButtonExtensions.swift
//  RentWorks
//
//  Created by Spencer Curtis on 10/28/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation

extension UIButton {
    
    
    // These functions should only be used on the arrow buttons during the account creation process.
    
    func setOffScreenToRight() {
        UIView.animate(withDuration: 0.0000001, animations: {
            
            self.center.x = self.center.x + 200
            
        })
    }
    
    
    func slideFromRight() {
        self.alpha = 1
        UIView.animate(withDuration: 1, animations: {
            
            self.center.x -= 200
            
        })
    }
    
    
}
