//
//  User.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class User {
    // MARK: - Partial vars
    var id: Int!
    var username: String!
    var userRole: String!
    
    // MARK: - vars for full user
    var password: String!
    var email: String!
    var createdAt: String!
    var updatedAt: String!
    var firstname: String!
    var lastname: String!
    
    // MARK: - Init for Sign Up / Login Use
    init?(id: Int?,
          username: String?,
          password: String?,
          email: String?,
          createdAt: String?,
          updatedAt: String?,
          userRole: String?,
          firstname: String?,
          lastname: String?) {
        
        guard
            let id = id,
            let username = username,
            let email = email
            else {
                return nil
        }
        
        let password = password ?? "null"
        let createdAt = createdAt ?? "null"
        let updatedAt = updatedAt ?? "null"
        let userRole = userRole ?? "null"
        let firstname = firstname ?? "null"
        let lastname = lastname ?? "null"
        
        self.id = id
        self.username = username
        self.password = password
        self.email = email
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.userRole = userRole
        self.firstname = firstname
        self.lastname = lastname
    }
    
    convenience init?(fromJSON json: [String: Any]) {
        let id = json["id"] as? Int
        let username = json["username"] as? String
        let password = json["password"] as? String
        let email = json["email"] as? String
        let createdAt = json["createdAt"] as? String
        let updatedAt = json["updatedAt"] as? String
        let userRole = json["user_role"] as? String
        let firstname = json["firstname"] as? String
        let lastname = json["lastname"] as? String
        
        self.init(id: id,
                  username: username,
                  password: password,
                  email: email,
                  createdAt: createdAt,
                  updatedAt: updatedAt,
                  userRole: userRole,
                  firstname: firstname,
                  lastname: lastname)
    }
    
    // MARK: - Init for Topic Detail Use
    init(id: Int,
         username: String,
         userRole: String) {
        self.id = id
        self.username = username
        self.userRole = userRole
    }
    
    convenience init?(json: [String: Any]) {
        let id = json["id"] as! Int
        let username = json["username"] as! String
        let userRole = json["userRole"] as? String ?? "none"
        self.init(id: id, username: username, userRole: userRole)
    }
}
