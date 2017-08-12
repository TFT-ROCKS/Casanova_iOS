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
}
