//
//  WeChatManager.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 10/30/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class WeChatManager {
    static let shared = WeChatManager()
    public var scene: WXScene = WXSceneSession
    
    func sendMusicContent(entity: GeneralShareEntity) {
        guard let entity = entity as? AnswerToWeChatEntity else {
            return
        }
        let message = WXMediaMessage()
        message.title = entity.title
        message.description = entity.description
        message.setThumbImage(entity.image)
        
        let ext = WXMusicObject()
        ext.musicUrl = entity.musicUrl
        ext.musicDataUrl = entity.musicDataUrl
        
        message.mediaObject = ext
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(scene.rawValue)
        
        WXApi.send(req)
    }
    
    func sendLinkContent(entity: GeneralShareEntity) {
        guard let entity = entity as? AnswerToWeChatEntity else {
            return
        }
        let message = WXMediaMessage()
        message.title = entity.title
        message.description = entity.description
        message.setThumbImage(entity.image)
        
        let ext = WXWebpageObject()
        ext.webpageUrl = entity.musicUrl
//        ext.musicDataUrl = entity.musicDataUrl
        
        message.mediaObject = ext
        
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(scene.rawValue)
        
        WXApi.send(req)
    }
}
