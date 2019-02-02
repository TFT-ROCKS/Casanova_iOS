//
//  AnswerAPIService.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/26/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import Alamofire

class AnswerAPIService {
    /// Singleton
    static let shared = AnswerAPIService()
    
    /// URL for answer
    let url = "https://tft.rocks/api2.0"
    
    /// Fetch answers for a single topic
    ///
    /// - parameter num: number of answers
    /// - parameter offset: offset
    /// - parameter topicID: topic id
    /// - parameter block: completion block
    ///
    func fetchAnswers(num: Int, offset: Int, topicID: Int, withCompletion block: ((ErrorMessage?, [Answer]?) -> Void)? = nil) {
        
        // Create URL
        let url = "\(self.url)/answer/load?topicId=\(topicID)&n=\(num)&offset=\(offset)"
        
        // Make request
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                if let arr = response.result.value as? [Any] {
                    var newAnswers: [Answer] = []
                    for answer in arr {
                        if let answer = answer as? [String: Any] {
                            let newAnswer = Answer(fromJson: answer)
                            newAnswers.append(newAnswer!)
                        }
                    }
                    block?(nil, newAnswers)
                }
                else {
                    let errorMessage = ErrorMessage(msg: "response cannot convert to array, when trying to fetch amswers")
                    block?(errorMessage, nil)
                }
            }
            else {
                let errorMessage = ErrorMessage(msg: "failed to fetch answers")
                block?(errorMessage, nil)
            }
        }
    }
    
    /// Post an answer from a user
    ///
    /// - parameter topicId: topic id
    /// - parameter userId: user id
    /// - parameter title: title
    /// - parameter audioUrl: audio url
    /// - parameter ref: reference
    /// - parameter block: completion block
    ///
    func postAnswer(topicId: Int?, userId: Int?, title: String, audioUrl: String, ref: String, withCompletion block: ((ErrorMessage?, Int?) -> Void)? = nil) {
        guard let topicId = topicId else {
            let msg = "topicId == nil, when post answer"
            let errorMessage = ErrorMessage(msg: msg)
            block?(errorMessage, nil)
            return
        }
        
        guard let userId = userId else {
            let msg = "userId == nil, when post answer"
            let errorMessage = ErrorMessage(msg: msg)
            block?(errorMessage, nil)
            return
        }
        
        let headers: HTTPHeaders = [:]
        let params: Parameters = ["title": title,
                                  "notetitle": "",
                                  "chinesetitle": "",
                                  "topicid": topicId,
                                  "userid": userId,
                                  "references": ref,
                                  "audio_url": audioUrl,
                                  "status": 0]
        
        // Create URL
        let url = "\(self.url)/answer/post"
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            if let json = response.result.value {
                if let json = json as? [String: Any] {
                    if let code = json["code"] as? Int, code == 200 {
                        // success
                        if let insertId = json["insertId"] as? Int {
                            Utils.runOnMainThread { block?(nil, insertId) }
                        }
                    } else if let msg = json["message"] as? String {
                        // failure
                        let errorMessage = ErrorMessage(msg: msg)
                        Utils.runOnMainThread { block?(errorMessage, nil) }
                    }
                } else {
                    let errorMessage = ErrorMessage(msg: "json cannot deserialization, when post answer")
                    block?(errorMessage, nil)
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when post answer")
                block?(errorMessage, nil)
            }
        }
    }
    
    /// Delete an answer for a user
    ///
    /// - parameter answerId: answer id
    /// - parameter block: completion block
    ///
    func deleteAnswer(answerId: Int?, withCompletion block: ((ErrorMessage?) -> Void)? = nil) {
        guard let answerId = answerId else {
            let msg = "answerId == nil, when delete answer"
            let errorMessage = ErrorMessage(msg: msg)
            block?(errorMessage)
            return
        }
        
        let headers: HTTPHeaders = [:]
        let params: Parameters = ["status": 0]
        
        // Create URL
        let url = "\(self.url)/answer/update?answerId=\(answerId)"
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            if let json = response.result.value {
                if let json = json as? [String: Any] {
                    if let code = json["code"] as? Int, code == 200 {
                        // success
                        Utils.runOnMainThread { block?(nil) }
                    } else if let msg = json["message"] as? String {
                        // failure
                        let errorMessage = ErrorMessage(msg: msg)
                        Utils.runOnMainThread { block?(errorMessage) }
                    }
                } else {
                    let errorMessage = ErrorMessage(msg: "json cannot deserialization, when delete answer")
                    block?(errorMessage)
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when delete answer")
                block?(errorMessage)
            }
        }
    }
}
