//
//  SegmentedControler.swift
//  RentWorks
//
//  Created by Candice Davis on 2/14/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation

@IBDesignable class SegmentedControl: UISegmentedControl {
    
    @IBInspectable var height: CGFloat = 34
    @IBInspectable var background: UIColor = UIColor.clear
    @IBInspectable var tint: UIColor = UIColor(red:0.95, green:0.96, blue:0.97, alpha:1.0)
    @IBInspectable var borderColor: UIColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
    @IBInspectable var textColor = UIColor(red:0.15, green:0.16, blue:0.24, alpha:1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupUI()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        setupUI()
    }
    
    func setupUI() {
        layer.cornerRadius = 0.5
        
        let centerSave = center
        frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: height)
        center = centerSave
        
        layer.borderColor = borderColor.cgColor
        backgroundColor = background
        tintColor = tint
        
        SegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: textColor], for: UIControlState.selected)
        SegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: textColor], for: UIControlState.normal)
//        setDividerImage(UIImage(), forLeftSegmentState: UIControlState.normal, rightSegmentState: UIControlState.normal, barMetrics: UIBarMetrics.default)
    }

    
}
