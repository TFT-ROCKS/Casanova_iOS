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
    
    let userDefault = UserDefaults.standard
    
    func saveLoginInfoToDevice(username: String, password: String) {
        userDefault.set(username, forKey: "username")
        userDefault.set(password, forKey: "password")
    }
    
    func readLoginInfoFromDevice() -> [String: Any]? {
        var info: [String: Any] = [:]
        guard let username = userDefault.string(forKey: "username") else { return nil }
        info["username"] = username
        guard let password = userDefault.string(forKey: "password") else { return nil }
        info["password"] = password
        
        return info
    }
}
