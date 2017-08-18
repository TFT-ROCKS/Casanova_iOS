//
//  DifficultyView.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/23/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class DifficultyView: UIView {
    var level: Int = 0
    var mode: TopicHeaderViewMode
    
    convenience init(frame: CGRect, level: Int) {
        self.init(frame: frame, level: level, mode: nil)
    }
    
    init(frame: CGRect, level: Int, mode: TopicHeaderViewMode?) {
        self.mode = mode ?? .plain
        super.init(frame: frame)
        self.level = level
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        // rects: w*h --> 4*4, 4*6, 4*8, 4*10, 4*12, boder-width = 0.3pt
        // horizontal space: (self.width - (4+1.2) * 5) / 4
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setLineWidth(0.6)
        let color = (mode == .plain) ? UIColor(red: 75 / 255.0, green: 205 / 255.0, blue: 237 / 255.0, alpha: 1).cgColor : UIColor.white.cgColor
        ctx?.setStrokeColor(color)
        
        let height = self.bounds.size.height
        let width = self.bounds.size.width
        let rectWidth: CGFloat = 4.0 + 0.6
        let space: CGFloat = (width - (5.0 * rectWidth)) / 4.0
        let verticalOffSet: CGFloat = 3.0
        
        let rect1 = CGRect(x: 0, y: height - 4 - verticalOffSet, width: 4, height: 4)
        let rect2 = CGRect(x: 1 * (rectWidth + space), y: height - 6 - verticalOffSet, width: 4, height: 6)
        let rect3 = CGRect(x: 2 * (rectWidth + space), y: height - 8 - verticalOffSet, width: 4, height: 8)
        let rect4 = CGRect(x: 3 * (rectWidth + space), y: height - 10 - verticalOffSet, width: 4, height: 10)
        let rect5 = CGRect(x: 4 * (rectWidth + space), y: height - 12 - verticalOffSet, width: 4, height: 12)
        
        ctx?.addRects([rect1, rect2, rect3, rect4, rect5])
        ctx?.strokePath()
        ctx?.setFillColor(color)
        if level >= 1 {
            ctx?.fill(rect1)
        }
        if level >= 2 {
            ctx?.fill(rect2)
        }
        if level >= 3 {
            ctx?.fill(rect3)
        }
        if level >= 4 {
            ctx?.fill(rect4)
        }
        if level >= 5 {
            ctx?.fill(rect5)
        }
    }
}
