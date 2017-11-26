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
            let answerId = json["AnswerId"] as? Int,
            let userId = json["UserId"] as? Int
            else {
                return nil
        }
        self.init(id: id, answerId: answerId, userId: userId)
    }
    
    convenience init?(fromLikedAnswersJSON json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let userId = json["UserId"] as? Int
            else {
                return nil
        }
        self.init(id: id, answerId: -1, userId: userId)
    }
    
    convenience init?(fromSingleAnswerJSON json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let userIdJSON = json["User"] as? [String: Any],
            let userId = userIdJSON["id"] as? Int
            else {
                return nil
        }
        self.init(id: id, answerId: -1, userId: userId)
    }
}
