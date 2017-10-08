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
    let userDefault = UserDefaults.standard
    let url = "https://tft.rocks/api"
    func signUp(username: String, email: String, password: String, withCompletion block: ((ErrorMessage?) -> Void)? = nil) {
        if username == "" {
            let errorMessage = ErrorMessage(msg: Errors.usernameNotValid)
            block?(errorMessage)
            return
        } else if email == "" || !isValidEmailAddress(emailAddressString: email) {
            let errorMessage = ErrorMessage(msg: Errors.emailNotValid)
            block?(errorMessage)
            return
        } else if password == "" {
            let errorMessage = ErrorMessage(msg: Errors.passwordNotValid)
            block?(errorMessage)
            return
        }
        
        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "*/*",
                                    "Referer": "https://tft.rocks/",
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
                //print("JSON: \(json)") // serialized json response
                if let json = json as? [String: Any] {
                    if let msg = json["message"] as? String {
                        // failure
                        let errorMessage = ErrorMessage(msg: msg)
                        block?(errorMessage)
                    } else {
                        // success
                        block?(nil)
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
    
    func signIn(usernameOrEmail: String, password: String, withCompletion block: ((ErrorMessage?, User?) -> Void)? = nil) {
        if usernameOrEmail == "" {
            let errorMessage = ErrorMessage(msg: Errors.usernameOrEmailNotValid)
            block?(errorMessage, nil)
            return
        } else if password == "" {
            let errorMessage = ErrorMessage(msg: Errors.passwordNotValid)
            block?(errorMessage, nil)
            return
        }
        
        let usernameOrEmailKey = isValidEmailAddress(emailAddressString: usernameOrEmail) ? "email" : "username"
        
        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "*/*",
                                    "Referer": "https://tft.rocks/",
                                    "X-Requested-With": "XMLHttpRequest",
                                    "Connection": "keep-alive"]
        let params: Parameters = ["requests": ["g0": ["resource": "userService",
                                                      "operation": "update",
                                                      "params": [:],
                                                      "body": [usernameOrEmailKey: usernameOrEmail,
                                                               "password": password]]],
                                  "context": [:]]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            if let json = response.result.value {
                //print("JSON: \(json)") // serialized json response
                if let json = json as? [String: Any] {
                    if let msg = json["message"] as? String {
                        // failure
                        let errorMessage = ErrorMessage(msg: msg)
                        Utils.runOnMainThread { block?(errorMessage, nil) }
                    } else {
                        // success
                        if let dict = json["g0"] as? [String: Any] {
                            if let dict = dict["data"] as? [String: Any] {
                                if let user = User(fromJSON: dict) {
                                    Utils.runOnMainThread { block?(nil, user) }
                                }
                            }
                        }
                    }
                } else {
                    let errorMessage = ErrorMessage(msg: "json cannot deserialization, when sign in")
                    Utils.runOnMainThread { block?(errorMessage, nil) }
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when sign in")
                Utils.runOnMainThread { block?(errorMessage, nil) }
            }
        }
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0 {
                returnValue = false
            }
            
        } catch let error as NSError {
            //print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }

    func logOut(withCompletion block: ((ErrorMessage?) -> Void)? = nil) {
        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "*/*",
                                    "Referer": "https://tft.rocks/",
                                    "X-Requested-With": "XMLHttpRequest",
                                    "Connection": "keep-alive"]
        let params: Parameters = ["requests": ["g0": ["resource": "userService",
                                                      "operation": "update",
                                                      "params": ["key":"logout"],
                                                      "body": []]],
                                  "context": [:]]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            if response.result.isSuccess {
                Utils.runOnMainThread { block?(nil) }
            } else {
                let errorMsg = ErrorMessage(msg: response.result.error.debugDescription)
                //print(errorMsg.msg)
                Utils.runOnMainThread { block?(errorMsg) }
            }
        }
    }
    
    func update(userId: Int, username: String, firstname: String, lastname: String, withCompletion block: ((ErrorMessage?, User?) -> Void)? = nil) {
        
        let headers: HTTPHeaders = ["Content-Type": "application/json",
                                    "Accept": "*/*",
                                    "Referer": "https://tft.rocks/profile/\(userId)",
                                    "X-Requested-With": "XMLHttpRequest",
                                    "Connection": "keep-alive"]
        let params: Parameters = ["requests": ["g0": ["resource": "userService",
                                                      "operation": "update",
                                                      "params": ["key":"editprofile"],
                                                      "body": ["id": userId,
                                                               "username": username,
                                                               "firstname": firstname,
                                                               "lastname": lastname]]],
                                  "context": [:]]
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            if let json = response.result.value {
                //print("JSON: \(json)") // serialized json response
                if let json = json as? [String: Any] {
                    if let msg = json["message"] as? String {
                        // failure
                        let errorMessage = ErrorMessage(msg: msg)
                        Utils.runOnMainThread { block?(errorMessage, nil) }
                    } else {
                        // success
                        if let dict = json["g0"] as? [String: Any] {
                            if let dict = dict["data"] as? [String: Any] {
                                if let user = User(fromJSON: dict) {
                                    Utils.runOnMainThread { block?(nil, user) }
                                }
                            }
                        }
                    }
                } else {
                    let errorMessage = ErrorMessage(msg: "json cannot deserialization, when edit user profile")
                    Utils.runOnMainThread { block?(errorMessage, nil) }
                }
            } else {
                let errorMessage = ErrorMessage(msg: "json == nil, when edit user profile")
                Utils.runOnMainThread { block?(errorMessage, nil) }
            }
        }
    }
}
