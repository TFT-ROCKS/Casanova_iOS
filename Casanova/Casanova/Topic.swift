//
//  Topic.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class Topic {
    // MARK: - Home Page
    var answersCount: Int
    var topicTitle: String
    var topicId: Int
    var status: Int
    var level: Int
    var tags: String
    var isDetailed: Bool
    
    init(answersCount: Int,
         topicTitle: String,
         topicId: Int,
         status: Int,
         level: Int,
         tags: String) {
        
        self.answersCount = answersCount
        self.topicTitle = topicTitle
        self.topicId = topicId
        self.status = status
        self.level = level
        self.tags = tags
        self.isDetailed = false
    }
    
    convenience init?(fromJson json: [String: Any]) {
        guard let answersCount = json["answersCount"] as? Int,
            let topicTitle = json["topicTitle"] as? String,
            let topicId = json["topicId"] as? Int,
            let status = json["status"] as? Int,
            let level = json["level"] as? Int,
            let tags = json["tags"] as? String
            else {
                let errorMessage = ErrorMessage(msg: "Error found, when parsing json, into topic")
                print(errorMessage.msg)
                return nil
        }
        self.init(answersCount: answersCount,
                  topicTitle: topicTitle,
                  topicId: topicId,
                  status: status,
                  level: level,
                  tags: tags)
    }
    
    // MARK: - Detail Page
    var answers: [Answer]?
    var user: User?
}
