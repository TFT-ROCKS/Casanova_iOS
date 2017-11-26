//
//  Alamofire+Helper.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 11/26/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import Alamofire

extension Alamofire.SessionManager {
    @discardableResult
    public func requestWithoutCache(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)//you can pass URLRequest.CachePolicy as parameter
        -> DataRequest
    {
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: headers)
            urlRequest.cachePolicy = .reloadIgnoringCacheData // <<== Cache disabled
            let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
            return request(encodedURLRequest)
        } catch {
            // TODO: find a better way to handle error
            print(error)
            return request(URLRequest(url: URL(string: "http://example.com/wrong_request")!))
        }
    }
}

class AlamofireManager {
    static let shared = AlamofireManager()
    
    @discardableResult
    public func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DataRequest
    {
        return Alamofire.SessionManager.default.requestWithoutCache(
            url,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
        )
    }
}
