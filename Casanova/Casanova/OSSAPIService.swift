//
//  OSSAPIService.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 9/20/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

// signature generation reference: https://help.aliyun.com/document_detail/32059.html?spm=5176.doc32046.6.711.ptC717

import Foundation
import AliyunOSSiOS

class OSSAPIService {
    /// Singleton
    static let shared = OSSAPIService()
    
    let region = "oss-cn-shanghai"
    let bucket = "tftsandbox"
    let accessKeyId = "LTAIusdNpq7wCQKX"
    let accessKeySecret = "TkPl85Pm0rGvXv171Lk6utrbhhBwl2"
    
    lazy var client: OSSClient = {
        let endpoint = "https://\(self.region).aliyuncs.com"
        let credential = OSSCustomSignerCredentialProvider(implementedSigner: { (contentToSign, error) -> String? in
            let signature = OSSUtil.calBase64Sha1(withData: contentToSign, withSecret: self.accessKeySecret)
            return String(format: "OSS %@:%@", self.accessKeyId, signature!)
        })
        let config = OSSClientConfiguration()
        config.maxRetryCount = 3
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 24 * 60 * 60
        let client = OSSClient(endpoint: endpoint, credentialProvider: credential!, clientConfiguration: config)
        
        return client
    }()
    
    func uploadAudioFile(url: URL, withProgressBlock pBlock: @escaping (Int64, Int64, Int64) -> Swift.Void, withCompletionBlock cBlock: @escaping (ErrorMessage?, String?, String?) -> Swift.Void) {
        
        let put = OSSPutObjectRequest()
        let uuid = UUID().uuidString
        put.bucketName = bucket
        put.objectKey = "recordings/\(uuid).wav"
        put.uploadingFileURL = url
        put.uploadProgress = pBlock
        
        let putTask = client.putObject(put)
        putTask.continue({ task in
            if task.error == nil {
                let urlStr = "http://tftsandbox.oss-cn-shanghai.aliyuncs.com/\(put.objectKey!)"
                cBlock(nil, urlStr, uuid)
                //print("upload object success!")
            } else {
                let errMsg = ErrorMessage(msg: task.error.debugDescription)
                cBlock(errMsg, nil, nil)
                //print("upload object failed, error: \(String(describing: task.error))")
            }
            return nil
        })
    }
    
    func deleteAudioFile(uuid: String) {
        let delete = OSSDeleteObjectRequest()
        let uuid = uuid
        delete.bucketName = bucket
        delete.objectKey = "recordings/\(uuid).wav"
        
        let deleteTask = client.deleteObject(delete)
        deleteTask.continue({ task in
            if task.error == nil {
                
            } else {
                
            }
            return nil
        })
    }
}
