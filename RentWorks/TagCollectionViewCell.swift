//
//  TagCollectionViewCell.swift
//  RentWorks
//
//  Created by Candice Davis on 2/15/17.
//  Copyright © 2017 Michael Perry. All rights reserved.
//

import UIKit
class TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tagLabel: UILabel!
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return tagLabel.intrinsicContentSize
    }
}
