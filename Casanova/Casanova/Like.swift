//
//  Like.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class Like {
    var id: Int!
    var answerId: Int!
    var userId: Int!
    
    init(id: Int,
         answerId: Int,
         userId: Int) {
        
        self.id = id
        self.answerId = answerId
        self.userId = userId
    }
    
    convenience init?(fromJSON json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let answerId = json["answerId"] as? Int,
            let userId = json["userId"] as? Int
            else {
                return nil
        }
        self.init(id: id, answerId: answerId, userId: userId)
    }
}
