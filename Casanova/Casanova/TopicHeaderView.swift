//
//  TopicHeaderView.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/4/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import TagListView

enum TopicHeaderViewMode {
    case plain
    case cool
}

class TopicHeaderView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var difficultyView: UIView!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var numOfAnswersLabel: UILabel!
    
    var mode: TopicHeaderViewMode!
    
    let difficulties: [String] = ["Beginner", "Easy", "Medium", "Hard", "Ridiculous"]
    
    var topic: Topic! {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) { // For using custom view in code
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) { // For using custom view in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("TopicHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.backgroundColor = UIColor.white
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        mode = .plain
        difficultyLabel.font = UIFont.mr(size: 12)
        numOfAnswersLabel.font = UIFont.mr(size: 12)
    }
    
    func updateUI() {
        // Update UI
        titleLabel.text = topic.title
        titleLabel.font = UIFont.mb(size: 14)
        titleLabel.textColor = UIColor.bodyTextColor
        
        difficultyLabel.font = UIFont.mr(size: 12)
        difficultyLabel.text = difficulties[topic.level - 1]
        
        numOfAnswersLabel.text = "\(topic.answersCount)个回答"
        numOfAnswersLabel.font = UIFont.pfr(size: 12)
        numOfAnswersLabel.textColor = UIColor.nonBodyTextColor
        
        let diffView = DifficultyView(frame: difficultyView.bounds, level: topic.level)
        diffView.tag = 101
        diffView.backgroundColor = UIColor.clear
        difficultyView.backgroundColor = UIColor.clear
        difficultyView.addSubview(diffView)
        difficultyLabel.textColor = UIColor.nonBodyTextColor
        
        // tag list view config
        tagListView.removeAllTags()
        for tag in topic.tags.components(separatedBy: ",") {
            let newTag = "#\(tag.uppercased())"
            tagListView.addTag(newTag)
        }
        tagListView.textFont = UIFont.mr(size: 12)
        tagListView.textColor = UIColor.brandColor
        tagListView.borderColor = UIColor.brandColor
        tagListView.textColor = UIColor.brandColor
        tagListView.borderColor = UIColor.brandColor
    }
    
    func cool() {
        if mode == .plain {
            mode = .cool
            // add bgd img view
            let bgdImgView = UIImageView(frame: CGRect(x: 0, y: -1, width: contentView.bounds.width, height: contentView.bounds.height))
            bgdImgView.tag = 111
            bgdImgView.image = #imageLiteral(resourceName: "header_bgd")
            contentView.addSubview(bgdImgView)
            contentView.sendSubview(toBack: bgdImgView)
            
            // remove diffView and re-init it
            for view in difficultyView.subviews {
                if view.tag == 101 {
                    view.removeFromSuperview()
                }
            }
            let diffView = DifficultyView(frame: difficultyView.bounds, level: topic.level, mode: .cool)
            diffView.tag = 101
            diffView.backgroundColor = UIColor.clear
            difficultyView.addSubview(diffView)
            
            difficultyLabel.textColor = UIColor.white
            numOfAnswersLabel.textColor = UIColor.white
            titleLabel.textColor = UIColor.white
            tagListView.textColor = UIColor.white
            tagListView.borderColor = UIColor.white
        }
    }
    
    func plain() {
        if mode == .cool {
            mode = .plain
            // rm bgd img view
            for view in contentView.subviews {
                if view.tag == 111 {
                    view.removeFromSuperview()
                }
            }
            
            // remove diffView and re-init it
            for view in difficultyView.subviews {
                if view.tag == 101 {
                    view.removeFromSuperview()
                }
            }
            let diffView = DifficultyView(frame: difficultyView.bounds, level: topic.level, mode: .plain)
            diffView.tag = 101
            diffView.backgroundColor = UIColor.clear
            difficultyView.addSubview(diffView)
            
            difficultyLabel.textColor = UIColor.nonBodyTextColor
            numOfAnswersLabel.textColor = UIColor.nonBodyTextColor
            titleLabel.textColor = UIColor.nonBodyTextColor
            tagListView.textColor = UIColor.brandColor
            tagListView.borderColor = UIColor.brandColor
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
