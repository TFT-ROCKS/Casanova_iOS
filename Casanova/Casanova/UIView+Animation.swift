//
//  UIView+Animation.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/11/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

// MARK: - UIView extension
extension UIView {
    /**
     Fade in a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeIn(withDuration duration: TimeInterval = 1.0, withCompletionBlock block: ((Bool) -> Swift.Void)? = nil) {
        self.isHidden = false
        self.alpha = 0.0
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        }, completion: { success in
            block?(success)
        })
    }
    
    /**
     Fade out a view with a duration
     
     - parameter duration: custom animation duration
     */
    func fadeOut(withDuration duration: TimeInterval = 1.0, withCompletionBlock block: ((Bool) -> Swift.Void)? = nil) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        }, completion: { success in
            self.isHidden = true
            block?(success)
        })
    }
    
    
    func blink(withDuration duration: TimeInterval = 2.0, withDelay delay: TimeInterval = 0.0, withCOmpletionBlock block: ((Bool) -> Swift.Void)? = nil) {
        self.alpha = 1.0
        UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction], animations: {
            self.alpha = 0.6
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { success in
            block?(success)
        })
    }
    
    func stopBlink() {
        self.alpha = 1.0
        self.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.layer.removeAllAnimations()
    }
}
