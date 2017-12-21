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
        tagListView.textFont = UIFont.mr(size: 12)
        tagListView.textColor = UIColor.brandColor
        tagListView.borderColor = UIColor.brandColor
        
        answerImageView.image = UIImage(named: topic.tags.components(separatedBy: ",").first?.lowercased() ?? "others")!
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear

        actualContentView.backgroundColor = UIColor.white
        actualContentView.layer.cornerRadius = 2
        actualContentView.layer.masksToBounds = false
        actualContentView.layer.shadowColor = UIColor.shadowColor.cgColor
        actualContentView.layer.shadowOpacity = 1
        actualContentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        answerImageView.contentMode = .scaleAspectFill
        answerImageView.clipsToBounds = true
        answerImageView.layer.cornerRadius = 2
        titleLabel.font = UIFont.mb(size: 13)
        titleLabel.textColor = UIColor.bodyTextColor
        chineseTitleLabel.font = UIFont.pfr(size: 13)
        chineseTitleLabel.textColor = UIColor.bodyTextColor
        difficultyLabel.font = UIFont.mr(size: 12)
        numOfAnswersLabel.font = UIFont.pfr(size: 12)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
