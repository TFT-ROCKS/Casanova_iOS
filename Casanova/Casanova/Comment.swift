//
//  Comment.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class Comment {
    var commentId: Int
    var commentTitle: Int
    var position: String
    var createdAt: String
    var updatedAt: String
    var answerId: Int
    var userId: Int
    
    init(commentId: Int,
        commentTitle: Int,
        position: String,
        createdAt: String,
        updatedAt: String,
        answerId: Int,
        userId: Int) {
        
        self.commentId = commentId
        self.commentTitle = commentTitle
        self.position = position
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.answerId = answerId
        self.userId = userId
    }
}
