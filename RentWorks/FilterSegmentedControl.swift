//
//  SegmentedControler.swift
//  RentWorks
//
//  Created by Candice Davis on 2/14/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import Foundation

@IBDesignable class FilterSegmentedControl: UISegmentedControl {
    
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
        
        let textAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName as NSObject: textColor,
            NSFontAttributeName as NSObject: UIFont(name: "SF UI Text", size: 14.0)!,
//            NSFontAttributeName as NSObject : UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightMedium)
        ]
        
        FilterSegmentedControl.appearance().setTitleTextAttributes(textAttributes, for: UIControlState.selected)
        FilterSegmentedControl.appearance().setTitleTextAttributes(textAttributes, for: UIControlState.normal)
        
//        setDividerImage(UIImage(), forLeftSegmentState: UIControlState.normal, rightSegmentState: UIControlState.normal, barMetrics: UIBarMetrics.default)
    }

    
}
