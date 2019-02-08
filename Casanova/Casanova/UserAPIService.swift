//
//  UserAPIService.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/16/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import Alamofire

class UserAPIService {
    static let shared = UserAPIService()
    let userDefault = UserDefaults.standard
    let url = "https://tft.rocks/api2.0"
    
    func signUp(username: String,
                email: String,
                password: String,
                firstname: String,
                lastname: String,
                withCompletion block: ((ErrorMessage?) -> Void)? = nil) {
        
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
        
        let headers: HTTPHeaders = [:]
        let params: Parameters = ["username": username,
                                  "email": email,
                                  "firstname": firstname,
                                  "password": password,
                                  "lastname": lastname]
        
        Alamofire.request("\(url)/user/register", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            if let json = response.result.value {
                if let json = json as? [String: Any] {
                    if let code = json["code"] as? Int, code == 200 {
                        // success
                        Utils.runOnMainThread {
                            block?(nil)
                        }
                    } else if let msg = json["message"] as? String {
                        // failure
                        let errorMessage = ErrorMessage(msg: msg)
                        block?(errorMessage)
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
        
        let headers: HTTPHeaders = [:]
        let params: Parameters = ["email": usernameOrEmail,
                                  "password": password]
        
        Alamofire.request("\(url)/login", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            if let json = response.result.value {
                if let json = json as? [String: Any] {
                    if let code = json["code"] as? Int, code == 200 {
                        // success
                        // save cookie
                        CookieManager.shared.fetchCookiesFromHeaders(headers: response.response?.allHeaderFields, url: response.request?.url)
                        
                        // save user & exec block
                        if let userJSON = json["user"] as? [String: Any] {
                            let user = User(fromJSON: userJSON)
                            Utils.runOnMainThread { block?(nil, user) }
                        }
                    } else if let msg = json["message"] as? String {
                        // failure
                        let errorMessage = ErrorMessage(msg: msg)
                        Utils.runOnMainThread { block?(errorMessage, nil) }
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
            
        } catch _ {
            returnValue = false
        }
        
        return  returnValue
    }

    func logOut(withCompletion block: ((ErrorMessage?) -> Void)? = nil) {
        
        Alamofire.request("\(url)/logout", method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                Utils.runOnMainThread { block?(nil) }
            } else {
                let errorMsg = ErrorMessage(msg: response.result.error.debugDescription)
                Utils.runOnMainThread { block?(errorMsg) }
            }
        }
    }
    
    func update(userId: Int, username: String, firstname: String, lastname: String, withCompletion block: ((ErrorMessage?, User?) -> Void)? = nil) {
        
        let headers: HTTPHeaders = [:]
        var password: String!
        if let loginInfo = Environment.shared.readLoginInfoFromDevice() {
            password = loginInfo[Environment.USER_PASSWORD] as? String
        }
        let params: Parameters = ["username": username,
                                  "firstname": firstname,
                                  "lastname": lastname,
                                  "oldpassword": password,
                                  "password": password]
        
        // Create URL
        let url = "\(self.url)/user/update?userId=\(userId)"
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON {
            response in
            
            if let json = response.result.value {
                if let json = json as? [String: Any] {
                    if let code = json["code"] as? Int, code == 200 {
                        // success
                        // save user & exec block
                        if let userJSON = json["user"] as? [String: Any] {
                            let user = User(fromJSON: userJSON)
                            Utils.runOnMainThread { block?(nil, user) }
                        }
                    } else if let msg = json["message"] as? String {
                        // failure
                        let errorMessage = ErrorMessage(msg: msg)
                        Utils.runOnMainThread { block?(errorMessage, nil) }
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
