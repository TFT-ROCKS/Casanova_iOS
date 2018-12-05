//
//  CookieManager.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 10/2/18.
//  Copyright © 2018 Xiaoyu Guo. All rights reserved.
//

import Foundation
import Alamofire

class CookieManager {
    /// Singleton
    static let shared = CookieManager()
    
    func fetchCookiesFromHeaders(headers: [AnyHashable: Any]?, url: URL?) {
        guard
            let headers = headers as? [String: String],
            let url = url
            else { return }
        
        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: url)
        print(cookies)
        
        updateCookies(cookies: cookies, url: url)
    }
    
    func updateCookies(cookies: [HTTPCookie], url: URL) {
        Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookies(cookies, for: url, mainDocumentURL: nil)
    }
}
