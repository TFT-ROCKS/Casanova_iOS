//
//  String+Helper.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 10/2/18.
//  Copyright © 2018 Xiaoyu Guo. All rights reserved.
//

import Foundation

extension String {
    func toDictionary(splitter: String = ";", delimiter: String = "=") -> [String:Any] {
        var dict = [String:Any]()
        let arr = self.components(separatedBy: splitter)
        for element in arr {
            let newElement = element.trimmingCharacters(in: CharacterSet.whitespaces)
            let elements = newElement.components(separatedBy: delimiter)
            if elements.count == 2 {
                dict[elements[0]] = elements[1]
            }
        }
        return dict
    }
}
