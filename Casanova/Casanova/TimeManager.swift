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
            return "\(Int(interval)) seconds ago"
        } else if interval / (60.0 * 60.0) < 1.0 {
            // less than 1 hour, display in minutes
            return "\(Int(interval / 60.0)) minutes ago"
        } else if interval / (60.0 * 60.0 * 24.0) < 1.0 {
            // less than 1 day, display in hours
            return "\(Int(interval / (60.0 * 60.0))) hours ago"
        } else if interval / (60.0 * 60.0 * 24.0 * MAX_DAYS) < 1.0 {
            // less than MAX_DAYS days, display in days
            return "\(Int(interval / (60.0 * 60.0 * 24.0))) days ago"
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
}
