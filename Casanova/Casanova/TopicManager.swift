//
//  TopicManager.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/18/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import Alamofire

class TopicManager {
    static let shared = TopicManager()
    
    let urlPre = "https://tft.rocks/api/topicsService;levelFilter=%5B%5D;searchQuery=;"
    let urlPost = "tagFilter=%5B%5D?returnMeta=true"
    func fetchTopics(from: Int, withCompletion block: ((ErrorMessage?, [Topic]?) -> Void)? = nil) {
        // Create URL
        let urlMid = "start=\(from);"
        let url = urlPre + urlMid + urlPost
        
        // Make request
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                if let topics = json as? NSDictionary {
                    if let topics = topics["data"] as? NSArray {
                        // success
                        var newTopics: [Topic] = []
                        for topic in topics {
                            if let topic = topic as? [String: Any] {
                                let newTopic = Topic(fromJson: topic)
                                newTopics.append(newTopic!)
                            }
                        }
                        block?(nil, newTopics)
                    }
                } else {
                    let errorMessage = ErrorMessage(msg: "json cannot convert to NSDictionary, when trying to fetch topics")
                    block?(errorMessage, nil)
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when trying to fetch topics")
                block?(errorMessage, nil)
            }
        }
    }
    
    
    let urlTopicDetail = "https://tft.rocks/api/topicsService;id="
    func fetchTopicDetail(for topic: Topic, withCompletion block: ((ErrorMessage?, Topic?) -> Void)? = nil) {
        // Create URL
        let url = urlTopicDetail + "\(topic.id)"
        
        // Make request
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                if let dict = json as? [String: Any] {
                    if let topicJSON = dict["topic"] as? [String: Any] {
                        // success
                        topic.fetchDetail(fromJSON: topicJSON)
                        block?(nil, topic)
                    }
                } else {
                    let errorMessage = ErrorMessage(msg: "json cannot convert to [String: Any], when trying to fetch single topic detail")
                    block?(errorMessage, nil)
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when trying to fetch single topic detail")
                block?(errorMessage, nil)
            }
        }
    }
}
