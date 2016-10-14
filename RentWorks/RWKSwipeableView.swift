//
//  RWKSwipableView.swift
//  CardSwipingTest
//
//  Created by Spencer Curtis on 9/29/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit

class RWKSwipeableView: UIView {
    
    var delegate: RWKSwipeableViewDelegate?
    var user: TestUser? {
        didSet {
            guard let user = user else { return }
            print("SwipeableView user: \(user.id)")
        }
    }
    
    
    
    var count = 0
    
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
        
        setupPanGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPanGestureRecognizer()
    }
    
    func beingDragged() {
        guard let sender = panGestureRecognizer,
            let senderView = sender.view,
            let superView = self.superview else { return }
        
        xFromCenter = sender.translation(in: senderView).x
        yFromCenter = sender.translation(in: senderView).y
        
        switch sender.state {
            
        case .began:
            UIView.animate(withDuration: 0.2, animations: {
                senderView.center = sender.location(in: superView)
                }, completion: { (complete) in
            })
        case .changed:
            count += 1
            
            if senderView.center.x > superView.center.x + 25 || senderView.center.x < superView.center.x  - 25 || count > 10  {
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
            count = 0
            rotationAngle = 0.0
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

protocol RWKSwipeableViewDelegate {
    func swipeAnimationsFor(swipeableView: UIView, inSuperview superview: UIView)
    func rightAnimationFor(swipeableView: UIView, inSuperview superview: UIView)
    func leftAnimationFor(swipeableView: UIView, inSuperview superview: UIView)
    func put(swipeableView: UIView, inCenterOf superview: UIView)
    func reset(swipeableView: UIView, inSuperview: UIView)
}


//extension RWKSwipeableViewDelegate {
//
//
//    func swipeAnimationsFor(swipeableView: UIView, inSuperview superview: UIView) {
//        if swipeableView.center.x > superview.center.x + 45 {
//            rightAnimationFor(swipeableView: swipeableView, inSuperview: superview)
//        } else if swipeableView.center.x < superview.center.x - 45 {
//            leftAnimationFor(swipeableView: swipeableView, inSuperview: superview)
//        } else {
//            put(swipeableView: swipeableView, inCenterOf: superview)
//        }
//    }
//
//    func rightAnimationFor(swipeableView: UIView, inSuperview superview: UIView) {
//        let finishPoint = CGPoint(x: CGFloat(700), y: superview.center.y - 100)
//        UIView.animate(withDuration: 0.7, animations: {
//            swipeableView.center = finishPoint
//            swipeableView.transform = CGAffineTransform(rotationAngle: self.degreesToRadians(degree: 90))
//        }) { (complete) in
//            self.reset(swipeableView: swipeableView, inSuperview: superview)
//        }
//
//    }
//
//    func leftAnimationFor(swipeableView: UIView, inSuperview superview: UIView) {
//        let finishPoint = CGPoint(x: CGFloat(-700), y: superview.center.y - 100)
//        UIView.animate(withDuration: 0.7, animations: {
//            swipeableView.center = finishPoint
//
//            swipeableView.transform = CGAffineTransform(rotationAngle: self.degreesToRadians(degree: -90))
//        }) { (complete) in
//            self.reset(swipeableView: swipeableView, inSuperview: superview)
//        }
//    }
//
//
//    func put(swipeableView: UIView, inCenterOf superview: UIView) {
//        UIView.animate(withDuration: 0.5) {
//            swipeableView.center = superview.center
//            swipeableView.transform = CGAffineTransform(rotationAngle: 0.0)
//        }
//    }
//
//
//    func reset(swipeableView: UIView, inSuperview: UIView) {
//        let constraints = inSuperview.constraints
//        swipeableView.removeFromSuperview()
//        inSuperview.addSubview(swipeableView)
//        inSuperview.addConstraints(constraints)
//
//        swipeableView.transform = CGAffineTransform(rotationAngle: 0.0)
//    }
//
//    func degreesToRadians(degree: Double) -> CGFloat {
//        return CGFloat(M_PI * (degree) / 180.0)
//    }
//}
