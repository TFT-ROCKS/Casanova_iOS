//
//  TopicBriefTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/18/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import TagListView
import Nuke

class TopicBriefTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var difficultyView: UIView!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var numOfAnswersLabel: UILabel!
    @IBOutlet weak var answerImageView: UIImageView!
    @IBOutlet weak var chineseTitleLabel: UILabel!
    @IBOutlet weak var actualContentView: UIView!
    @IBOutlet weak var shadowView: UIView!
    
    let difficulties: [String] = ["Beginner", "Easy", "Medium", "Hard", "Ridiculous"]
    
    var topic: Topic! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        // Update UI
        
        titleLabel.text = topic.title
        chineseTitleLabel.text = topic.chineseTitle ?? Placeholder.chineseTopicTitlePlaceholderStr
        difficultyLabel.text = difficulties[topic.level - 1]
        numOfAnswersLabel.text = "\(topic.answersCount)个回答"
        let diffView = DifficultyView(frame: difficultyView.bounds, level: topic.level)
        diffView.tag = 101
        diffView.backgroundColor = UIColor.clear
        for subView in difficultyView.subviews {
            if subView.tag == 101 {
                subView.removeFromSuperview()
            }
        }
        difficultyView.addSubview(diffView)
        
        // tag list view config
        tagListView.removeAllTags()
        for tag in topic.tags.components(separatedBy: ",") {
            let newTag = "#\(tag.uppercased())"
            tagListView.addTag(newTag)
        }
        tagListView.textFont = UIFont.sfpr(size: 12)
        tagListView.textColor = UIColor.brandColor
        tagListView.borderColor = UIColor.brandColor
        
        if let imageURL = topic.answerPictureUrl {
            Manager.shared.loadImage(with: URL(string: imageURL)!, into: answerImageView)
        } else {
            answerImageView.image = imageForTopic
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = .none

        shadowView.layer.cornerRadius = 8
        shadowView.layer.shadowColor = UIColor.shadowColor.cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        actualContentView.backgroundColor = UIColor.white
        actualContentView.layer.cornerRadius = 8
        actualContentView.layer.masksToBounds = true
        
        answerImageView.contentMode = .scaleAspectFill
        answerImageView.clipsToBounds = true
        answerImageView.layer.cornerRadius = 2
        titleLabel.font = UIFont.sfps(size: 16)
        titleLabel.textColor = UIColor.bodyTextColor
        chineseTitleLabel.font = UIFont.pfr(size: 14)
        chineseTitleLabel.textColor = UIColor.bodyTextColor
        difficultyLabel.font = UIFont.pfr(size: 12)
        numOfAnswersLabel.font = UIFont.pfr(size: 12)
    }
    
    // MARK: - Utils
    private var imageForTopic: UIImage {
        let id = topic.id
        let tags = topic.tags.components(separatedBy: ",")
        let tagToUse = tags[id % tags.count].lowercased()
        let imageName = tagToUse + "\(id % 3 + 1)" // 1, 2, 3
        
        return UIImage(named: imageName) ?? UIImage(named: "others")!
    }
}
