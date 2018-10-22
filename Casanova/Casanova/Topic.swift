//
//  Topic.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class Topic {
    // MARK: - Keys
    static let ID = "id"
    static let TITLE = "title"
    static let LEVEL = "level"
    static let CREATED_AT = "createdAt"
    static let UPDATED_AT = "updatedAt"
    static let USER_ID = "UserId"
    static let IS_TRENDING = "isTrending"
    static let TASK = "task"
    static let STATUS = "status"
    static let CHINESE_TITLE = "chineseTitle"
    static let TAGS = "tags"
    static let ANSWER_COUNT = "answer_count"
    
    // MARK: - Home Page
    var id: Int
    var answersCount: Int
    var title: String
    var chineseTitle: String?
    var level: Int
    var status: Int
    var tags: String
    var isTrending: Int
    var answerPictureUrl: String?
    
    init(answersCount: Int,
         title: String,
         chineseTitle: String?,
         id: Int,
         status: Int,
         level: Int,
         tags: String,
         answerPictureUrl: String?,
         isTrending: Int) {
        
        self.answersCount = answersCount
        self.title = title
        self.chineseTitle = chineseTitle
        self.id = id
        self.status = status
        self.level = level
        self.tags = tags
        self.answerPictureUrl = answerPictureUrl
        self.isTrending = isTrending
    }
    
    convenience init?(fromJson json: [String: Any]) {
        guard
            let title = json[Topic.TITLE] as? String,
            let id = json[Topic.ID] as? Int
            else {
                return nil
        }
        
        let answersCount = json[Topic.ANSWER_COUNT] as? Int ?? 0
        let level = json[Topic.LEVEL] as? Int ?? 0
        let tags = json[Topic.TAGS] as? String ?? "others"
        let isTrending = json[Topic.IS_TRENDING] as? Int ?? 0
        let status = json[Topic.STATUS] as? Int ?? 0
        let chineseTitle = json[Topic.CHINESE_TITLE] as? String
        let answerPictureUrl: String? = nil // nil for now
        
        self.init(answersCount: answersCount,
                  title: title,
                  chineseTitle: chineseTitle,
                  id: id,
                  status: status,
                  level: level,
                  tags: tags,
                  answerPictureUrl: answerPictureUrl,
                  isTrending: isTrending)
    }
    
    convenience init?(fromSingleAnswerJSON json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let level = json["level"] as? Int,
            let isTrending = json["isTrending"] as? Int
            else {
                return nil
        }
        
        let chineseTitle = json["topicChineseTitle"] as? String
        let answerPictureUrl = json["answerPictureUrl"] as? String
        
        self.init(answersCount: 1,
                  title: title,
                  chineseTitle: chineseTitle,
                  id: id,
                  status: 1,
                  level: level,
                  tags: "",
                  answerPictureUrl: answerPictureUrl,
                  isTrending: isTrending)
    }
    
    convenience init?(fromLikedAnswersJSON json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let level = json["level"] as? Int,
            let status = json["status"] as? Int,
            let isTrending = json["isTrending"] as? Int,
            let answers = json["Answers"] as? [Any],
            let tags = json["Tags"] as? [Any]
            else {
                return nil
        }
        let answersCount = answers.count
        var tagsArr: [String] = []
        for tag in tags {
            guard let tag = tag as? [String: Any] else { return nil }
            if let tagString = tag["title"] as? String {
                tagsArr.append(tagString)
            }
        }
        let tagsStr = tagsArr.joined(separator: ",")
        let chineseTitle = json["topicChineseTitle"] as? String
        let answerPictureUrl = json["answerPictureUrl"] as? String
        self.init(answersCount: answersCount,
                  title: title,
                  chineseTitle: chineseTitle,
                  id: id,
                  status: status,
                  level: level,
                  tags: tagsStr,
                  answerPictureUrl: answerPictureUrl,
                  isTrending: isTrending)
    }
}
