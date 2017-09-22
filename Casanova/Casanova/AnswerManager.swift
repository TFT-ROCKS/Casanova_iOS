//
//  AnswerManager.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/26/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import Alamofire

class AnswerManager {
    /// Singleton
    static let shared = AnswerManager()
    
    /// URL for fetch answers of a specific user
    let urlAnswersService = "https://tft.rocks/api/answersService;userId="
    /// URL for post answer
    let url = "https://tft.rocks/api"
    
    /// Fetch likedAnswers of a user
    /// - parameter user: user
    /// - parameter block: completion block
    ///
    func fetchLikedAnswers(forUser user: User, withCompletion block: ((ErrorMessage?, [Answer]?) -> Void)? = nil) {
        // Create URL
        let url = urlAnswersService + "\(user.id!)"
        
        // Make request
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if let json = response.result.value {
                //print("JSON: \(json)") // serialized json response
                if let dict = json as? [String: Any] {
                    if let answersArr = dict["likedAnswers"] as? [Any] {
                        // success
                        var answers: [Answer] = []
                        for answerJSON in answersArr {
                            if let answerJSON = answerJSON as? [String: Any] {
                                if let answer = Answer(fromLikedAnswersJson: answerJSON) {
                                    answers.append(answer)
                                }
                            }
                        }
                        block?(nil, answers)
                    }
                } else {
                    let errorMessage = ErrorMessage(msg: "json cannot convert to [String: Any], when trying to fetch liked answers")
                    block?(errorMessage, nil)
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when trying to fetch fetch liked answers")
                block?(errorMessage, nil)
            }
        }
    }
    
    /// Fetch Answers of a user
    /// - parameter user: user
    /// - parameter block: completion block
    ///
    func fetchUserAnswers(forUser user: User, withCompletion block: ((ErrorMessage?, [Answer]?) -> Void)? = nil) {
        // Create URL
        let url = urlAnswersService + "\(user.id!)"
        
        // Make request
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if let json = response.result.value {
                //print("JSON: \(json)") // serialized json response
                if let dict = json as? [String: Any] {
                    if let answersArr = dict["answers"] as? [Any] {
                        // success
                        var answers: [Answer] = []
                        for answerJSON in answersArr {
                            if let answerJSON = answerJSON as? [String: Any] {
                                if let answer = Answer(fromLikedAnswersJson: answerJSON) {
                                    answers.append(answer)
                                }
                            }
                        }
                        block?(nil, answers)
                    }
                } else {
                    let errorMessage = ErrorMessage(msg: "json cannot convert to [String: Any], when trying to fetch user answers")
                    block?(errorMessage, nil)
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when trying to fetch fetch user answers")
                block?(errorMessage, nil)
            }
        }
    }
    
    func postAnswer(topicId: Int?, userId: Int?, title: String, audioUrl: String, ref: String, withCompletion block: ((ErrorMessage?, Answer?) -> Void)? = nil) {
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
        
        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "*/*",
                                    "Referer": "https://tft.rocks/topic/\(topicId)",
            "X-Requested-With": "XMLHttpRequest",
            "Connection": "keep-alive"]
        let params: Parameters = ["requests": ["g0": ["resource": "answersService",
                                                      "operation": "create",
                                                      "params": ["id":nil,
                                                                 "topicId":topicId,
                                                                 "userId":userId,
                                                                 "title":title,
                                                                 "references":ref,
                                                                 "audioUrl":audioUrl],
                                                      "body": [:]]],
                                  "context": [:]]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            if let json = response.result.value {
                //print("JSON: \(json)") // serialized json response
                if let json = json as? [String: Any] {
                    if let msg = json["message"] as? String {
                        // failure
                        let errorMessage = ErrorMessage(msg: msg)
                        block?(errorMessage, nil)
                    } else {
                        // success
                        if let json = json["g0"] as? [String: Any] {
                            if let dict = json["data"] as? [String: Any] {
                                if let answer = Answer(fromCreateJSON: dict) {
                                    block?(nil, answer)
                                }
                            }
                        }
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
}
