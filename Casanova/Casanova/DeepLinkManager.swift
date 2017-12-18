//
//  DeepLinkManager.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 12/17/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class DeepLinkManager {
    var actions: [DeepLinkAction]
    
    // MARK: - Init
    
    init(actions: [DeepLinkAction]) {
        self.actions = actions
    }
    
    // MARK: - Convenience Init for Universal Link / Deep Link / Notification
    
    convenience init?(withUniversalLink url: URL) {
        let actions = DeepLinkManager.resolveDeepLinkActions(fromUniversalLink: url)
        
        if let actions = actions {
            self.init(actions: actions)
        } else {
            return nil
        }
    }
    
    convenience init?(withDeepLink url: URL) {
        let actions = DeepLinkManager.resolveDeepLinkActions(fromDeepLink: url)
        
        if let actions = actions {
            self.init(actions: actions)
        } else {
            return nil
        }
    }
    
    convenience init?(withNotification url: URL) {
        let actions = DeepLinkManager.resolveDeepLinkActions(fromNotification: url)
        
        if let actions = actions {
            self.init(actions: actions)
        } else {
            return nil
        }
    }
    
    // MARK: - Utils
    
    class func resolveDeepLinkActions(fromUniversalLink url: URL) -> [DeepLinkAction]? {
        
        let domain = url.pathComponents[1]
        
        if domain == "topic" {
            // 1
            // sample url: https://tft.rocks/topic/314?from=singlemessage&isappinstalled=0#686
            let params = url.description.components(separatedBy: CharacterSet.init(charactersIn: "#"))
            if params.count > 1 {
                if let answerId = Int(params[1]) {
                    return [
                        DeepLinkAction(actionType: .answer, actionId: answerId)
                    ]
                }
            }
        }
        
        return nil
    }
    
    class func resolveDeepLinkActions(fromDeepLink url: URL) -> [DeepLinkAction]? {
        
        return nil
    }
    
    class func resolveDeepLinkActions(fromNotification url: URL) -> [DeepLinkAction]? {
        
        return nil
    }
}
