//
//  CommentAPIService.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/26/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import Alamofire

class CommentAPIService {
    static let shared = CommentAPIService()
    
    let url = "https://tft.rocks/api2.0"
    
    /// Fetch comments for certain answer
    /// - parameter num: num of comments
    /// - parameter offset: offset
    /// - parameter answerID: answer id
    /// - parameter block: completion block
    ///
    func fetchComments(num: Int, offset: Int, answerID: Int, withCompletion block: ((ErrorMessage?, [Comment]?) -> Void)? = nil) {
        
        // Create URL
        let url = "\(self.url)/comment/get?answerId=\(answerID)&n=\(num)&offset=\(offset)"
        
        // Make request
        Alamofire.request(url, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                if let arr = response.result.value as? [Any] {
                    var newComments: [Comment] = []
                    for comment in arr {
                        if let comment = comment as? [String: Any] {
                            let newComment = Comment(fromJSON: comment)
                            newComments.append(newComment!)
                        }
                    }
                    block?(nil, newComments)
                }
                else {
                    let errorMessage = ErrorMessage(msg: "response cannot convert to array, when trying to fetch comments")
                    block?(errorMessage, nil)
                }
            }
            else {
                let errorMessage = ErrorMessage(msg: "failed to fetch comments")
                block?(errorMessage, nil)
            }
        }
    }
    
    /// Post a comment for certain answer
    /// - parameter answerId: answer id
    /// - parameter userId: user id
    /// - parameter title: comment title
    /// - parameter audioUrl: audio url
    /// - parameter block: completion block
    ///
    func postComment(answerId: Int?, userId: Int?, title: String, audioUrl: String, withCompletion block: ((ErrorMessage?) -> Void)? = nil) {
        guard let answerId = answerId else {
            let msg = "answerId == nil, when comment answer"
            let errorMessage = ErrorMessage(msg: msg)
            block?(errorMessage)
            return
        }
        
        guard let userId = userId else {
            let msg = "userId == nil, when comment answer"
            let errorMessage = ErrorMessage(msg: msg)
            block?(errorMessage)
            return
        }
        
        let headers: HTTPHeaders = [:]
        let params: Parameters = ["title": title,
                                  "audio_url": audioUrl,
                                  "answerId": answerId,
                                  "userId": userId]
        
        // Create URL
        let url = "\(self.url)/comment/insert"
        
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
                    let errorMessage = ErrorMessage(msg: "json cannot deserialization, when post comment")
                    Utils.runOnMainThread { block?(errorMessage) }
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when post comment")
                Utils.runOnMainThread { block?(errorMessage) }
            }
        }
    }
    
    /// Delete a comment from certain answer
    /// - parameter commentId: comment id
    /// - parameter block: completion block
    ///
    func deleteComment(commentId: Int?, withCompletion block: ((ErrorMessage?) -> Void)? = nil) {
        
        guard let commentId = commentId else {
            let msg = "commentId == nil, when delete comment"
            let errorMessage = ErrorMessage(msg: msg)
            block?(errorMessage)
            return
        }
        
        let headers: HTTPHeaders = [:]
        let params: Parameters = [:]
        
        // Create URL
        let url = "\(self.url)/comment/delete?commentId=\(commentId)"
        
        Alamofire.request(url, method: .delete, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
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
                    let errorMessage = ErrorMessage(msg: "json cannot deserialization, when delete comment")
                    Utils.runOnMainThread { block?(errorMessage) }
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when delete comment")
                Utils.runOnMainThread { block?(errorMessage) }
            }
        }
    }
}
