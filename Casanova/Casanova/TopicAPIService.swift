//
//  TopicAPIService.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/18/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import Alamofire

class TopicAPIService {
    /// Singleton
    static let shared = TopicAPIService()
    
    /// URL for fetch topics
    let url = "https://tft.rocks/api2.0/"
    
    /// URL for fetch single topic
    let urlTopicDetail = "https://tft.rocks/api/topicsService;id="
    
    /// Fetch topics for home view
    /// - parameter block: completion block
    ///
    func fetchTopics(num: Int, offset: Int, id: Int?, withCompletion block: ((ErrorMessage?, [Topic]?) -> Void)? = nil) {
        
        // Create URL
        var url = "\(self.url)topic?n=\(num)&offset=\(offset)"
        if let id = id {
            url += "&id=\(id)"
        }
        
        // Make request
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                if let arr = response.result.value as? [Any] {
                    var newTopics: [Topic] = []
                    for topic in arr {
                        if let topic = topic as? [String: Any] {
                            let newTopic = Topic(fromJson: topic)
                            newTopics.append(newTopic!)
                        }
                    }
                    block?(nil, newTopics)
                }
                else {
                    let errorMessage = ErrorMessage(msg: "response cannot convert to array, when trying to fetch topics")
                    block?(errorMessage, nil)
                }
            }
            else {
                let errorMessage = ErrorMessage(msg: "failed to fetch topics")
                block?(errorMessage, nil)
            }
        }
    }
    
    /// Fetch topics with filters
    /// - parameter block: completion block
    ///
    func fetchTopics(levels: [String] = [], query: String = "", tags: [String] = [], withCompletion block: ((ErrorMessage?, [Topic]?) -> Void)? = nil) {
        // Handle params
        let levelsString = levels.map { "level=\($0)" }.joined(separator: "&")
        let tagsString = tags.map { "tag=\($0)" }.joined(separator: "&")
        
        // Create URL
        var url = "\(self.url)topic/search?&search=\(query)"
        if levelsString.count > 0 {
            url += "&\(levelsString)"
        }
        if tagsString.count > 0 {
            url += "&\(tagsString)"
        }
        
        // Make request
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                if let arr = response.result.value as? [Any] {
                    var newTopics: [Topic] = []
                    for topic in arr {
                        if let topic = topic as? [String: Any] {
                            let newTopic = Topic(fromJson: topic)
                            newTopics.append(newTopic!)
                        }
                    }
                    block?(nil, newTopics)
                }
                else {
                    let errorMessage = ErrorMessage(msg: "response cannot convert to array, when trying to search topics")
                    block?(errorMessage, nil)
                }
            }
            else {
                let errorMessage = ErrorMessage(msg: "failed to search topics")
                block?(errorMessage, nil)
            }
        }
    }
    
    //    /// Fetch single topic detail for topic detail view
    //    /// - parameter for: topic that needs detail info
    //    /// - parameter block: completion block
    //    func fetchTopicDetail(for topic: Topic, withCompletion block: ((ErrorMessage?, Topic?) -> Void)? = nil) {
    //        // Create URL
    //        let url = urlTopicDetail + "\(topic.id)"
    //
    //        // Make request
    //        Alamofire.request(url, method: .get).responseJSON {
    //            response in
    //            if let json = response.result.value {
    //                //print("JSON: \(json)") // serialized json response
    //                if let dict = json as? [String: Any] {
    //                    if let topicJSON = dict["topic"] as? [String: Any] {
    //                        // success
    //                        if topic.fetchDetail(fromJSON: topicJSON) {
    //                            block?(nil, topic)
    //                        }
    //                    }
    //                } else {
    //                    let errorMessage = ErrorMessage(msg: "json cannot convert to [String: Any], when trying to fetch single topic detail")
    //                    block?(errorMessage, nil)
    //                }
    //            } else {
    //                let errorMessage = ErrorMessage(msg: "json == nil, when trying to fetch single topic detail")
    //                block?(errorMessage, nil)
    //            }
    //        }
    //    }
}
