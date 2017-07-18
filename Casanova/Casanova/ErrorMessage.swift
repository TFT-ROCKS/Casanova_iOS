//
//  ErrorMessage.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class ErrorMessage {
    let msg: String
    
    init(msg: String?) {
        self.msg = msg ?? "no error msg to show"
    }
}
