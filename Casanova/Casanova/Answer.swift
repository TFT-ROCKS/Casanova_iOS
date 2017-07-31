//
//  Answer.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class Answer {
    var answerId: Int
    var answerTitle: String
    var updatedAt: String
    var topicId: Int
    var userId: Int
    var ref: String
    var status: Int
    var audioURL: String
    
    init(answerId: Int,
         answerTitle: String,
         updatedAt: String,
         topicId: Int,
         userId: Int,
         ref: String,
         status: Int,
         audioURL: String) {
        
        self.answerId = answerId
        self.answerTitle = answerTitle
        self.updatedAt = updatedAt
        self.topicId = topicId
        self.userId = userId
        self.ref = ref
        self.status = status
        self.audioURL = audioURL
    }
    
    convenience init?(fromJson json: [String: Any]) {
        guard let answerId = json["answerId"] as? Int,
            let answerTitle = json["answerTitle"] as? String,
            let updatedAt = json["updatedAt"] as? String,
            let topicId = json["topicId"] as? Int,
            let userId = json["userId"] as? Int,
            let ref = json["ref"] as? String,
            let status = json["status"] as? Int,
            let audioURL = json["audioURL"] as? String
            else {
                let errorMessage = ErrorMessage(msg: "Error found, when parsing json, into answer")
                print(errorMessage.msg)
                return nil
        }
        self.init(answerId: answerId,
                  answerTitle: answerTitle,
                  updatedAt: updatedAt,
                  topicId: topicId,
                  userId: userId,
                  ref: ref,
                  status: status,
                  audioURL: audioURL)
    }
}
