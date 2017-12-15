//
//  AnimatedCircleView.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 11/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

let pi: CGFloat = CGFloat(Double.pi)
let startAngle: CGFloat = (3.0 * pi) / 2.0

// ----
// Math class to handle fun circle forumals
// ----
class Math {
    static func percentToRadians(_ percentComplete: CGFloat) -> CGFloat {
        let degrees = (percentComplete/100) * 360
        return startAngle + (degrees * (pi/180))
    }
}

protocol AnimatedCircleViewDelegate: class {
    func animatedCircleViewDidTapped(_ tap: UITapGestureRecognizer)
}

class AnimatedCircleView: UIView, CAAnimationDelegate, UIGestureRecognizerDelegate {
    
    let percentComplete: CGFloat = 100
    
    var filledLayer: CAShapeLayer!
    var strokeColor: CGColor!
    var fillColor: CGColor!
    var maskLayer: CAShapeLayer!
    
    weak var delegate: AnimatedCircleViewDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, strokeColor: CGColor, fillColor: CGColor) {
        super.init(frame: frame)
        
        self.strokeColor = strokeColor
        self.fillColor = fillColor
        
        // tap gesture added to content view
        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        tgr.delegate = self
        addGestureRecognizer(tgr)
    }
    
    override func layoutSubviews() {
        let endAngle = Math.percentToRadians(percentComplete)
        
        // ----
        // Create oval bezier path and layer (outter circle)
        // ----
        let outterOvalPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))
        let outterCircleStrokeLayer = CAShapeLayer()
        outterCircleStrokeLayer.path = outterOvalPath.cgPath
        outterCircleStrokeLayer.lineWidth = 2
        outterCircleStrokeLayer.fillColor = UIColor.clear.cgColor
        outterCircleStrokeLayer.strokeColor = fillColor
        
        // ----
        // Create oval bezier path and layer
        // ----
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: 10, y: 10, width: bounds.width - 20, height: bounds.height - 20))
        let circleStrokeLayer = CAShapeLayer()
        circleStrokeLayer.path = ovalPath.cgPath
        circleStrokeLayer.lineWidth = 2
        circleStrokeLayer.fillColor = UIColor.clear.cgColor
        circleStrokeLayer.strokeColor = strokeColor
        
        // ----
        // Create filled bezier path and layer
        // ----
        let filledPathStart = UIBezierPath(arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2), radius: bounds.width / 2 - 10, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        filledPathStart.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2))
        filledLayer = CAShapeLayer()
        filledLayer.path = filledPathStart.cgPath
        filledLayer.fillColor = fillColor
        
        // ----
        // Add any layers to container view
        // ----
        backgroundColor = UIColor.white
        filledLayer.frame = bounds
        
        layer.addSublayer(outterCircleStrokeLayer)
        layer.addSublayer(circleStrokeLayer)
        layer.addSublayer(filledLayer)
        filledLayer.isHidden = true
    }
    
    func viewTapped(_ tap: UITapGestureRecognizer) {
        delegate.animatedCircleViewDidTapped(tap)
    }
    
    func animateForRecording(duration: Float, toValue: Float) {
        let endAngle = Math.percentToRadians(percentComplete)
        
        maskLayer = CAShapeLayer()
        
        let maskWidth: CGFloat = filledLayer.frame.size.width
        let maskHeight: CGFloat = filledLayer.frame.size.height
        let centerPoint: CGPoint = CGPoint(x: maskWidth / 2, y: maskHeight / 2)
        let radius: CGFloat = CGFloat(sqrtf(Float(maskWidth * maskWidth + maskHeight * maskHeight)) / 2)
        
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        maskLayer.lineWidth = radius
        
        let arcPath: CGMutablePath = CGMutablePath()
        arcPath.move(to: CGPoint(x: centerPoint.x, y: centerPoint.y - radius / 2))
        arcPath.addArc(center: centerPoint, radius: radius / 2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        maskLayer.path = arcPath
        maskLayer.strokeEnd = 0
        
        filledLayer.isHidden = false
        filledLayer.mask = maskLayer
        filledLayer.mask!.frame = filledLayer.frame
        
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.duration = CFTimeInterval(duration)
        anim.delegate = self
        
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        anim.fillMode = kCAFillModeForwards
        anim.isRemovedOnCompletion = false
        anim.autoreverses = false
        anim.toValue = toValue
        anim.repeatCount = 1.0
        
        maskLayer.add(anim, forKey: "strokeEnd")
    }
    
    func animateForUploading(with percent: Float) {
        animateForRecording(duration: 0.0001, toValue: percent)
    }
    
    func reset() {
        if maskLayer == nil { return }
        maskLayer.removeAnimation(forKey: "strokeEnd")
    }
    
}
