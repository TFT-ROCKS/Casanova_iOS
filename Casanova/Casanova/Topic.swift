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
    var title: String
    var id: Int
    var status: Int
    var level: Int
    var tags: String
    var isTrending: Int
    var isDetailed: Bool
    
    init(answersCount: Int,
         title: String,
         id: Int,
         status: Int,
         level: Int,
         tags: String,
         isTrending: Int) {
        
        self.answersCount = answersCount
        self.title = title
        self.id = id
        self.status = status
        self.level = level
        self.tags = tags
        self.isTrending = isTrending
        self.isDetailed = false
    }
    
    convenience init?(fromJson json: [String: Any]) {
        guard let answersCount = json["answersCount"] as? Int,
            let title = json["topicTitle"] as? String,
            let id = json["topicId"] as? Int,
            let status = json["status"] as? Int,
            let level = json["level"] as? Int,
            let tags = json["tags"] as? String,
            let isTrending = json["isTrending"] as? Int
            else {
                let errorMessage = ErrorMessage(msg: "Error found, when parsing json, into topic")
                print(errorMessage.msg)
                return nil
        }
        self.init(answersCount: answersCount,
                  title: title,
                  id: id,
                  status: status,
                  level: level,
                  tags: tags,
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
                let errorMessage = ErrorMessage(msg: "Error found, when parsing json, into topic, from liked answers JSON")
                print(errorMessage.msg)
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
        self.init(answersCount: answersCount,
                  title: title,
                  id: id,
                  status: status,
                  level: level,
                  tags: tagsStr,
                  isTrending: isTrending)
    }
    
    // MARK: - Detail Page
    var answers: [Answer]!
    
    func fetchDetail(fromJSON json: [String: Any]) -> Bool{
        guard let answersJSON = json["Answers"] as? [Any] else {
            let errorMessage = ErrorMessage(msg: "Error found, when parsing json, into topic detail")
            print(errorMessage.msg)
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
        }
        return isDetailed
    }
}
