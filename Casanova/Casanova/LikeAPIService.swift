//
//  LikeAPIService.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/26/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import Alamofire

class LikeAPIService {
    static let shared = LikeAPIService()
    let url = "https://tft.rocks/api"
    func postLike(answerId: Int?, userId: Int?, topicId: Int, withCompletion block: ((ErrorMessage?, Like?) -> Void)? = nil) {
        guard let answerId = answerId else {
            let msg = "answerId == nil, when like answer"
            let errorMessage = ErrorMessage(msg: msg)
            block?(errorMessage, nil)
            return
        }
        
        guard let userId = userId else {
            let msg = "userId == nil, when like answer"
            let errorMessage = ErrorMessage(msg: msg)
            block?(errorMessage, nil)
            return
        }
        
        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "*/*",
                                    "Referer": "https://tft.rocks/topic/\(answerId)",
            "X-Requested-With": "XMLHttpRequest",
            "Connection": "keep-alive"]
        let params: Parameters = ["requests": ["g0": ["resource": "likeService",
                                                      "operation": "create",
                                                      "params": ["answerId":answerId,
                                                                 "userId":userId,
                                                                 "topicId":topicId],
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
                        // Success
                        if let json = json["g0"] as? [String: Any] {
                            if let dict = json["data"] as? [String: Any] {
                                if let like = Like(fromJSON: dict) {
                                    block?(nil, like)
                                }
                            }
                        }
                    }
                } else {
                    let errorMessage = ErrorMessage(msg: "json cannot deserialization, when post like")
                    block?(errorMessage, nil)
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when post like")
                block?(errorMessage, nil)
            }
        }
    }
    
    func deleteLike(likeId: Int?, answerId: Int?, userId: Int?, topicId: Int, withCompletion block: ((ErrorMessage?) -> Void)? = nil) {
        guard let likeId = likeId else {
            let msg = "likeId == nil, when un-like answer"
            let errorMessage = ErrorMessage(msg: msg)
            block?(errorMessage)
            return
        }
        
        guard let answerId = answerId else {
            let msg = "answerId == nil, when un-like answer"
            let errorMessage = ErrorMessage(msg: msg)
            block?(errorMessage)
            return
        }
        
        guard let userId = userId else {
            let msg = "userId == nil, when un-like answer"
            let errorMessage = ErrorMessage(msg: msg)
            block?(errorMessage)
            return
        }
        
        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "*/*",
                                    "Referer": "https://tft.rocks/topic/\(answerId)",
            "X-Requested-With": "XMLHttpRequest",
            "Connection": "keep-alive"]
        let params: Parameters = ["requests": ["g0": ["resource": "likeService",
                                                      "operation": "create",
                                                      "params": ["existedLike":["id":likeId,
                                                                                "UserId":userId],
                                                                 "answerId":answerId,
                                                                 "userId":userId,
                                                                 "topicId":topicId],
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
                        block?(errorMessage)
                    } else {
                        // success
                        if let json = json["g0"] as? [String: Any] {
                            if let dict = json["data"] as? [String: Any] {
                                if dict["deletedLike"] as! Bool == true {
                                    // Delete Success
                                    block?(nil)
                                }
                            }
                        }
                    }
                } else {
                    let errorMessage = ErrorMessage(msg: "json cannot deserialization, when post like")
                    block?(errorMessage)
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when post like")
                block?(errorMessage)
            }
        }
    }
}
