//
//  PropertyTableViewCell.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class PropertyTableViewCell: UITableViewCell {
    
    // MARK: outlets
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var imgProperty: UIImageView!
    @IBOutlet weak var imgBlipPropertyAvailableIndicator: UIImageView!
    
    @IBOutlet weak var vwContent: UIView!
    
    // MARK: variables
    
    var property: Property! = nil
    
    // MARK: life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupImages()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topAndBottomBorders()
    }
    
    private func setupImages() {
        imgBlipPropertyAvailableIndicator.layer.cornerRadius = imgBlipPropertyAvailableIndicator.frame.width / 2
        imgBlipPropertyAvailableIndicator.layer.borderColor = UIColor.white.cgColor
        imgBlipPropertyAvailableIndicator.layer.borderWidth = 2
        
        imgProperty.layer.cornerRadius = imgProperty.frame.width / 2
    }
    
    private func topAndBottomBorders() {
//        let topBorder = CALayer()
//        topBorder.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: 1)
//        topBorder.backgroundColor = UIColor(colorLiteralRed: 221/255, green: 221/255, blue: 221/255, alpha: 0.9).cgColor
//        vwContent.layer.addSublayer(topBorder)
        
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: bounds.size.height-1, width: bounds.size.width, height: 0.5)
        bottomBorder.backgroundColor = UIColor(colorLiteralRed: 221/255, green: 221/255, blue: 221/255, alpha: 0.9).cgColor
        vwContent.layer.addSublayer(bottomBorder)
    }
}
