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
}
