//
//  RWKSwipableView.swift
//  CardSwipingTest
//
//  Created by Spencer Curtis on 9/29/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation

@objc protocol RWKSwipeableViewDelegate : NSObjectProtocol {
    func swipeLeftCompleteTransform(view: UIView)
    func swipeRightCompleteTransform(view: UIView)
    func resetFrontCardTransform(view: UIView)
    func beingDragged(gesture: UIPanGestureRecognizer)
    func updateCardUI()
    @objc optional func swipableView(_ swipableView: RWKSwipeableView, didSwipeOn cardEntity: Any)
    @objc optional func swipableView(_ swipableView: RWKSwipeableView, didAccept cardEntity: Any)
    @objc optional func swipableView(_ swipableView: RWKSwipeableView, didReject cardEntity: Any)
}

class RWKSwipeableView: UIView {
    
    var delegate: RWKSwipeableViewDelegate?
    
    var property: Property? 
    var renter: Renter?
    
    var dragCount = 0
    
    var rotationAngle: CGFloat = 0.0
    var xFromCenter: CGFloat = 0.0
    var yFromCenter: CGFloat = 0.0
    var previousX: CGFloat = 0.0
    
    var constraintArray: [NSLayoutConstraint] = []
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var originalPoint: CGPoint = CGPoint.zero
    
    func setupPanGestureRecognizer() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(beingDragged))
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPanGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPanGestureRecognizer()
    }
    
    func beingDragged() {
        guard let delegate = delegate else { return }
        let gesture = panGestureRecognizer!
        
        delegate.beingDragged(gesture: gesture)
        
        let label = gesture.view!
        
        if gesture.state == UIGestureRecognizerState.ended {
            guard let superView = self.superview else { return }
            var acceptedOrRejected = ""
            let swipeDistanceFromEdgeRequired: CGFloat = 75
        
            if label.center.x < swipeDistanceFromEdgeRequired {
                acceptedOrRejected = "rejected"
                if let renter = self.renter {
                    if let swipped = delegate.swipableView?(self, didSwipeOn: renter), let rejected = delegate.swipableView?(self, didReject: renter) { swipped; rejected}
                } else if let property = self.property {
                    if let swipped = delegate.swipableView?(self, didSwipeOn: property), let rejected = delegate.swipableView?(self, didReject: property) { swipped; rejected }
                }
                
                UIView.animate(withDuration: 0.2, animations: {
                    delegate.swipeLeftCompleteTransform(view: label)
                }, completion: { (true) in
                    delegate.updateCardUI()
                    delegate.resetFrontCardTransform(view: label)
                })
            } else if label.center.x > superView.bounds.width - swipeDistanceFromEdgeRequired {
                acceptedOrRejected = "accepted"
                if let renter = self.renter {
                    if let swipped = delegate.swipableView?(self, didSwipeOn: renter), let accepted = delegate.swipableView?(self, didAccept: renter) { swipped; accepted}
                } else if let property = self.property {
                    if let swipped = delegate.swipableView?(self, didSwipeOn: property), let accepted = delegate.swipableView?(self, didAccept: property) { swipped; accepted }
                }
                UIView.animate(withDuration: 0.2, animations: {
                    delegate.swipeRightCompleteTransform(view: label)
                }, completion: { (true) in
                    delegate.updateCardUI()
                    delegate.resetFrontCardTransform(view: label)
                })
            } else {
                UIView.animate(withDuration: 0.1, animations: {
                    delegate.resetFrontCardTransform(view: label)
                })
            }
            print(acceptedOrRejected)
        }
    }
}
