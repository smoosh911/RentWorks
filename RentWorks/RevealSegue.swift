//
//  CardDetailViewSegue.swift
//  RentWorks
//
//  Created by Michael Perry on 12/29/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import QuartzCore

class RevealSegue: UIStoryboardSegue {
    
    override func perform() {
        let src: UIViewController = self.source
        let dst: UIViewController = self.destination
        
        src.present(dst, animated: false) {
            
        }
    }
}
