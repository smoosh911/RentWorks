//
//  RWKSwipableView.swift
//  CardSwipingTest
//
//  Created by Spencer Curtis on 9/29/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit

class RWKSwipeableView: UIView {
    
    weak var delegate: RWKSwipeableViewDelegate?
    var user: TestUser?
    
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
        guard let superView = self.superview else { return }
        constraintArray = superView.constraints
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        hideDropShadow()
        setupPanGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        hideDropShadow()
        setupPanGestureRecognizer()
    }
    
    func showDropShadow() {
        UIView.animate(withDuration: 1) { 
            self.shadowOpacity = 0.3
        }
    }
    
    func hideDropShadow() {
        UIView.animate(withDuration: 1) {
            self.shadowOpacity = 0.0
            self.shadowOffset = CGPoint(x: 0, y: 0)
        }
    }
    
    func beingDragged() {
        guard let sender = panGestureRecognizer,
            let senderView = sender.view,
            let superView = self.superview else { return }
        
        xFromCenter = sender.translation(in: senderView).x
        yFromCenter = sender.translation(in: senderView).y
        
        switch sender.state {
            
        case .began:
            showDropShadow()
            UIView.animate(withDuration: 0.2, animations: {
                senderView.center = sender.location(in: superView)
                }, completion: { (complete) in
            })
        case .changed:
            dragCount += 1
            
            if senderView.center.x > superView.center.x + 25 || senderView.center.x < superView.center.x  - 25 || dragCount > 10  {
                if senderView.center.x > previousX {
                    rotationAngle += 0.01
                } else if senderView.center.x < previousX {
                    rotationAngle -= 0.01
                }
                UIView.animate(withDuration: 0.1, animations: {
                    senderView.transform = CGAffineTransform(rotationAngle: self.rotationAngle)
                    
                    }, completion: nil)
                previousX = senderView.center.x
                
            }
            senderView.center = sender.location(in: superView)
            break
            
        case .ended:
            if sender.velocity(in: superView).x > 200 || sender.velocity(in: superView).y > 200.0 || sender.velocity(in: superView).x < -200.0 || sender.velocity(in: superView).y < -200.0 {
                
                delegate?.swipeAnimationsFor(swipeableView: self, inSuperview: superView)
            } else {
                delegate?.put(swipeableView: self, inCenterOf: superView)
                delegate?.reset(swipeableView: self, inSuperview: superView)
            }
            dragCount = 0
            rotationAngle = 0.0
            self.hideDropShadow()
            break
        case .possible:
            break
        case .cancelled:
            break
        case .failed:
            break
            
        }
        
    }
}

protocol RWKSwipeableViewDelegate: class {
    func swipeAnimationsFor(swipeableView: UIView, inSuperview superview: UIView)
    func rightAnimationFor(swipeableView: UIView, inSuperview superview: UIView)
    func leftAnimationFor(swipeableView: UIView, inSuperview superview: UIView)
    func put(swipeableView: UIView, inCenterOf superview: UIView)
    func reset(swipeableView: UIView, inSuperview: UIView)
}
