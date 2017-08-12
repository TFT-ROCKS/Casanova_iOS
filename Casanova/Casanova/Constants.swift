//
//  Constants.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/6/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import UIKit

struct Tags {
    struct HomeVC {
        static let homeTableViewTag = 100
        static let tpoTableViewTag = 101
        static let levelTableViewTag = 102
        static let catTableViewTag = 103
    }
    struct SavedVC {
        
    }
}

struct Colors {
    struct HomeVC {
        struct View {
            static func homeTableViewBackgroundColor() -> UIColor { return UIColor(red: 248 / 255.0, green: 250 / 255.0, blue: 252 / 255.0, alpha: 1) }
            static func topicBriefTableViewCellShadowColor() -> UIColor { return UIColor(red: 217/255.0, green: 225/255.0, blue: 239/255.0, alpha: 1) }
        }
        struct FilterView {
            static func filterLabelTextColor() -> UIColor { return UIColor(red: 75.0 / 255.0, green: 205.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0) }
            static func filterSelectionTextColor() -> UIColor { return UIColor(red: 74.0 / 255.0, green: 74.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0) }
            static func filterCheckboxColor() -> UIColor { return UIColor(red: 15.0 / 255.0, green: 189.0 / 255.0, blue: 232.0 / 255.0, alpha: 1.0) }
        }
    }
    struct CommonVC {
        struct TagListView {
            static func tagLabelTextColor() -> UIColor { return UIColor(red: 75/255.0, green: 205/255.0, blue: 237/255.0, alpha: 1) }
            static func tagLabelBackgroundColor() -> UIColor { return UIColor(red: 232/255.0, green: 248/255.0, blue: 253/255.0, alpha: 1) }
            static func closeButtonColor() -> UIColor { return UIColor(red: 75/255.0, green: 205/255.0, blue: 237/255.0, alpha: 1) }
        }
        struct NavBar {
            static func tintColor() -> UIColor { return UIColor(red: 248 / 255.0, green: 250 / 255.0, blue: 252 / 255.0, alpha: 1) }
            static func barTintColor() -> UIColor { return UIColor.white }
            static func borderColor() -> UIColor { return barTintColor() }
            static func tftTitleColor() -> UIColor { return UIColor(red: 75.0 / 255.0, green: 205.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0) }
        }
    }
    struct TopicDetailVC {
        struct NavBar {
            static func tintColor() -> UIColor { return UIColor(red: 164.0 / 255.0, green: 170.0 / 255.0, blue: 179.0 / 255.0, alpha: 1.0) }
        }
    }
}

struct Fonts {
    struct HomeVC {
        struct FilterView {
            static func filterLabelTextFont() -> UIFont { return UIFont(name: "Montserrat-Light", size: 14.0)! }
            static func filterSelectionTextFont() -> UIFont { return UIFont(name: "Montserrat-Light", size: 17.0)! }
        }
    }
    struct CommonVC {
        struct TagListView {
            static func tagLabelTextFont() -> UIFont { return UIFont(name: "Avenir-Medium", size: 12.0)! }
        }
        struct NavBar {
            static func tftTitleTextFont() -> UIFont { return UIFont(name: "Montserrat-Regular", size: 18.0)! }
        }
    }
    struct TopicDetailVC {
        struct NavBar {
            static func titleTextFont() -> UIFont { return UIFont(name: "Montserrat-Light", size: 18.0)! }
        }
    }
}

struct ReuseIDs {
    struct HomeVC {
        struct View {
            static let topicBriefTableViewCell = "TopicBriefTableViewCell"
            static let loadMoreTableViewCell = "LoadMoreTableViewCell"
        }
        struct FilterView {
            static let filterTableViewCell = "FilterTableViewCell"
        }
    }
}

struct Duration {
    struct HomeVC {
        struct FilterView {
            static let fadeInOrOutDuration: Double = 0.2
        }
    }
}
