//
//  Comment.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class Comment {
    var id: Int
    var title: String
    var createdAt: String
    var user: User
    
    init?(id: Int,
          title: String,
          createdAt: String,
          user: User?) {
        
        guard let user = user else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.user = user
    }
    
    convenience init?(fromJSON json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let createdAt = json["createdAt"] as? String,
            let user = json["user"] as? [String: Any]
            else {
                return nil
        }
        self.init(id: id, title: title, createdAt: createdAt, user: User(json: user))
    }
}
