//
//  Answer.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class Answer {
    var id: Int
    var title: String
    var ref: String
    var audioURL: String?
    var updatedAt: String
    var user: User
    var likes: [Like]
    var comments: [Comment]
    
    init(id: Int,
         title: String,
         audioURL: String?,
         ref: String,
         updatedAt: String,
         user: User,
         likes: [Like],
         comments: [Comment]) {
        
        self.id = id
        self.title = title
        self.ref = ref
        self.audioURL = audioURL
        self.updatedAt = updatedAt
        
        self.user = user
        self.likes = likes
        self.comments = comments
    }
    
    convenience init?(fromJson json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let ref = json["references"] as? String,
            let updatedAt = json["updatedAt"] as? String,
            let userJSON = json["User"] as? [String: Any],
            let likesJSON = json["Likes"] as? [Any],
            let commentsJSON = json["Comments"] as? [Any]
            else {
                let errorMessage = ErrorMessage(msg: "Error found, when parsing json, into answer")
                print(errorMessage.msg)
                return nil
        }
        // audio url
        let audioURL = json["audio_url"] as? String
        // user
        guard let user = User(json: userJSON) else { return nil }
        // likes
        var likes: [Like] = []
        for likeJSON in likesJSON {
            guard let like = likeJSON as? [String: Any] else { return nil }
            if let like = Like(fromJSON: like) {
                likes.append(like)
            }
        }
        // comments
        var comments: [Comment] = []
        for commentJSON in commentsJSON {
            guard let comment = commentJSON as? [String: Any] else { return nil }
            if let comment = Comment(fromJSON: comment) {
                comments.append(comment)
            }
        }
        // init
        self.init(id: id, title: title, audioURL: audioURL, ref: ref, updatedAt: updatedAt, user: user, likes: likes, comments: comments)
    }
}