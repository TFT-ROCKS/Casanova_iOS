//
//  OSSManager.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 9/20/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import AliyunOSSiOS

class OSSManager {
    /// Singleton
    static let shared = OSSManager()
    
    let region = "oss-cn-shanghai"
    let bucket = "tftsandbox"
    let accessKeyId = "LTAIusdNpq7wCQKX"
    let accessKeySecret = "TkPl85Pm0rGvXv171Lk6utrbhhBwl2"
    
    func uploadAudioFile(url: URL, withProgressBlock pBlock: @escaping (Int64, Int64, Int64) -> Swift.Void, withCompletionBlock cBlock: @escaping (ErrorMessage?, String?) -> Swift.Void) {
        let endpoint = "https://\(region).aliyuncs.com"
        let credential = OSSCustomSignerCredentialProvider(implementedSigner: { (contentToSign, error) -> String? in
            let signature = OSSUtil.calBase64Sha1(withData: contentToSign, withSecret: self.accessKeySecret)
            return String(format: "OSS %@:%@", self.accessKeyId, signature!)
        })
        let config = OSSClientConfiguration()
        config.maxRetryCount = 3
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 24 * 60 * 60
        let client = OSSClient(endpoint: endpoint, credentialProvider: credential!, clientConfiguration: config)
        
        let put = OSSPutObjectRequest()
        put.bucketName = bucket
        put.objectKey = "recordings/\(UUID().uuidString).wav"
        put.uploadingFileURL = url
        put.uploadProgress = pBlock
        
        let putTask = client.putObject(put)
        putTask.continue({ task in
            if task.error == nil {
                let urlStr = "http://tftsandbox.oss-cn-shanghai.aliyuncs.com/\(put.objectKey!)"
                cBlock(nil, urlStr)
                print("upload object success!")
            } else {
                let errMsg = ErrorMessage(msg: task.error.debugDescription)
                cBlock(errMsg, nil)
                print("upload object failed, error: \(String(describing: task.error))")
            }
            return nil
        })
    }
}
