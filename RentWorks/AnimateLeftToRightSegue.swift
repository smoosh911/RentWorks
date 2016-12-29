//
//  AnimateLeftToRightSegue.swift
//  RentWorks
//
//  Created by Michael Perry on 12/28/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import Foundation
import QuartzCore

class AnimateLeftToRightSegue: UIStoryboardSegue {
    
    override func perform() {
        let src: UIViewController = self.source
        let dst: UIViewController = self.destination
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        src.navigationController!.view.layer.add(transition, forKey: kCATransition)
        src.navigationController!.pushViewController(dst, animated: false)
    }
}
