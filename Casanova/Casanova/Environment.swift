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
    
    var needsUpdateUserInfoFromServer: Bool = false
    
    var likedAnswers: [Answer]? {
        didSet {
            postUserInfoUpdatedNotification()
        }
    }
    
    let userDefault = UserDefaults.standard
    
    func saveLoginInfoToDevice(username: String, password: String) {
        userDefault.set(username, forKey: "username")
        let encryptedPassword = CryptoManager.shared.bytesFromEncrpyt(string: password)
        userDefault.set(encryptedPassword, forKey: "password")
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
        guard let password = userDefault.array(forKey: "password") else { return nil }
        let decryptedPassword = CryptoManager.shared.stringFromDecrpyt(bytes: password as! [UInt8])
        info["password"] = decryptedPassword
        
        return info
    }
    
    func postUserProfileUpdatedNotification() {
        NotificationCenter.default.post(name: Notifications.userProfileUpdatedNotification, object: nil, userInfo: nil)
    }
    
    func postUserInfoUpdatedNotification() {
        NotificationCenter.default.post(name: Notifications.userInfoUpdatedNotification, object: nil, userInfo: nil)
    }
}
