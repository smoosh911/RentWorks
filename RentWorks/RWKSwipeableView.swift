//
//  RWKSwipableView.swift
//  CardSwipingTest
//
//  Created by Spencer Curtis on 9/29/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit

protocol RWKSwipeableViewDelegate {
    func swipeLeftCompleteTransform(view: UIView)
    func swipeRightCompleteTransform(view: UIView)
    func resetFrontCardTransform(view: UIView)
    func beingDragged(gesture: UIPanGestureRecognizer)
    func updateUIElementsForPropertyCards()
    func updateUIElementsForRenterCards()
    func resetData()
    func likeUser()
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
        if delegate == nil {
            return
        }
        
        let gesture = panGestureRecognizer!
        
        delegate!.beingDragged(gesture: gesture)
        
        let label = gesture.view!
        
        if gesture.state == UIGestureRecognizerState.ended {
            
            var acceptedOrRejected = ""
            let swipeDistanceRequired: CGFloat = 150.0
        
            if label.center.x < swipeDistanceRequired {
                acceptedOrRejected = "rejected"
                UIView.animate(withDuration: 0.2, animations: {
                    self.delegate!.swipeLeftCompleteTransform(view: label)
                }, completion: { (true) in
                    if UserController.currentUserType == "renter" {
                        self.delegate!.updateUIElementsForPropertyCards()
                    } else if UserController.currentUserType == "landlord" {
                        self.delegate!.updateUIElementsForRenterCards()
                    }
                    self.delegate!.resetFrontCardTransform(view: label)
                })
            } else if label.center.x > self.bounds.width - swipeDistanceRequired {
                acceptedOrRejected = "accepted"
                UIView.animate(withDuration: 0.2, animations: {
                    self.delegate!.swipeRightCompleteTransform(view: label)
                }, completion: { (true) in
                    if UserController.currentUserType == "renter" {
                        self.delegate!.updateUIElementsForPropertyCards()
                    } else if UserController.currentUserType == "landlord" {
                        self.delegate!.updateUIElementsForRenterCards()
                    }
                    self.delegate!.resetFrontCardTransform(view: label)
                })
            } else {
                UIView.animate(withDuration: 0.1, animations: {
                    self.delegate!.resetFrontCardTransform(view: label)
                })
            }
            print(acceptedOrRejected)
        }
    }
}
