//
//  TopicBriefTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/18/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import TagListView

protocol TopicHeaderTableViewCellDelegate {
    func answerTopicButtonTapped(_ sender: UIButton)
}

class TopicHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var difficultyView: UIView!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var numOfAnswersLabel: UILabel!
    @IBOutlet weak var answerButton: UIButton!
    
    func bind(viewModel: TopicHeaderTableViewCellViewModel) {
        guard viewModel.allowedAccess(self) else { return }
        
        updateUI(with: viewModel)
        
        // bind
        viewModel.didUpdate = self.updateUI
        
        // actions
        answerButton.addTarget(viewModel, action: #selector(viewModel.wannaAnswer), for: .touchUpInside)
    }
    
    func updateUI(with viewModel: TopicHeaderTableViewCellViewModel) {
        // Update UI
        titleLabel.text = viewModel.titleText
        difficultyLabel.text = viewModel.difficultyText
        numOfAnswersLabel.text = viewModel.answersCountText
        
        // difficulty view
        let diffView = DifficultyView(frame: difficultyView.bounds, level: viewModel.level)
        diffView.tag = 101
        diffView.backgroundColor = UIColor.clear
        for subView in difficultyView.subviews {
            if subView.tag == 101 {
                subView.removeFromSuperview()
            }
        }
        difficultyView.addSubview(diffView)
        
        // tag list view
        tagListView.removeAllTags()
        for tag in viewModel.tags {
            let newTag = "#\(tag.uppercased())"
            tagListView.addTag(newTag)
        }
        tagListView.textFont = UIFont.mr(size: 12)
        tagListView.textColor = UIColor.brandColor
        tagListView.borderColor = UIColor.brandColor
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.white
        titleLabel.font = UIFont.mr(size: 14)
        titleLabel.textColor = UIColor.bodyTextColor
        selectionStyle = .none
        difficultyLabel.font = UIFont.mr(size: 12)
        numOfAnswersLabel.font = UIFont.mr(size: 12)
        answerButton.setTitleColor(UIColor.white, for: .normal)
        answerButton.backgroundColor = UIColor.brandColor
        answerButton.layer.cornerRadius = 3
        answerButton.layer.masksToBounds = true
        
        contentView.layer.shadowColor = UIColor.shadowColor.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.layer.shadowOpacity = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
