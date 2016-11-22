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
    @IBOutlet weak var availableDate: UILabel!
    @IBOutlet weak var monthlyPayment: UILabel!
    
    @IBOutlet weak var imgProperty: UIImageView!
    
    // MARK: variables
    
    var property: Property! = nil
    
    // MARK: life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
