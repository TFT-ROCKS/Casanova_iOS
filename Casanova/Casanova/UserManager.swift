//
//  UserManager.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/16/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import Alamofire

class UserManager {
    static let shared = UserManager()
    let url = "http://127.0.0.1:3000/api"
    func signUp(username: String?, email: String?, password: String?, withCompletion block: ((ErrorMessage) -> Void)? = nil) {
        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "*/*",
                                    "Referer": "http://127.0.0.1:3000/",
                                    "X-Requested-With": "XMLHttpRequest",
                                    "Connection": "keep-alive"]
        let params: Parameters = ["requests": ["g0": ["resource": "userService",
                                                      "operation": "create",
                                                      "params": [:],
                                                      "body": ["username": username,
                                                               "email": email,
                                                               "password": password]]],
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
                    let errorMessage = ErrorMessage(msg: "json cannot deserialization, when sign up")
                    block?(errorMessage)
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when sign up")
                block?(errorMessage)
            }
        }
    }
    
    func signIn(email: String?, password: String?, withCompletion block: ((ErrorMessage) -> Void)? = nil) {
        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "*/*",
                                    "Referer": "http://127.0.0.1:3000/",
                                    "X-Requested-With": "XMLHttpRequest",
                                    "Connection": "keep-alive"]
        let params: Parameters = ["requests": ["g0": ["resource": "userService",
                                                      "operation": "update",
                                                      "params": [:],
                                                      "body": ["email": email,
                                                               "password": password]]],
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
                        if let dict = json["g0"] as? [String: Any] {
                            if let dict = dict["data"] as? [String: Any] {
                                let user = User(fromJSON: dict)
                            }
                        }
                    }
                } else {
                    let errorMessage = ErrorMessage(msg: "json cannot deserialization, when sign in")
                    block?(errorMessage)
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when sign in")
                block?(errorMessage)
            }
        }
    }
}
