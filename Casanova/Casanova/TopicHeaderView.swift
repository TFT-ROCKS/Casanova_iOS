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
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var numOfStarsLabel: UILabel!
    
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
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        mode = .plain
    }
    
    func updateUI() {
        // Update UI
        starButton.setBackgroundImage(#imageLiteral(resourceName: "star-h"), for: .normal)
        titleLabel.text = topic.title
        difficultyLabel.text = difficulties[topic.level - 1]
        numOfAnswersLabel.text = "\(topic.answersCount) answers"
        
        let diffView = DifficultyView(frame: difficultyView.bounds, level: topic.level)
        diffView.tag = 101
        diffView.backgroundColor = UIColor.clear
        difficultyView.backgroundColor = UIColor.clear
        difficultyView.addSubview(diffView)
        
        // tag list view config
        tagListView.removeAllTags()
        for tag in topic.tags.components(separatedBy: ",") {
            let newTag = "#\(tag.uppercased())"
            tagListView.addTag(newTag)
        }
        tagListView.textFont = UIFont(name: "Avenir-Medium", size: 12)!
        
    }
    
    func cool() {
        if mode == .plain {
            mode = .cool
            let bgdImgView = UIImageView(frame: CGRect(x: 0, y: -1, width: contentView.bounds.width, height: contentView.bounds.height))
            bgdImgView.tag = 111
            bgdImgView.image = #imageLiteral(resourceName: "header_bgd")
            contentView.addSubview(bgdImgView)
            contentView.sendSubview(toBack: bgdImgView)
            
            // remove diffView and reinit it
            for view in difficultyView.subviews {
                if view.tag == 101 {
                    view.removeFromSuperview()
                }
            }
            let diffView = DifficultyView(frame: difficultyView.bounds, level: topic.level, mode: .cool)
            diffView.tag = 101
            diffView.backgroundColor = UIColor.clear
            difficultyView.addSubview(diffView)
            
            // diff label
            difficultyLabel.textColor = UIColor.white
            numOfAnswersLabel.textColor = UIColor.white
            titleLabel.textColor = UIColor.white
            numOfStarsLabel.textColor = UIColor.white
            tagListView.textColor = UIColor.white
        }
    }
    
    func plain() {
        if mode == .cool {
            mode = .plain
            for view in contentView.subviews {
                if view.tag == 111 {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
