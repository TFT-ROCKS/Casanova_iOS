//
//  HomeTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/18/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import TagListView

class HomeTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var difficultyImgView: UIImageView!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var numOfAnswersLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var answererNameLabel: UILabel!
    @IBOutlet weak var answerTimeLabel: UILabel!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var numOfStarsLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var numOfLikesLabel: UILabel!
    
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
        
        // tag list view config
        tagListView.removeAllTags()
        tagListView.addTags(topic.tags.components(separatedBy: ","))
        tagListView.textFont = UIFont(name: "HelveticaNeue", size: 16)!
        
        // substring answer to 300 chars
        let answer = topic.answerTitle
        answerLabel.text = answer.components(separatedBy: " ")[0...50].joined(separator: " ") + " ..."
        answererNameLabel.text = topic.userName
        answerTimeLabel.text = TimeManager.shared.elapsedDateString(fromString: topic.updatedAt)
        numOfLikesLabel.text = "\(topic.likeCount)"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        starButton.setImage(#imageLiteral(resourceName: "star"), for: .normal)
        likeButton.setImage(#imageLiteral(resourceName: "heart"), for: .normal)
        difficultyImgView.image = #imageLiteral(resourceName: "difficulty")
        profileButton.setImage(#imageLiteral(resourceName: "tftProfile"), for: .normal)
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
