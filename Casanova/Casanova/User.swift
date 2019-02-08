//
//  User.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class User {
    // MARK: - Keys
    static let ID = "id"
    static let USER_ID = "user_id"
    static let FIRSTNAME = "firstname"
    static let LASTNAME = "lastname"
    static let EMAIL = "email"
    static let USER_ROLE = "user_role"
    static let USERNAME = "username"
    
    // MARK: - Vars
    var id: Int!
    var username: String!
    var userRole: String!
    var email: String!
    var firstname: String!
    var lastname: String!
    
    // MARK: - Init for Sign Up / Login Use
    init(id: Int,
         username: String,
         email: String,
         userRole: String,
         firstname: String,
         lastname: String) {
        
        self.id = id
        self.username = username
        self.email = email
        self.userRole = userRole
        self.firstname = firstname
        self.lastname = lastname
    }
    
    convenience init?(fromJSON json: [String: Any]) {
        var userID: Int
        
        if let id = json[User.ID] as? Int {
            userID = id
        } else if let id = json[User.USER_ID] as? Int {
            userID = id
        } else {
            return nil
        }
        
        guard let username = json[User.USERNAME] as? String,
            let email = json[User.EMAIL] as? String,
            let userRole = json[User.USER_ROLE] as? String,
            let firstname = json[User.FIRSTNAME] as? String,
            let lastname = json[User.LASTNAME] as? String
            else {
                return nil
        }
        
        self.init(id: userID,
                  username: username,
                  email: email,
                  userRole: userRole,
                  firstname: firstname,
                  lastname: lastname)
    }
}
