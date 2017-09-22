//
//  CommentManager.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/26/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import Alamofire

class CommentManager {
    static let shared = CommentManager()
    let url = "https://tft.rocks/api"
    func postComment(answerId: Int?, userId: Int?, title: String, withCompletion block: ((ErrorMessage?, Comment?) -> Void)? = nil) {
        guard let answerId = answerId else {
            let msg = "answerId == nil, when comment answer"
            let errorMessage = ErrorMessage(msg: msg)
            block?(errorMessage, nil)
            return
        }
        
        guard let userId = userId else {
            let msg = "userId == nil, when comment answer"
            let errorMessage = ErrorMessage(msg: msg)
            block?(errorMessage, nil)
            return
        }
        // TODO: need to fix the referer using topicId
        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "*/*",
                                    "Referer": "https://tft.rocks/topic/\(answerId)",
                                    "X-Requested-With": "XMLHttpRequest",
                                    "Connection": "keep-alive"]
        let params: Parameters = ["requests": ["g0": ["resource": "commentService",
                                                      "operation": "create",
                                                      "params": ["answerId":answerId,
                                                                 "userId":userId,
                                                                 "title":title],
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
                                if let comment = Comment(fromJSON: dict) {
                                    block?(nil, comment)
                                }
                            }
                        }
                    }
                } else {
                    let errorMessage = ErrorMessage(msg: "json cannot deserialization, when post comment")
                    block?(errorMessage, nil)
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when post comment")
                block?(errorMessage, nil)
            }
        }
    }
}

