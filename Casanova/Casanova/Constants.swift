//
//  Constants.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/6/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import UIKit
import Down

struct Notifications {
    static let userInfoPreparedNotification = Notification.Name("UserInfoPreparedNotification")
    static let userProfileUpdatedNotification = Notification.Name("UserProfileUpdatedNotification")
    static let userInfoUpdatedNotification = Notification.Name("UserInfoUpdatedNotification")
}

struct Errors {
    public static let usernameNotValid = "对不起，您输入的用户名无效"
    public static let emailNotValid = "不好意思，您输入的邮箱无效"
    public static let passwordNotValid = "您的密码是啥子？"
    public static let usernameOrEmailNotValid = "请输入用户名或者邮箱"
}

struct Tags {
    struct HomeVC {
        static let homeTableViewTag = 100
        static let tpoTableViewTag = 101
        static let levelTableViewTag = 102
        static let catTableViewTag = 103
    }
    struct SavedVC {
        
    }
    struct ProfileVC {
        struct SettingsVC {
            static let usernameTableViewCellTag = 10
            static let firstnameTableViewCellTag = 11
            static let lastnameTableViewCellTag = 12
        }
    }
}

struct StoryboadIDs {
    static let audioRecordViewController = "AudioRecordViewController"
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
    struct SavedVC {
        struct View {
            static let topicBriefAppendTableViewCell = "TopicBriefAppendTableViewCell"
            static let separatorLineTableViewCell = "SeparatorLineTableViewCell"
        }
    }
    struct TopicDetailVC {
        struct View {
            static let answerDefaultCell = "AnswerDefaultCell"
            static let answerWithoutTextCell = "AnswerWithoutTextCell"
            static let answerWithoutAudioCell = "AnswerWithoutAudioCell"
        }
    }
    struct AnswerDetailVC {
        static let answerNoteTableViewCell = "AnswerNoteTableViewCell"
        static let commentTableViewCell = "CommentDefaultCell"
        static let commentTableViewCellForCurrentUser = "CommentTableViewCellForCurrentUser"
    }
    struct ProfileVC {
        static let profileTableViewCell = "ProfileTableViewCell"
        static let settingsTableViewCell = "ProfileSettingsTableViewCell"
    }
}

struct Duration {
    struct HomeVC {
        struct FilterView {
            static let fadeInOrOutDuration: Double = 0.2
        }
    }
    struct TopicDetailVC {
        struct View {
            static let fadeInOrOutDuration: Double = 0.2
            static let rewardFadeInDuration: Double = 1
            static let rewardFadeOutDuration: Double = 2
        }
    }
    struct AnswerDetailVC {
        static let fadeInOrOutDuration: Double = 0.3
    }
}

struct AttrString {
    static func paragraphStyle(lineSpacing: CGFloat) -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        return paragraphStyle
    }
    
    static func paragraphStyle(alignment: NSTextAlignment) -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        return paragraphStyle
    }
    
    static func topicAttrString(_ string: String) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: string)
        attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle(lineSpacing: 1.5), range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSFontAttributeName, value: UIFont(name: "Muli-Light", size: 14)!, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSKernAttributeName, value: -0.2, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.bodyTextColor, range: NSMakeRange(0, attrString.length))
        return attrString
    }
    
    static func smallTopicAttrString(_ string: String) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: string)
        attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle(lineSpacing: 0), range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSFontAttributeName, value: UIFont(name: "Muli-Light", size: 14)!, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSKernAttributeName, value: -0.2, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.bodyTextColor, range: NSMakeRange(0, attrString.length))
        return attrString
    }
    
    static func answerAttrString(_ string: String) -> NSAttributedString {
        let down = Down(markdownString: string)
        let temp = try? down.toAttributedString()
        let attrString = NSMutableAttributedString(attributedString: temp!)
        attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle(lineSpacing: 5), range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSFontAttributeName, value: UIFont(name: "MerriweatherLight", size: 13)!, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSKernAttributeName, value: -0.4, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.bodyTextColor, range: NSMakeRange(0, attrString.length))
        return attrString
    }
    
    static func commentAttrString(_ string: String) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: string)
        attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle(lineSpacing: 5), range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSFontAttributeName, value: UIFont(name: "MerriweatherLight", size: 13)!, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSKernAttributeName, value: -0.4, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.bodyTextColor, range: NSMakeRange(0, attrString.length))
        return attrString
    }
    
    static func titleAttrString(_ string: String, textColor: UIColor) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: string)
        attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle(alignment: .center), range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSFontAttributeName, value: UIFont(name: "PingFangSC-Regular", size: 17)!, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSForegroundColorAttributeName, value: textColor, range: NSMakeRange(0, attrString.length))
        return attrString
    }
    
    static func normalLabelAttrString(_ string: String) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: string)
        attrString.addAttribute(NSFontAttributeName, value: UIFont(name: "PingFangSC-Regular", size: 14)!, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.nonBodyTextColor, range: NSMakeRange(0, attrString.length))
        return attrString
    }
    
    static func smallLabelAttrString(_ string: String) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: string)
        attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle(alignment: .center), range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSFontAttributeName, value: UIFont(name: "PingFangSC-Regular", size: 12)!, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.nonBodyTextColor, range: NSMakeRange(0, attrString.length))
        return attrString
    }
}

struct Placeholder {
    static let answerImagePlaceholderURLStr = "https://placeimg.com/414/200/any"
    static let chineseTopicTitlePlaceholderStr = "中文翻译正在火速赶来，敬请期待..."
    static let answerTitlePlaceholderStr = "这个人很懒，什么也没说..."
}

