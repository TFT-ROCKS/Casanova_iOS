//
//  UIFont+Addition.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/18/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

extension UIFont {

    class func mr(size: CGFloat) -> UIFont {
        return UIFont(name: "Muli", size: size)!
    }
    
    class func pfl(size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Light", size: size)!
    }
    
    class func pfr(size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Regular", size: size)!
    }
    
}
