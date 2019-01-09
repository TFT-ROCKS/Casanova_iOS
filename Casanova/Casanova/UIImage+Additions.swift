//
//  UIImage+Additions.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 12/12/18.
//  Copyright © 2018 Xiaoyu Guo. All rights reserved.
//

import UIKit

extension UIImage {
    
    class func oriImage(named name: String) -> UIImage? {
        return UIImage(named: name)?.withRenderingMode(.alwaysOriginal)
    }
    
}
