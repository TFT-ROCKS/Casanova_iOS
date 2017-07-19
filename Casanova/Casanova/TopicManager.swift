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
    let url = "https://tft.rocks/api/topicsService"
    func fetchTopics(withCompletion block: ((ErrorMessage?, [Topic]?) -> Void)? = nil) {
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                if let topics = json as? NSArray {
                    // success
                    var newTopics: [Topic] = []
                    for topic in topics {
                        if let topic = topic as? [String: Any] {
                            let newTopic = Topic(fromJson: topic)
                            newTopics.append(newTopic!)
                        }
                    }
                    block?(nil, newTopics)
                } else {
                    let errorMessage = ErrorMessage(msg: "json cannot convert to array, when trying to fetch topics")
                    block?(errorMessage, nil)
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when trying to fetch topics")
                block?(errorMessage, nil)
            }
        }
    }
}
