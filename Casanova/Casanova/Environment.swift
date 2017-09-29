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
    
    var currentUser: User?
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
    
    var likedAnswers: [Answer]?
    
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
    
    func postUserInfoPreparedNotification() {
        NotificationCenter.default.post(name: Notifications.userInfoPreparedNotification, object: nil, userInfo: nil)
    }
}
