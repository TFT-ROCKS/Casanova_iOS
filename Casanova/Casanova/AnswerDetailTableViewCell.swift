//
//  AnswerDetailTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/31/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import AVFoundation
import SVGKit

enum AnswerMode {
    case short
    case full
}

class AnswerDetailTableViewCell: UITableViewCell, AVAudioPlayerDelegate {
    
    var answererButton: SVGKImageView!
    var answererNameLabel: UILabel!
    var answerTimeLabel: UILabel!
    var likeButton: UIButton!
    var likeCountLabel: UILabel!
    var commentButton: UIButton!
    var commentCountLabel: UILabel!
    var audioButton: UIButton?
    var answerTitleLabel: UILabel!
    
    var mode: AnswerMode!
    var isLikedCard: Bool = false
    
    var answer: Answer! {
        didSet {
            updateUI()
        }
    }
    
    var bottomConstraint: NSLayoutConstraint!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        answererButton = SVGKFastImageView(frame: .zero)
        answererNameLabel = UILabel(frame: .zero)
        answerTimeLabel = UILabel(frame: .zero)
        likeCountLabel = UILabel(frame: .zero)
        likeButton = UIButton(frame: .zero)
        commentCountLabel = UILabel(frame: .zero)
        commentButton = UIButton(frame: .zero)
        answerTitleLabel = UILabel(frame: .zero)
        
        contentView.addSubview(answererButton)
        contentView.addSubview(answererNameLabel)
        contentView.addSubview(answerTimeLabel)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(commentCountLabel)
        contentView.addSubview(commentButton)
        contentView.addSubview(answerTitleLabel)
        
        answererButton.translatesAutoresizingMaskIntoConstraints = false
        answererNameLabel.translatesAutoresizingMaskIntoConstraints = false
        answerTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        commentCountLabel.translatesAutoresizingMaskIntoConstraints = false
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        answerTitleLabel?.translatesAutoresizingMaskIntoConstraints = false
        
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
        likeCountLabel.widthAnchor.constraint(equalToConstant: 24).isActive = true
        likeCountLabel.heightAnchor.constraint(equalToConstant: 19).isActive = true
//        likeCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        likeCountLabel.centerYAnchor.constraint(equalTo: answererButton.centerYAnchor).isActive = true
        
        // likeButton constraints
        likeButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        likeButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        likeButton.trailingAnchor.constraint(equalTo: likeCountLabel.leadingAnchor, constant: -8).isActive = true
        likeButton.centerYAnchor.constraint(equalTo: answererButton.centerYAnchor).isActive = true
        
        // commentCount constraints
        commentCountLabel.widthAnchor.constraint(equalToConstant: 24).isActive = true
        commentCountLabel.heightAnchor.constraint(equalToConstant: 19).isActive = true
        commentCountLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -8).isActive = true
        commentCountLabel.centerYAnchor.constraint(equalTo: answererButton.centerYAnchor).isActive = true
        
        // commentButton constraints
        commentButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        commentButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        commentButton.trailingAnchor.constraint(equalTo: commentCountLabel.leadingAnchor, constant: -8).isActive = true
        commentButton.centerYAnchor.constraint(equalTo: answererButton.centerYAnchor).isActive = true
        
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
        
        answerTitleLabel.topAnchor.constraint(equalTo: answererButton.bottomAnchor, constant: 20).isActive = true
        answerTitleLabel.leadingAnchor.constraint(equalTo: answererButton.leadingAnchor).isActive = true
        answerTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        bottomConstraint = answerTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -29)
        bottomConstraint.isActive = true
        
        answererNameLabel.font = UIFont.mr(size: 14)
        answererNameLabel.textColor = UIColor.nonBodyTextColor
        answerTimeLabel.font = UIFont.pfr(size: 12)
        answerTimeLabel.textColor = UIColor.nonBodyTextColor
        
        likeCountLabel.font = UIFont.mr(size: 14)
        likeCountLabel.textColor = UIColor.nonBodyTextColor
        commentCountLabel.font = UIFont.mr(size: 14)
        commentCountLabel.textColor = UIColor.nonBodyTextColor
        
        likeButton.setImage(#imageLiteral(resourceName: "like_btn"), for: .normal)
        commentButton.setImage(#imageLiteral(resourceName: "cmt_btn"), for: .normal)
        
        answerTitleLabel.numberOfLines = 0
        answerTitleLabel.textAlignment = .left
        
        answererButton.layer.cornerRadius = 15
        answererButton.layer.masksToBounds = true
        answererButton.layer.borderColor = UIColor.clear.cgColor
        answererButton.layer.borderWidth = 0
        
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
        let avator = SVGKImage(named: "TFTicons_avator_\(answer.user.id % 8)")
        answererButton.image = avator
    
        switch mode! {
        case .full:
            answerTitleLabel.attributedText = AttrString.answerAttrString(answer.title)
        case .short:
            // substring answer to 50 words
            let components = answer.title.components(separatedBy: " ")
            if components.count < 50 {
                answerTitleLabel.attributedText = AttrString.answerAttrString(answer.title)
            } else {
                answerTitleLabel.attributedText = AttrString.answerAttrString(components[0...50].joined(separator: " ") + " ...")
            }
        }
        
        if isLikedCard {
            bottomConstraint.constant = -10
        }
    }
}

extension AnswerDetailTableViewCell: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
    }
}
