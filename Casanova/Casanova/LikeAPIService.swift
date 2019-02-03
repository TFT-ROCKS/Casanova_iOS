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
    /// Singleton
    static let shared = LikeAPIService()
    
    /// URL for answer
    let url = "https://tft.rocks/api2.0"
    
    /// Post like for certain answer
    ///
    /// - parameter answerId: answer id
    /// - parameter userId: user id
    /// - parameter block: completion block
    ///
    func postLike(answerId: Int?, userId: Int?, withCompletion block: ((ErrorMessage?, Int?) -> Void)? = nil) {
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
        
        let headers: HTTPHeaders = [:]
        let params: Parameters = ["answerId": answerId,
                                  "userId": userId]
        
        // Create URL
        let url = "\(self.url)/like/insert"
        
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
                    let errorMessage = ErrorMessage(msg: "json cannot deserialization, when post like")
                    block?(errorMessage, nil)
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when post like")
                block?(errorMessage, nil)
            }
        }
    }
}
