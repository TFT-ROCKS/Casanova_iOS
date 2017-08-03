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
        
        guard let id = id else {
            let msg = ErrorMessage(msg: "id == nil, when init user")
            print(msg.msg)
            return nil
        }
        guard let username = username else {
            let msg = ErrorMessage(msg: "username == nil, when init user")
            print(msg.msg)
            return nil
        }
        guard let password = password else {
            let msg = ErrorMessage(msg: "password == nil, when init user")
            print(msg.msg)
            return nil
        }
        guard let email = email else {
            let msg = ErrorMessage(msg: "email == nil, when init user")
            print(msg.msg)
            return nil
        }
        guard let createdAt = createdAt else {
            let msg = ErrorMessage(msg: "createdAt == nil, when init user")
            print(msg.msg)
            return nil
        }
        guard let updatedAt = updatedAt else {
            let msg = ErrorMessage(msg: "updatedAt == nil, when init user")
            print(msg.msg)
            return nil
        }
        guard let userRole = userRole else {
            let msg = ErrorMessage(msg: "userRole == nil, when init user")
            print(msg.msg)
            return nil
        }
        guard let firstname = firstname else {
            let msg = ErrorMessage(msg: "firstname == nil, when init user")
            print(msg.msg)
            return nil
        }
        guard let lastname = lastname else {
            let msg = ErrorMessage(msg: "lastname == nil, when init user")
            print(msg.msg)
            return nil
        }
        
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
        guard let id = json["id"] as? Int else {
            let msg = ErrorMessage(msg: "id == nil, when init user from JSON")
            print(msg.msg)
            return nil
        }
        guard let username = json["username"] as? String else {
            let msg = ErrorMessage(msg: "username == nil, when init user from JSON")
            print(msg.msg)
            return nil
        }
        guard let password = json["password"] as? String else {
            let msg = ErrorMessage(msg: "password == nil, when init user from JSON")
            print(msg.msg)
            return nil
        }
        guard let email = json["email"] as? String else {
            let msg = ErrorMessage(msg: "email == nil, when init user from JSON")
            print(msg.msg)
            return nil
        }
        guard let createdAt = json["createdAt"] as? String else {
            let msg = ErrorMessage(msg: "createdAt == nil, when init user from JSON")
            print(msg.msg)
            return nil
        }
        guard let updatedAt = json["updatedAt"] as? String else {
            let msg = ErrorMessage(msg: "updatedAt == nil, when init user from JSON")
            print(msg.msg)
            return nil
        }
        guard let userRole = json["user_role"] as? String else {
            let msg = ErrorMessage(msg: "userRole == nil, when init user from JSON")
            print(msg.msg)
            return nil
        }
        guard let firstname = json["firstname"] as? String else {
            let msg = ErrorMessage(msg: "firstname == nil, when init user from JSON")
            print(msg.msg)
            return nil
        }
        guard let lastname = json["lastname"] as? String else {
            let msg = ErrorMessage(msg: "lastname == nil, when init user from JSON")
            print(msg.msg)
            return nil
        }
        
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
        guard let id = json["id"] as? Int,
            let username = json["username"] as? String
            else {
                return nil
        }
        let userRole = json["userRole"] as? String ?? "none"
        self.init(id: id, username: username, userRole: userRole)
    }
}
