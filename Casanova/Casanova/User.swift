//
//  User.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class User {
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
        guard let id = json["user_id"] as? Int,
            let username = json["username"] as? String,
            let email = json["email"] as? String,
            let userRole = json["user_role"] as? String,
            let firstname = json["firstname"] as? String,
            let lastname = json["lastname"] as? String
            else {
                return nil
        }
        
        self.init(id: id,
                  username: username,
                  email: email,
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
