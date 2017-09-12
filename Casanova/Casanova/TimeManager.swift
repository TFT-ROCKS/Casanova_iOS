//
//  TimeManager.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/20/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class TimeManager {
    static let shared = TimeManager()
    let MAX_DAYS: Double = 20.0
    
    func date(fromString formattedDate: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return formatter.date(from: formattedDate) ?? Date()
    }
    
    func elapsedDateString(fromDate date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval / 60.0 < 1.0 {
            // less than 1 min, display in seconds
            return "\(Int(interval))秒前"
        } else if interval / (60.0 * 60.0) < 1.0 {
            // less than 1 hour, display in minutes
            return "\(Int(interval / 60.0))分钟前"
        } else if interval / (60.0 * 60.0 * 24.0) < 1.0 {
            // less than 1 day, display in hours
            return "\(Int(interval / (60.0 * 60.0)))小时前"
        } else if interval / (60.0 * 60.0 * 24.0 * MAX_DAYS) < 1.0 {
            // less than MAX_DAYS days, display in days
            return "\(Int(interval / (60.0 * 60.0 * 24.0)))天前"
        } else {
            // more than MAX_DAYS days, display original date-time
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from:date)
        }
    }
    
    func elapsedDateString(fromString dateString: String) -> String {
        let date = self.date(fromString: dateString)
        return self.elapsedDateString(fromDate: date)
    }
    
    func timeString(time: TimeInterval) -> String {
//        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    func stringFromTimeInterval(_ interval: TimeInterval) -> String {
        
        let ti = Int(interval)
        
        let ms = Int(interval.truncatingRemainder(dividingBy: 1) * 1000)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
    }
}
