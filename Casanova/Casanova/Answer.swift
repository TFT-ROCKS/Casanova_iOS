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
    var ref: String?
    var audioURL: String?
    var noteURL: String?
    var updatedAt: String
    var user: User
    var likes: [Like]
    var comments: [Comment]
    var topic: Topic? // may not have topic
    
    init(id: Int,
         title: String,
         audioURL: String?,
         noteURL: String?,
         ref: String?,
         updatedAt: String,
         user: User,
         likes: [Like],
         comments: [Comment],
         topic: Topic?) {
        
        self.id = id
        self.title = title
        self.ref = ref
        self.audioURL = audioURL
        self.noteURL = noteURL
        self.updatedAt = updatedAt
        
        self.user = user
        self.likes = likes
        self.comments = comments
        self.topic = topic
        
        self.comments =  self.comments.sort() as! [Comment]
    }
    
    convenience init?(fromJson json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let updatedAt = json["updatedAt"] as? String,
            let userJSON = json["User"] as? [String: Any],
            let likesJSON = json["Likes"] as? [Any],
            let commentsJSON = json["Comments"] as? [Any]
            else {
                let errorMessage = ErrorMessage(msg: "Error found, when parsing json, into answer")
                //print(errorMessage.msg)
                return nil
        }
        // ref
        let ref = json["references"] as? String
        // audio url
        let audioURL = json["audio_url"] as? String
        // note url
        let noteURL = json["note_url"] as? String
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
        self.init(id: id, title: title, audioURL: audioURL, noteURL: noteURL, ref: ref, updatedAt: updatedAt, user: user, likes: likes, comments: comments, topic: nil)
    }
    
    convenience init?(fromCreateJSON json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let updatedAt = json["updatedAt"] as? String,
            let userJSON = json["User"] as? [String: Any],
            let commentsJSON = json["Comments"] as? [Any]
            else {
                let errorMessage = ErrorMessage(msg: "Error found, when parsing json, into answer")
                //print(errorMessage.msg)
                return nil
        }
        // ref
        let ref = json["references"] as? String
        // audio url
        let audioURL = json["audioUrl"] as? String
        // user
        guard let user = User(json: userJSON) else { return nil }
        // comments
        var comments: [Comment] = []
        for commentJSON in commentsJSON {
            guard let comment = commentJSON as? [String: Any] else { return nil }
            if let comment = Comment(fromJSON: comment) {
                comments.append(comment)
            }
        }
        // init
        self.init(id: id, title: title, audioURL: audioURL, noteURL: nil, ref: ref, updatedAt: updatedAt, user: user, likes: [], comments: comments, topic: nil)
    }
    
    // User Answers vs Liked Answers: same schema
    convenience init?(fromLikedAnswersJson json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let updatedAt = json["updatedAt"] as? String,
            let userJSON = json["User"] as? [String: Any],
            let likesJSON = json["Likes"] as? [Any],
            let commentsJSON = json["Comments"] as? [Any]
            else {
                let errorMessage = ErrorMessage(msg: "Error found, when parsing json, into answer")
                //print(errorMessage.msg)
                return nil
        }
        // ref
        let ref = json["references"] as? String
        // audio url
        let audioURL = json["audio_url"] as? String
        // note url
        let noteURL = json["note_url"] as? String
        // topic
        var topic: Topic? = nil
        if let topicJSON = json["Topic"] as? [String: Any] {
            topic = Topic(fromLikedAnswersJSON: topicJSON)
        }
        // user
        guard let user = User(json: userJSON) else { return nil }
        // likes
        var likes: [Like] = []
        for likeJSON in likesJSON {
            guard let like = likeJSON as? [String: Any] else { return nil }
            if let like = Like(fromLikedAnswersJSON: like) {
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
        self.init(id: id, title: title, audioURL: audioURL, noteURL: noteURL, ref: ref, updatedAt: updatedAt, user: user, likes: likes, comments: comments, topic: topic)
    }
    
    // Single Answer: parse single answer JSON
    convenience init?(fromSingleAnswerJson json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let updatedAt = json["updatedAt"] as? String,
            let userJSON = json["User"] as? [String: Any],
            let likesJSON = json["Likes"] as? [Any],
            let commentsJSON = json["Comments"] as? [Any]
            else {
                let errorMessage = ErrorMessage(msg: "Error found, when parsing json, into answer")
                //print(errorMessage.msg)
                return nil
        }
        // ref
        let ref = json["references"] as? String
        // audio url
        let audioURL = json["audio_url"] as? String
        // note url
        let noteURL = json["note_url"] as? String
        // topic
        var topic: Topic? = nil
        if let topicJSON = json["Topic"] as? [String: Any] {
            topic = Topic(fromSingleAnswerJSON: topicJSON)
        }
        // user
        guard let user = User(json: userJSON) else { return nil }
        // likes
        var likes: [Like] = []
        for likeJSON in likesJSON {
            guard let like = likeJSON as? [String: Any] else { return nil }
            if let like = Like(fromSingleAnswerJSON: like) {
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
        self.init(id: id, title: title, audioURL: audioURL, noteURL: noteURL, ref: ref, updatedAt: updatedAt, user: user, likes: likes, comments: comments, topic: topic)
    }
}
