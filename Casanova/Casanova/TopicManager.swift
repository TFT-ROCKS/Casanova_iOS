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
    /// Singleton
    static let shared = TopicManager()
    
    /// URL for fetch topics
    let urlPre = "https://tft.rocks/api/topicsService;"
    func levelFilter(_ levels: String) -> String { return "levelFilter=\(levels);" }
    func searchQuery(_ query: String) -> String { return "searchQuery=\(query);" }
    func tagFilter(_ tags: String) -> String { return "tagFilter=\(tags);" }
    func startFilter(_ from: Int) -> String { return "start=\(from)" }
    let urlPost = "?returnMeta=true"
    
    /// URL for fetch single topic
    let urlTopicDetail = "https://tft.rocks/api/topicsService;id="
    
    
    /// Fetch topics for home view
    /// - parameter from: starting index
    /// - parameter block: completion block
    ///
    func fetchTopics(levels: [String] = [], query: String = "", tags: [String] = [], start: Int, withCompletion block: ((ErrorMessage?, [Topic]?) -> Void)? = nil) {
        // Handle params
        let levelsString = levels.joined(separator: ",")
        let tagsString = tags.joined(separator: ",")
        
        // Create URL
        let url = urlPre + levelFilter(levelsString) + searchQuery(query) + tagFilter(tagsString) + startFilter(start) + urlPost
        
        // Make request
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if let json = response.result.value {
                //print("JSON: \(json)") // serialized json response
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
    
    /// Fetch single topic detail for topic detail view
    /// - parameter for: topic that needs detail info
    /// - parameter block: completion block
    func fetchTopicDetail(for topic: Topic, withCompletion block: ((ErrorMessage?, Topic?) -> Void)? = nil) {
        // Create URL
        let url = urlTopicDetail + "\(topic.id)"

        // Make request
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if let json = response.result.value {
                //print("JSON: \(json)") // serialized json response
                if let dict = json as? [String: Any] {
                    if let topicJSON = dict["topic"] as? [String: Any] {
                        // success
                        if topic.fetchDetail(fromJSON: topicJSON) {
                            block?(nil, topic)
                        }
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
