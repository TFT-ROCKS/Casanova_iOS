//
//  Topic.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class Topic {
    var likeCount: Int
    var likeUsers: String
    var answersCount: Int
    var topicTitle: String
    var answerTitle: String
    var updatedAt: String
    var userId: Int
    var userName: String
    var topicId: Int
    var answerId: Int
    var status: Int
    var level: Int
    var tags: String
    
    init(likeCount: Int,
         likeUsers: String,
         answersCount: Int,
         topicTitle: String,
         answerTitle: String,
         updatedAt: String,
         userId: Int,
         userName: String,
         topicId: Int,
         answerId: Int,
         status: Int,
         level: Int,
         tags: String) {
        
        self.likeCount = likeCount
        self.likeUsers = likeUsers
        self.answersCount = answersCount
        self.topicTitle = topicTitle
        self.answerTitle = answerTitle
        self.updatedAt = updatedAt
        self.userId = userId
        self.userName = userName
        self.topicId = topicId
        self.answerId = answerId
        self.status = status
        self.level = level
        self.tags = tags
    }
    
    convenience init?(fromJson json: [String: Any]) {
        guard let likeCount = json["likeCount"] as? Int,
            let likeUsers = json["likeUsers"] as? String,
            let answersCount = json["answersCount"] as? Int,
            let topicTitle = json["topicTitle"] as? String,
            let answerTitle = json["answerTitle"] as? String,
            let updatedAt = json["updatedAt"] as? String,
            let userId = json["userId"] as? Int,
            let userName = json["userName"] as? String,
            let topicId = json["topicId"] as? Int,
            let answerId = json["answerId"] as? Int,
            let status = json["status"] as? Int,
            let level = json["level"] as? Int,
            let tags = json["tags"] as? String
            else {
                let errorMessage = ErrorMessage(msg: "Error found, when parsing json, into topic")
                print(errorMessage.msg)
                return nil
        }
        self.init(likeCount: likeCount,
                  likeUsers: likeUsers,
                  answersCount: answersCount,
                  topicTitle: topicTitle,
                  answerTitle: answerTitle,
                  updatedAt: updatedAt,
                  userId: userId,
                  userName: userName,
                  topicId: topicId,
                  answerId: answerId,
                  status: status,
                  level: level,
                  tags: tags)
    }
}
