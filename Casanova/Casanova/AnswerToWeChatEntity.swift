//
//  AnswerToWeChatEntity.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 10/31/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class AnswerToWeChatEntity: GeneralShareEntity {
    var title: String
    var description: String
    var image: UIImage
    var musicUrl: String
    var musicDataUrl: String
    
    init(title: String,
         description: String,
         image: UIImage,
         musicUrl: String,
         musicDataUrl: String) {
        self.title = title
        self.description = description
        self.image = image
        self.musicUrl = musicUrl
        self.musicDataUrl = musicDataUrl
        
        super.init()
    }
}
