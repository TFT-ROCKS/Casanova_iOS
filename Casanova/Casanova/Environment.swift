//
//  Environment.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/19/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class Environment {
    static let shared = Environment()
    
    var currentUser: User? {
        didSet {
            postUserProfileUpdatedNotification()
        }
    }
    
    var answers: [Answer]?
    
    func removeAnswer(_ answerId: Int) {
        var index: Int? = nil
        for i in 0..<answers!.count {
            if answerId == answers![i].id {
                index = i
            }
        }
        if index != nil {
            answers!.remove(at: index!)
        }
    }
    
    func needsPrepareUserInfo() {
        prepareForCurrentUser()
    }
    
    var needsUpdateUserInfoFromServer: Bool = false
    
    var likedAnswers: [Answer]? {
        didSet {
            postUserInfoUpdatedNotification()
        }
    }
    
    let userDefault = UserDefaults.standard
    
    func saveLoginInfoToDevice(username: String, password: String) {
        userDefault.set(username, forKey: "username")
        userDefault.set(password, forKey: "password")
    }
    
    func updateUserNameToDevice(username: String) {
        userDefault.set(username, forKey: "username")
    }
    
    func resetLoginInfoOnDevice() {
        userDefault.set(nil, forKey: "username")
        userDefault.set(nil, forKey: "password")
    }
    
    func readLoginInfoFromDevice() -> [String: Any]? {
        var info: [String: Any] = [:]
        guard let username = userDefault.string(forKey: "username") else { return nil }
        info["username"] = username
        guard let password = userDefault.string(forKey: "password") else { return nil }
        info["password"] = password
        
        return info
    }
    
    func prepareForCurrentUser() {
        guard let user = currentUser else {
            return
        }
        AnswerManager.shared.fetchUserInfo(forUser: user, withCompletion: { (error, answers, likedAnswers) in
            self.answers = answers
            self.likedAnswers = likedAnswers
            self.postUserInfoPreparedNotification()
        })
    }
    
    func updateForCurrentUser(withCompletion block: ((ErrorMessage?) -> Swift.Void)? = nil) {
        guard let user = currentUser else {
            block?(ErrorMessage(msg: "User Not Found"))
            return
        }
        AnswerManager.shared.fetchUserInfo(forUser: user, withCompletion: { (error, answers, likedAnswers) in
            if error == nil {
                self.answers = answers
                self.likedAnswers = likedAnswers
                self.postUserInfoUpdatedNotification()
                block?(nil)
            } else {
                let e = ErrorMessage(msg: error.debugDescription)
                block?(e)
            }
        })
    }
    
    func postUserInfoPreparedNotification() {
        NotificationCenter.default.post(name: Notifications.userInfoPreparedNotification, object: nil, userInfo: nil)
    }
    
    func postUserProfileUpdatedNotification() {
        NotificationCenter.default.post(name: Notifications.userProfileUpdatedNotification, object: nil, userInfo: nil)
    }
    
    func postUserInfoUpdatedNotification() {
        NotificationCenter.default.post(name: Notifications.userInfoUpdatedNotification, object: nil, userInfo: nil)
    }
}
