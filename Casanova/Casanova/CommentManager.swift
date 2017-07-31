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
    let url = "http://127.0.0.1:3000/api"
    func postComment(answerID: Int, userId: Int, title: String, withCompletion block: ((ErrorMessage) -> Void)? = nil) {
        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "*/*",
                                    "Referer": "http://127.0.0.1:3000/",
                                    "X-Requested-With": "XMLHttpRequest",
                                    "Connection": "keep-alive"]
        let params: Parameters = ["requests": ["g0": ["resource": "commentService",
                                                      "operation": "create",
                                                      "params": ["answerId":answerID,
                                                                 "userId":userId,
                                                                 "title":title],
                                                      "body": [:]]],
                                  "context": [:]]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                if let json = json as? [String: Any] {
                    if let msg = json["message"] as? String {
                        // failure
                        let errorMessage = ErrorMessage(msg: msg)
                        block?(errorMessage)
                    } else {
                        // success
                        
                    }
                } else {
                    let errorMessage = ErrorMessage(msg: "json cannot deserialization, when post comment")
                    block?(errorMessage)
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when post comment")
                block?(errorMessage)
            }
        }
    }
}

