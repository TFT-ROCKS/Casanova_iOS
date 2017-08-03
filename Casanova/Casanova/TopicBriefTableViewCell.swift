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
        titleLabel.text = topic.topicTitle
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
        tagListView.textFont = UIFont(name: "Avenir-Medium", size: 10)!
        
        // substring answer to 300 chars
//        let answer = topic.answerTitle
//        answerLabel.text = answer.components(separatedBy: " ")[0...50].joined(separator: " ") + " ..."
//        answererNameLabel.text = topic.userName
//        answerTimeLabel.text = TimeManager.shared.elapsedDateString(fromString: topic.updatedAt)
//        numOfLikesLabel.text = "\(topic.likeCount)"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        starButton.setBackgroundImage(#imageLiteral(resourceName: "star"), for: .normal)
//        likeButton.setBackgroundImage(#imageLiteral(resourceName: "heart"), for: .normal)
//        profileButton.setBackgroundImage(#imageLiteral(resourceName: "tftProfile"), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func difficulty(fromLevel level: Int) -> String {
        switch level {
        case 1:
            return "Beginner"
        case 2:
            return "Easy"
        case 3:
            return "Medium"
        case 4:
            return "Hard"
        case 5:
            return "Ridiculous"
        default:
            return "Beginner"
        }
    }
    
}
