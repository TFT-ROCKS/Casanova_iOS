//
//  AnswerDetailTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/31/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class AnswerBriefTableViewCell: UITableViewCell {
    
    var answererButton: UIImageView!
    var answererNameLabel: UILabel!
    var answerTimeLabel: UILabel!
    var clapsLabel: UILabel!
    var commentLabel: UILabel!
    var audioButton: UIButton?
    var answerTitleTextView: UITextView!
    var trashButton: UIButton!
    var answerImageView: UIImageView?
    
    var canBeDeleted: Bool = false
    
    var answer: Answer! {
        didSet {
            updateUI()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        answererButton = UIImageView(frame: .zero)
        answererNameLabel = UILabel(frame: .zero)
        answerTimeLabel = UILabel(frame: .zero)
        answerTitleTextView = UITextView(frame: .zero)
        trashButton = UIButton(frame: .zero)
        
        contentView.addSubview(answererButton)
        contentView.addSubview(answererNameLabel)
        contentView.addSubview(answerTimeLabel)
        contentView.addSubview(answerTitleTextView)
        contentView.addSubview(trashButton)
        
        answererButton.translatesAutoresizingMaskIntoConstraints = false
        answererNameLabel.translatesAutoresizingMaskIntoConstraints = false
        answerTimeLabel.translatesAutoresizingMaskIntoConstraints = false
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
        
        // trashButton constraints
        trashButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        trashButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        trashButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        trashButton.centerYAnchor.constraint(equalTo: answererButton.centerYAnchor).isActive = true
        
        // answerTitle constraints
        answerTitleTextView.topAnchor.constraint(equalTo: answererButton.bottomAnchor, constant: 20).isActive = true
        answerTitleTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        answerTitleTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2).isActive = true
        answerTitleTextView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        if reuseIdentifier! != ReuseIDs.TopicDetailVC.View.answerWithoutAudioCell {
            audioButton = UIButton(frame: .zero)
            answerImageView = UIImageView(frame: .zero)
            
            contentView.addSubview(answerImageView!)
            contentView.addSubview(audioButton!)
            
            audioButton!.translatesAutoresizingMaskIntoConstraints = false
            answerImageView!.translatesAutoresizingMaskIntoConstraints = false
            
            // answerImageView constraints
            answerImageView!.leadingAnchor.constraint(equalTo: answererButton.leadingAnchor).isActive = true
            answerImageView!.widthAnchor.constraint(equalToConstant: 90).isActive = true
            answerImageView!.heightAnchor.constraint(equalToConstant: 90).isActive = true
            answerImageView!.topAnchor.constraint(equalTo: answererButton.bottomAnchor, constant: 20).isActive = true
            // audioButton constraints
            audioButton!.widthAnchor.constraint(equalToConstant: 40).isActive = true
            audioButton!.heightAnchor.constraint(equalToConstant: 40).isActive = true
            audioButton!.centerYAnchor.constraint(equalTo: answerImageView!.centerYAnchor).isActive = true
            audioButton!.centerXAnchor.constraint(equalTo: answerImageView!.centerXAnchor).isActive = true
            // answerTitle constraints
            answerTitleTextView.leadingAnchor.constraint(equalTo: answerImageView!.trailingAnchor, constant: 17).isActive = true
            
            // config
            audioButton!.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
        } else {
            // answerTitle constraints
            answerTitleTextView.leadingAnchor.constraint(equalTo: answererButton.leadingAnchor).isActive = true
        }
        
        answererNameLabel.font = UIFont.mr(size: 14)
        answererNameLabel.textColor = UIColor.nonBodyTextColor
        answerTimeLabel.font = UIFont.pfr(size: 12)
        answerTimeLabel.textColor = UIColor.nonBodyTextColor
        
        clapsLabel.font = UIFont.mr(size: 14)
        clapsLabel.textColor = UIColor.nonBodyTextColor
        commentLabel.font = UIFont.mr(size: 14)
        commentLabel.textColor = UIColor.nonBodyTextColor
        
        answererButton.layer.cornerRadius = 15
        answererButton.layer.masksToBounds = true
        answererButton.layer.borderColor = UIColor.clear.cgColor
        answererButton.layer.borderWidth = 0
        
        trashButton.setImage(#imageLiteral(resourceName: "trash"), for: .normal)
        
        answerTitleTextView.textAlignment = .left
        answerTitleTextView.isEditable = false
        answerTitleTextView.isScrollEnabled = false
        answerTitleTextView.isSelectable = false
        answerTitleTextView.isUserInteractionEnabled = false
        
        contentView.backgroundColor = UIColor.white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func bind(with viewModel: AnswerBriefTableViewCellViewModel) {
        guard viewModel.allowedAccess(self) else { return }
        
        updateUI(with: viewModel)
        
        // bind
        viewModel.didUpdate = self.updateUI
    }

    func updateUI(with viewModel: AnswerBriefTableViewCellViewModel) {
        answererNameLabel.text = viewModel.answererNameText
        answerTimeLabel.text = viewModel.answerTimeText
        answererButton.image = viewModel.avator
        answerTitleTextView.attributedText = viewModel.answerTitleText
        
        if canBeDeleted {
            trashButton.isHidden = false
        } else {
            trashButton.isHidden = true
        }
    }
}
