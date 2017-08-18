//
//  TopicBriefTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/18/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import TagListView

class TopicBriefTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var difficultyView: UIView!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var numOfAnswersLabel: UILabel!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var numOfStarsLabel: UILabel!
    
    let difficulties: [String] = ["Beginner", "Easy", "Medium", "Hard", "Ridiculous"]
    
    var topic: Topic! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        // Update UI
        
        titleLabel.attributedText = AttrString.topicAttrString(topic.title)
        difficultyLabel.text = difficulties[topic.level - 1]
        numOfAnswersLabel.text = "\(topic.answersCount) answers"
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
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.bgdColor
        selectionStyle = .none
        starButton.setBackgroundImage(#imageLiteral(resourceName: "star-h"), for: .normal)
        
        difficultyLabel.font = UIFont.mr(size: 14)
        numOfAnswersLabel.font = UIFont.mr(size: 14)
        numOfStarsLabel.font = UIFont.mr(size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
