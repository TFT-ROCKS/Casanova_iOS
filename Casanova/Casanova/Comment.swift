//
//  Comment.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class Comment {
    // MARK: - Keys
    static let COMMENT_ID = "id"
    static let COMMENT_TITLE = "title"
    static let COMMENT_AUDIO_URL = "audio_url"
    static let COMMENT_CREATE_TIME = "comment_createtime"
    static let COMMENT_UPDATE_TIME = "comment_updatetime"
    static let USER_ID = "user_id"
    static let USER_NAME = "username"
    static let USER_EMAIL = "email"
    static let USER_ROLE = "user_role"
    
    // MARK: - Vars
    var id: Int
    var title: String
    var audioURL: String?
    var createdAt: String
    var userID: Int
    var username: String
    var userEmail: String
    var userRole: String
    
    init?(id: Int,
          title: String,
          audioURL: String?,
          createdAt: String,
          userID: Int,
          username: String,
          userEmail: String,
          userRole: String) {
        
        self.id = id
        self.title = title
        self.audioURL = audioURL
        self.createdAt = createdAt
        self.userID = userID
        self.username = username
        self.userEmail = userEmail
        self.userRole = userRole
    }
    
    convenience init?(fromJSON json: [String: Any]) {
        guard let id = json[Comment.COMMENT_ID] as? Int,
            let title = json[Comment.COMMENT_TITLE] as? String,
            let userID = json[Comment.USER_ID] as? Int
            else {
                return nil
        }
        
        let audioURL = json[Comment.COMMENT_AUDIO_URL] as? String
        let createdAt = json[Comment.COMMENT_CREATE_TIME] as? String ?? ""
        let username = json[Comment.USER_NAME] as? String ?? ""
        let userEmail = json[Comment.USER_EMAIL] as? String ?? ""
        let userRole = json[Comment.USER_ROLE] as? String ?? ""
        
        self.init(id: id,
                  title: title,
                  audioURL: audioURL,
                  createdAt: createdAt,
                  userID: userID,
                  username: username,
                  userEmail: userEmail,
                  userRole: userRole)
    }
}
