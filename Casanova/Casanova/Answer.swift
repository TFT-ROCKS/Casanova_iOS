//
//  Answer.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class Answer {
    
    // MARK: - Keys
    static let LIKES_NUM = "likes_num"
    static let COMMENTS_NUM = "comments_num"
    static let ANSWER_ID = "answer_id"
    static let USER_ID = "user_id"
    static let USER_NAME = "user_name"
    static let USER_ROLE = "user_role"
    static let ANSWER_TITLE = "answer_title"
    static let ANSWER_CREATETIME = "answer_createtime"
    static let ANSWER_UPDATETIME = "answer_updatetime"
    static let ANSWER_REFERENCES = "answer_references"
    static let ANSWER_STATUS = "answer_status"
    static let ANSWER_UKAUDIO = "answer_audio"
    static let ANSWER_PIC = "answer_pic"
    static let ANSWER_NOTE = "answer_note"
    static let ANSWER_CHINESETITLE = "answer_chinesetitle"
    static let ANSWER_USAUDIO = "answer_USaudio"
    static let ANSWER_NOTE_URL = "answer_note_url"
    
    // MARK: - Vars
    var id: Int
    var title: String
    var createtime: String
    var updateTime: String
    var references: String
    var status: Int
    var ukAudio: String?
    var pic: String
    var note: String
    var noteURL: String?
    var chineseTitle: String
    var usAudio: String?
    var likesNum: Int
    var commentsNum: Int
    var userID: Int
    var username: String
    var userRole: String
    
    init(id: Int,
         title: String,
         createtime: String,
         updateTime: String,
         references: String,
         status: Int,
         ukAudio: String?,
         pic: String,
         note: String,
         noteURL: String?,
         chineseTitle: String,
         usAudio: String?,
         likesNum: Int,
         commentsNum: Int,
         userID: Int,
         username: String,
         userRole: String) {
        
        self.id = id
        self.title = title
        self.createtime = createtime
        self.updateTime = updateTime
        self.references = references
        self.status = status
        self.ukAudio = ukAudio
        self.pic = pic
        self.note = note
        self.noteURL = noteURL
        self.chineseTitle = chineseTitle
        self.usAudio = usAudio
        self.likesNum = likesNum
        self.commentsNum = commentsNum
        self.userID = userID
        self.username = username
        self.userRole = userRole
    }
    
    convenience init?(fromJson json: [String: Any]) {
        guard let id = json[Answer.ANSWER_ID] as? Int,
            let title = json[Answer.ANSWER_TITLE] as? String,
            let userID = json[Answer.USER_ID] as? Int
            else {
                return nil
        }
        
        let createtime = json[Answer.ANSWER_CREATETIME] as? String ?? ""
        let updateTime = json[Answer.ANSWER_UPDATETIME] as? String ?? ""
        let references = json[Answer.ANSWER_REFERENCES] as? String ?? ""
        let status = json[Answer.ANSWER_STATUS] as? Int ?? 0
        let ukAudio = json[Answer.ANSWER_UKAUDIO] as? String
        let pic = json[Answer.ANSWER_PIC] as? String ?? ""
        let note = json[Answer.ANSWER_NOTE] as? String ?? ""
        let noteURL = json[Answer.ANSWER_NOTE_URL] as? String
        let chineseTitle = json[Answer.ANSWER_CHINESETITLE] as? String ?? ""
        let usAudio = json[Answer.ANSWER_USAUDIO] as? String
        let likesNum = json[Answer.LIKES_NUM] as? Int ?? 0
        let commentsNum = json[Answer.COMMENTS_NUM] as? Int ?? 0
        let username = json[Answer.USER_NAME] as? String ?? ""
        let userRole = json[Answer.USER_ROLE] as? String ?? ""
        
        self.init(id: id,
                  title: title,
                  createtime: createtime,
                  updateTime: updateTime,
                  references: references,
                  status: status,
                  ukAudio: ukAudio,
                  pic: pic,
                  note: note,
                  noteURL: noteURL,
                  chineseTitle: chineseTitle,
                  usAudio: usAudio,
                  likesNum: likesNum,
                  commentsNum: commentsNum,
                  userID: userID,
                  username: username,
                  userRole: userRole)
    }
}
