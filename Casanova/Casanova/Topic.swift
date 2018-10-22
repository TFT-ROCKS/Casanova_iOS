//
//  Topic.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class Topic {
//    ▿ 0 : 2 elements
//    - key : topic_id
//    - value : 11
//    ▿ 1 : 2 elements
//    - key : answer_count
//    - value : 1
//    ▿ 2 : 2 elements
//    - key : topic_title
//    - value : Usually, novels, magazines and poetry are considered the three major forms of literature. Which one do you prefer and why?
//    ▿ 3 : 2 elements
//    - key : topic_level
//    - value : 2
//    ▿ 4 : 2 elements
//    - key : topic_status
//    - value : 1
//    ▿ 5 : 2 elements
//    - key : topic_chinese_title
//    - value : 通常，小说、杂志和诗歌被认为是文学的三种主要形式。你喜欢哪一个，解释你为什么喜欢这种文学形式？。
//    ▿ 6 : 2 elements
//    - key : topic_tags
//    - value : others
//    ▿ 7 : 2 elements
//    - key : topic_isTrending
//    - value : 0
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
    var isDetailed: Bool
    
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
        self.isDetailed = false
    }
    
    convenience init?(fromJson json: [String: Any]) {
        guard
            let title = json["topic_title"] as? String,
            let id = json["topic_id"] as? Int
            else {
                return nil
        }
        
        let answersCount = json["answer_count"] as? Int ?? 0
        let level = json["topic_level"] as? Int ?? 0
        let tags = json["topic_tags"] as? String ?? ""
        let isTrending = json["topic_isTrending"] as? Int ?? 0
        let status = json["topic_status"] as? Int ?? 0
        let chineseTitle = json["topic_chinese_title"] as? String
        let answerPictureUrl = json["answerPictureUrl"] as? String
        
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
    
    // MARK: - Detail Page
    var answers: [Answer]!
    
    func fetchDetail(fromJSON json: [String: Any]) -> Bool{
        guard let answersJSON = json["Answers"] as? [Any] else {
            return false
        }
        answers = []
        isDetailed = true
        for answerJSON in answersJSON {
            if let answerJSON = answerJSON as? [String: Any] {
                if let answer = Answer(fromJson: answerJSON) {
                    answers.append(answer)
                }
            }
        }
        
        if answers.count == 0 {
            isDetailed = false
        } else {
            answers = answers.sort() as! [Answer]
        }
        
        return isDetailed
    }
}
