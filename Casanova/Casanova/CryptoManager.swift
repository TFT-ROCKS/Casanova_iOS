//
//  CryptoManager.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 10/8/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import IDZSwiftCommonCrypto

class CryptoManager {
    let key = arrayFrom(hexString: "2b7e151628aed2a6abf7158809cf4f3c")
    let iv = arrayFrom(hexString: "9cf4a58c2b0a28aee1f367151f786d2b")
    
    static let shared = CryptoManager()
    
    func bytesFromEncrpyt(string: String) -> [UInt8]? {
        let cryptor = Cryptor(operation:.encrypt, algorithm:.aes, options:.PKCS7Padding, key:key, iv:iv)
        let cipherText = cryptor.update(string: string)?.final()
        
        return cipherText
    }
    
    func stringFromDecrpyt(bytes: [UInt8]) -> String {
        let cryptor = Cryptor(operation:.decrypt, algorithm:.aes, options:.PKCS7Padding, key:key, iv:iv)
        let decryptedPlainText = cryptor.update(byteArray: bytes)?.final()
        let decryptedString = decryptedPlainText!.reduce("") { $0 + String(UnicodeScalar($1)) }
        
        return decryptedString
    }
    
}
