//
//  Array+Helper.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/11/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

// MARK: - Array extension
extension Array {
    func toUpperCase() -> [String] {
        var res: [String] = []
        for str in self {
            if let s = str as? String {
                res.append(s.uppercased())
            }
        }
        return res
    }
    
    func toLowerCase() -> [String] {
        var res: [String] = []
        for str in self {
            if let s = str as? String {
                res.append(s.lowercased())
            }
        }
        return res
    }
    
    /// Check if answers array contains this topic
    func containsTopic(_ id: Int) -> Bool {
        for answer in self {
            if let answer = answer as? Answer {
                if answer.topic?.id == id { return true }
            }
        }
        return false
    }
    
    /// Remove certain answer from answers array if contains
    mutating func removeAnswer(_ id: Int) {
        var index: Int? = nil
        for i in 0..<self.count {
            if let answer = self[i] as? Answer {
                if answer.id == id {
                    index = i
                }
            }
        }
        if index != nil {
            self.remove(at: index!)
        }
    }
    
    // Remove certain comment from comments array if contains
    mutating func removeComment(_ id: Int) {
        var index: Int? = nil
        for i in 0..<self.count {
            if let comment = self[i] as? Comment {
                if comment.id == id {
                    index = i
                }
            }
        }
        if index != nil {
            self.remove(at: index!)
        }
    }
    
    // Remove certain like from likes array if contains
    mutating func removeLike(_ id: Int) {
        var index: Int? = nil
        for i in 0..<self.count {
            if let like = self[i] as? Like {
                if like.id == id {
                    index = i
                }
            }
        }
        if index != nil {
            self.remove(at: index!)
        }
    }
}
