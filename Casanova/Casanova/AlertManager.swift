//
//  AlertManager.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 11/26/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

class AlertManager {
    class func alertController(title: String,
                               msg: String,
                               style: UIAlertControllerStyle,
                               actionT1: String,
                               style1: UIAlertActionStyle,
                               handler1: ((UIAlertAction) -> Void)?,
                               actionT2: String,
                               style2: UIAlertActionStyle,
                               handler2: ((UIAlertAction) -> Void)?,
                               viewForPopover: UIView
        ) -> UIAlertController{
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: style)
        let action1 = UIAlertAction(title: actionT1, style: style1, handler: handler1)
        let action2 = UIAlertAction(title: actionT2, style: style2, handler: handler2)
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = viewForPopover
            popoverController.sourceRect = CGRect(x: viewForPopover.bounds.midX, y: viewForPopover.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        return alertController
    }
}
