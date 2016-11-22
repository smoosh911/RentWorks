//
//  PropertyDetailsViewController.swift
//  RentWorks
//
//  Created by Michael Perry on 11/20/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit

class PropertyDetailsViewController: UIViewController {
    
    @IBOutlet weak var lblPropertyAddress: UILabel!
    
    @IBOutlet weak var imgProperty: UIImageView!
    
    var property: Property! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblPropertyAddress.text = property.address
        
        guard let profileImage = property.profileImages?.firstObject as? ProfileImage, let image = UIImage(data: profileImage.imageData as! Data) else { return }
        
        
        imgProperty.image = image
    }
    
    @IBAction func backNavigationButtonTapped(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}
