//
//  AnswerDetailTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/31/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import AVFoundation

enum AnswerMode {
    case short
    case full
}

class AnswerDetailTableViewCell: UITableViewCell, AVAudioPlayerDelegate {
    
    var answererButton: UIImageView!
    var answererNameLabel: UILabel!
    var answerTimeLabel: UILabel!
    var audioToggle: JTMaterialSwitch!
    var likeButton: UIButton!
    var likeCountLabel: UILabel!
    var commentButton: UIButton!
    var commentCountLabel: UILabel!
    var audioButton: UIButton?
    var answerTitleTextView: UITextView!
    var trashButton: UIButton!
    
    var mode: AnswerMode!
    var isLikedCard: Bool = false
    var canBeDeleted: Bool = false
    var canAudioToggle: Bool = false
    
    var answer: Answer! {
        didSet {
            updateUI()
        }
    }
    
    var bottomConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        answererButton = UIImageView(frame: .zero)
        answererNameLabel = UILabel(frame: .zero)
        answerTimeLabel = UILabel(frame: .zero)
        likeCountLabel = UILabel(frame: .zero)
        likeButton = UIButton(frame: .zero)
        commentCountLabel = UILabel(frame: .zero)
        commentButton = UIButton(frame: .zero)
        answerTitleTextView = UITextView(frame: .zero)
        trashButton = UIButton(frame: .zero)
        
        contentView.addSubview(answererButton)
        contentView.addSubview(answererNameLabel)
        contentView.addSubview(answerTimeLabel)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(commentCountLabel)
        contentView.addSubview(commentButton)
        contentView.addSubview(answerTitleTextView)
        contentView.addSubview(trashButton)
        
        answererButton.translatesAutoresizingMaskIntoConstraints = false
        answererNameLabel.translatesAutoresizingMaskIntoConstraints = false
        answerTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        commentCountLabel.translatesAutoresizingMaskIntoConstraints = false
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        answerTitleTextView?.translatesAutoresizingMaskIntoConstraints = false
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Constraints
        
        // answererButton constraints
        answererButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        answererButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        answererButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17).isActive = true
        answererButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24).isActive = true
        
        // answererNameLabel constraints
        answererNameLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        answererNameLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        answererNameLabel.leadingAnchor.constraint(equalTo: answererButton.trailingAnchor, constant: 20).isActive = true
        answererNameLabel.topAnchor.constraint(equalTo: answererButton.topAnchor).isActive = true
        
        // answerTimeLabel constraints
        answerTimeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        answerTimeLabel.heightAnchor.constraint(equalToConstant: 19).isActive = true
        answerTimeLabel.leadingAnchor.constraint(equalTo: answererNameLabel.leadingAnchor).isActive = true
        answerTimeLabel.topAnchor.constraint(equalTo: answererNameLabel.bottomAnchor, constant: 5).isActive = true
        
        // likeCountLabel constraints
//        likeCountLabel.widthAnchor.constraint(equalToConstant: 24).isActive = true
        likeCountLabel.heightAnchor.constraint(equalToConstant: 19).isActive = true
//        likeCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        likeCountLabel.centerYAnchor.constraint(equalTo: answererButton.centerYAnchor).isActive = true
        
        // likeButton constraints
        likeButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        likeButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        likeButton.trailingAnchor.constraint(equalTo: likeCountLabel.leadingAnchor, constant: -8).isActive = true
        likeButton.centerYAnchor.constraint(equalTo: answererButton.centerYAnchor).isActive = true
        
        // commentCount constraints
//        commentCountLabel.widthAnchor.constraint(equalToConstant: 24).isActive = true
        commentCountLabel.heightAnchor.constraint(equalToConstant: 19).isActive = true
        commentCountLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -8).isActive = true
        commentCountLabel.centerYAnchor.constraint(equalTo: answererButton.centerYAnchor).isActive = true
        
        // commentButton constraints
        commentButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        commentButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        commentButton.trailingAnchor.constraint(equalTo: commentCountLabel.leadingAnchor, constant: -8).isActive = true
        commentButton.centerYAnchor.constraint(equalTo: answererButton.centerYAnchor).isActive = true
        
        // trashButton constraints
        trashButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        trashButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        trashButton.trailingAnchor.constraint(equalTo: commentButton.leadingAnchor, constant: -12).isActive = true
        trashButton.centerYAnchor.constraint(equalTo: answererButton.centerYAnchor).isActive = true
        
        if reuseIdentifier! != ReuseIDs.TopicDetailVC.View.answerWithoutAudioCell {
            audioButton = UIButton(frame: .zero)
            
            contentView.addSubview(audioButton!)
            
            audioButton!.translatesAutoresizingMaskIntoConstraints = false
            
            // audioButton constraints
            audioButton!.widthAnchor.constraint(equalToConstant: 24).isActive = true
            audioButton!.heightAnchor.constraint(equalToConstant: 24).isActive = true
            audioButton!.centerYAnchor.constraint(equalTo: commentCountLabel.centerYAnchor).isActive = true
            audioButton!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
            likeCountLabel.trailingAnchor.constraint(equalTo: audioButton!.leadingAnchor, constant: -8).isActive = true
            
            // config
            audioButton!.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
        } else {
            likeCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        }
        
        answerTitleTextView.topAnchor.constraint(equalTo: answererButton.bottomAnchor, constant: 20).isActive = true
        answerTitleTextView.leadingAnchor.constraint(equalTo: answererButton.leadingAnchor).isActive = true
        answerTitleTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        bottomConstraint = answerTitleTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2)
        bottomConstraint.isActive = true
        
        answererNameLabel.font = UIFont.sfps(size: 14)
        answererNameLabel.textColor = UIColor.nonBodyTextColor
        answerTimeLabel.font = UIFont.pfr(size: 12)
        answerTimeLabel.textColor = UIColor.nonBodyTextColor
        
        likeCountLabel.font = UIFont.sfps(size: 14)
        likeCountLabel.textColor = UIColor.nonBodyTextColor
        commentCountLabel.font = UIFont.sfps(size: 14)
        commentCountLabel.textColor = UIColor.nonBodyTextColor
        
        likeButton.setImage(#imageLiteral(resourceName: "like_btn"), for: .normal)
        commentButton.setImage(#imageLiteral(resourceName: "cmt_btn"), for: .normal)
        
        answerTitleTextView.textAlignment = .left
        answerTitleTextView.isEditable = false
        answerTitleTextView.isScrollEnabled = false
        
        answererButton.layer.cornerRadius = 15
        answererButton.layer.masksToBounds = true
        answererButton.layer.borderColor = UIColor.clear.cgColor
        answererButton.layer.borderWidth = 0
        
        trashButton.setImage(#imageLiteral(resourceName: "trash"), for: .normal)
        
        audioToggle = JTMaterialSwitch(size: JTMaterialSwitchSizeSmall, state: JTMaterialSwitchStateOff)!
        audioToggle.thumbOnTintColor = UIColor.white
        audioToggle.thumbOffTintColor = UIColor.white
        audioToggle.trackOnTintColor = UIColor.brandColor
        audioToggle.trackOffTintColor = UIColor.tftCoolGrey
        audioToggle.rippleFillColor = UIColor.brandColor
        audioToggle.font = UIFont.pfm(size: 8)
        audioToggle.onText = "美"
        audioToggle.offText = "美"
        audioToggle.onTextColor = UIColor.brandColor
        audioToggle.offTextColor = UIColor.tftCoolGrey
        audioToggle.center = CGPoint(x: 180, y: 32)
        contentView.addSubview(audioToggle)
        
        contentView.backgroundColor = UIColor.white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateUI() {
        answererNameLabel.text = answer.user.username
        answerTimeLabel.text = TimeManager.shared.elapsedDateString(fromString: answer.updatedAt)
        likeCountLabel.text = "\(answer.likes.count)"
        commentCountLabel.text = "\(answer.comments.count)"
        
        // avator
        let avator = UIImage(named: "TFTicons_avator_\(answer.user.id % 8)")
        answererButton.image = avator
    
        let note = answer.noteTitle == nil ? "" : answer.noteTitle!
        switch mode! {
        case .full:
            answerTitleTextView.attributedText = AttrString.answerAttrString(answer.title + "\n***\n" + note)
            
        case .short:
            answerTitleTextView.isSelectable = false
            answerTitleTextView.isUserInteractionEnabled = false
            // substring answer to 50 words
            let components = answer.title.components(separatedBy: " ")
            if components.count < 50 {
                answerTitleTextView.attributedText = AttrString.answerAttrString(answer.title)
            } else {
                answerTitleTextView.attributedText = AttrString.answerAttrString(components[0...50].joined(separator: " ") + " ...")
            }
        }
        
        if isLikedCard {
            bottomConstraint.constant = -2
            // force canAudioToggle false
            canAudioToggle = false
        }
        
        if canBeDeleted {
            trashButton.isHidden = false
        } else {
            trashButton.isHidden = true
        }
        
        if canAudioToggle {
            audioToggle.isHidden = false
        } else {
            audioToggle.isHidden = true
        }
    }
}
