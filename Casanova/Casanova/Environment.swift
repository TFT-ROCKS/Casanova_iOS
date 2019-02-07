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
    
    static let USER_EMAIL = "user_email"
    static let USER_PASSWORD = "user_password"
    
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
    
    func saveLoginInfoToDevice(userEmail: String, password: String) {
        userDefault.set(userEmail, forKey: Environment.USER_EMAIL)
        let encryptedPassword = CryptoManager.shared.bytesFromEncrpyt(string: password)
        userDefault.set(encryptedPassword, forKey: Environment.USER_PASSWORD)
    }
    
    func updateUserEmailToDevice(userEmail: String) {
        userDefault.set(userEmail, forKey: Environment.USER_EMAIL)
    }
    
    func resetLoginInfoOnDevice() {
        userDefault.set(nil, forKey: Environment.USER_EMAIL)
        userDefault.set(nil, forKey: Environment.USER_PASSWORD)
    }
    
    func readLoginInfoFromDevice() -> [String: Any]? {
        var info: [String: Any] = [:]
        
        guard let userEmail = userDefault.string(forKey: Environment.USER_EMAIL) else { return nil }
        info[Environment.USER_EMAIL] = userEmail
        
        guard let password = userDefault.array(forKey: Environment.USER_PASSWORD) else { return nil }
        let decryptedPassword = CryptoManager.shared.stringFromDecrpyt(bytes: password as! [UInt8])
        
        info[Environment.USER_PASSWORD] = decryptedPassword
        
        return info
    }
    
    func postUserProfileUpdatedNotification() {
        NotificationCenter.default.post(name: Notifications.userProfileUpdatedNotification, object: nil, userInfo: nil)
    }
    
    func postUserInfoUpdatedNotification() {
        NotificationCenter.default.post(name: Notifications.userInfoUpdatedNotification, object: nil, userInfo: nil)
    }
}
