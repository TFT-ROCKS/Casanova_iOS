//
//  TopicBriefTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/18/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import TagListView

class TopicHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chineseTitleLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var difficultyView: UIView!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var numOfAnswersLabel: UILabel!
    
    func bind(viewModel: TopicHeaderTableViewCellViewModel) {
        guard viewModel.allowedAccess(self) else { return }
        
        updateUI(with: viewModel)
        
        // bind
        viewModel.didUpdate = self.updateUI
    }
    
    func updateUI(with viewModel: TopicHeaderTableViewCellViewModel) {
        // Update UI
        titleLabel.text = viewModel.titleText
        chineseTitleLabel.text = viewModel.chineseTitleText
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
        tagListView.textFont = UIFont.sfpr(size: 12)
        tagListView.textColor = UIColor.brandColor
        tagListView.borderColor = UIColor.brandColor
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        titleLabel.font = UIFont.sfps(size: 16)
        titleLabel.textColor = UIColor.bodyTextColor
        chineseTitleLabel.font = UIFont.pfr(size: 14)
        chineseTitleLabel.textColor = UIColor.bodyTextColor
        difficultyLabel.font = UIFont.pfr(size: 12)
        numOfAnswersLabel.font = UIFont.pfr(size: 12)
        
        contentView.backgroundColor = UIColor.white
        contentView.layer.shadowColor = UIColor.shadowColor.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.layer.shadowOpacity = 1
    }
    
}
