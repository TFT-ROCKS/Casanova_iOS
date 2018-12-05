//
//  AnswerToWeChatTimeLineEntity.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 10/31/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class AnswerToWeChatTimeLineEntity: GeneralShareEntity {
    var title: String
    var desc: String
    var image: UIImage
    var webpageUrl: String
    
    init(topic: Topic, answer: Answer) {
        self.title = "托福语料：\(answer.username)的口语回答" + " - " + topic.title
        self.desc = topic.title
        self.image = UIImage(named: "TFTicons_avator_\(answer.userID % 8)")!
        self.webpageUrl = "https://tft.rocks/topic/\(topic.id)#\(answer.id)"
        
        super.init()
    }
}
