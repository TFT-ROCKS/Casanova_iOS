//
//  DeepLinkAction.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 12/17/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

enum DeepLinkActionType {
    case tab
    case topic
    case answer
}

struct DeepLinkAction: Equatable {
    let actionType: DeepLinkActionType
    let actionId: Int
    
    static func ==(lhs: DeepLinkAction, rhs: DeepLinkAction) -> Bool {
        return lhs.actionId == rhs.actionId && lhs.actionId == rhs.actionId
    }
}
