//
//  UIColor+Addition.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/11/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

extension UIColor {
    @nonobjc class var tftLightBlueGrey: UIColor {
        return UIColor(red: 217.0 / 255.0, green: 225.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var tftLightblue: UIColor {
        return UIColor(red: 75.0 / 255.0, green: 205.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var tftDuckEggBlue: UIColor {
        return UIColor(red: 232.0 / 255.0, green: 248.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var tftPaleGrey: UIColor {
        return UIColor(red: 248.0 / 255.0, green: 250.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var tftCoolGrey: UIColor {
        return UIColor(red: 173.0 / 255.0, green: 179.0 / 255.0, blue: 187.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var tftBlack: UIColor {
        return UIColor(white: 0.0, alpha: 1.0)
    }
    
    @nonobjc class var tftFadedBlue: UIColor {
        return UIColor(red: 91.0 / 255.0, green: 140.0 / 255.0, blue: 185.0 / 255.0, alpha: 1.0)
    }
    
    @nonobjc class var tftCharcoalGrey: UIColor {
        return UIColor(red: 74.0 / 255.0, green: 74.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
    }
    
    class var shadowColor: UIColor { return tftLightBlueGrey }
    class var brandColor: UIColor { return tftLightblue }
    class var bgdColor: UIColor { return tftPaleGrey }
    class var bodyTextColor: UIColor { return tftBlack }
    class var nonBodyTextColor: UIColor { return tftCharcoalGrey }
    class var navTintColor: UIColor { return tftCoolGrey }
}
