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
    
    class func mb(size: CGFloat) -> UIFont {
        return UIFont(name: "Muli-Bold", size: size)!
    }
    
    class func pfl(size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Light", size: size)!
    }
    
    class func pfr(size: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Regular", size: size)!
    }
    
    // Font Names = [["SFProText-Bold", "SFProText-Light", "SFProText-Regular", "SFProText-Semibold"]]
    class func sfpb(size: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Bold", size: size)!
    }
    
    class func sfpl(size: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Light", size: size)!
    }
    
    class func sfpr(size: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Regular", size: size)!
    }
    
    class func sfps(size: CGFloat) -> UIFont {
        return UIFont(name: "SFProText-Semibold", size: size)!
    }
}
