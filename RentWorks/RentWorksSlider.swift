//
//  Slider.swift
//  RentWorks
//
//  Created by Candice Davis on 2/14/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation

class RentWorksSlider: UISlider {
    
    @IBInspectable var trackHeight: CGFloat = 7
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: trackHeight))
        
    }
}
