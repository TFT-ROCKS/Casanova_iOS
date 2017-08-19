//
//  Utils.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/9/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class Utils {
    
    /// run block on main thread asyc
    static func runOnMainThread(block: @escaping (Void) -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
    static func doesCurrentUserLikeThisAnswer(_ answer: Answer) -> Bool {
        let currentUser = Environment.shared.currentUser
        for like in answer.likes {
            if currentUser?.id == like.userId {
                return true
            }
        }
        return false
    }
    
    static func likeIdFromAnswer(_ answer: Answer) -> Int? {
        let currentUser = Environment.shared.currentUser
        for like in answer.likes {
            if currentUser?.id == like.userId {
                return like.id
            }
        }
        return nil
    }
}
