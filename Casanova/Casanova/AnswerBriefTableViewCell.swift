//
//  AnswerDetailTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/31/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class AnswerBriefTableViewCell: UITableViewCell {
    
    // MARK: - Subviews
    var answererButton: UIImageView!
    var answererNameLabel: UILabel!
    var answerTimeLabel: UILabel!
    var clapsLabel: UILabel!
    var commentLabel: UILabel!
    var audioButton: UIButton?
    var answerTitleTextView: UITextView?
    var markImageView: UIImageView!
    var trashButton: UIButton!
    var answerImageView: UIImageView?
    
    // MARK: - View Model
    var viewModel: AnswerBriefTableViewCellViewModel!
    
    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .blue
        
        answererButton = UIImageView(frame: .zero)
        answererNameLabel = UILabel(frame: .zero)
        answerTimeLabel = UILabel(frame: .zero)
        clapsLabel = UILabel(frame: .zero)
        commentLabel = UILabel(frame: .zero)
        markImageView = UIImageView(frame: .zero)
        trashButton = UIButton(frame: .zero)
        
        contentView.addSubview(answererButton)
        contentView.addSubview(answererNameLabel)
        contentView.addSubview(answerTimeLabel)
        contentView.addSubview(clapsLabel)
        contentView.addSubview(commentLabel)
        contentView.addSubview(markImageView)
        contentView.addSubview(trashButton)
        
        answererButton.translatesAutoresizingMaskIntoConstraints = false
        answererNameLabel.translatesAutoresizingMaskIntoConstraints = false
        answerTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        clapsLabel.translatesAutoresizingMaskIntoConstraints = false
        commentLabel.translatesAutoresizingMaskIntoConstraints = false
        markImageView.translatesAutoresizingMaskIntoConstraints = false
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Constraints
        
        // answererButton constraints
        answererButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        answererButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        answererButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
        answererButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24).isActive = true
        
        // answererNameLabel constraints
        answererNameLabel.leadingAnchor.constraint(equalTo: answererButton.trailingAnchor, constant: 10).isActive = true
        answererNameLabel.topAnchor.constraint(equalTo: answererButton.topAnchor).isActive = true
        
        // answerTimeLabel constraints
        answerTimeLabel.leadingAnchor.constraint(equalTo: answererNameLabel.leadingAnchor).isActive = true
        answerTimeLabel.topAnchor.constraint(equalTo: answererNameLabel.bottomAnchor, constant: 5).isActive = true
        
        // markImageView constraints
        markImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        markImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        markImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        markImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        // trashButton constraints
        trashButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        trashButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        trashButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        trashButton.centerYAnchor.constraint(equalTo: answererButton.centerYAnchor).isActive = true
        
        // temp Y axis above claps and comment label
        let tempYAxisAnchor: NSLayoutYAxisAnchor
        let tempYOffSet: CGFloat
        
        if reuseIdentifier! == ReuseIDs.TopicDetailVC.View.answerTextAudioCell {
            // text & audio
            answerTitleTextView = UITextView(frame: .zero)
            audioButton = UIButton(frame: .zero)
            answerImageView = UIImageView(frame: .zero)
            
            contentView.addSubview(answerTitleTextView!)
            contentView.addSubview(answerImageView!)
            contentView.addSubview(audioButton!)
            
            audioButton!.translatesAutoresizingMaskIntoConstraints = false
            answerImageView!.translatesAutoresizingMaskIntoConstraints = false
            answerTitleTextView!.translatesAutoresizingMaskIntoConstraints = false
            
            // answerImageView constraints
            answerImageView!.leadingAnchor.constraint(equalTo: answererButton.leadingAnchor).isActive = true
            answerImageView!.widthAnchor.constraint(equalToConstant: 90).isActive = true
            answerImageView!.heightAnchor.constraint(equalToConstant: 90).isActive = true
            answerImageView!.topAnchor.constraint(equalTo: answerTitleTextView!.topAnchor, constant: 10).isActive = true
            
            // audioButton constraints
            audioButton!.widthAnchor.constraint(equalToConstant: 40).isActive = true
            audioButton!.heightAnchor.constraint(equalToConstant: 40).isActive = true
            audioButton!.centerYAnchor.constraint(equalTo: answerImageView!.centerYAnchor).isActive = true
            audioButton!.centerXAnchor.constraint(equalTo: answerImageView!.centerXAnchor).isActive = true
            
            // answerTitle constraints
            answerTitleTextView!.topAnchor.constraint(equalTo: answererButton.bottomAnchor, constant: 14).isActive = true
            answerTitleTextView!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
            answerTitleTextView!.heightAnchor.constraint(equalToConstant: 120).isActive = true
            answerTitleTextView!.leadingAnchor.constraint(equalTo: answerImageView!.trailingAnchor, constant: 17).isActive = true
            tempYAxisAnchor = answerTitleTextView!.bottomAnchor
            tempYOffSet = 0.0
            
        } else if reuseIdentifier! == ReuseIDs.TopicDetailVC.View.answerOnlyTextCell {
            // only text
            answerTitleTextView = UITextView(frame: .zero)
            
            contentView.addSubview(answerTitleTextView!)
            
            answerTitleTextView!.translatesAutoresizingMaskIntoConstraints = false
            
            // answerTitle constraints
            answerTitleTextView!.topAnchor.constraint(equalTo: answererButton.bottomAnchor, constant: 14).isActive = true
            answerTitleTextView!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
            answerTitleTextView!.heightAnchor.constraint(equalToConstant: 120).isActive = true
            answerTitleTextView!.leadingAnchor.constraint(equalTo: answererButton.leadingAnchor).isActive = true
            tempYAxisAnchor = answerTitleTextView!.bottomAnchor
            tempYOffSet = 0.0
            
        } else {
            // only audio
            audioButton = UIButton(frame: .zero)
            answerImageView = UIImageView(frame: .zero)
            
            contentView.addSubview(answerImageView!)
            contentView.addSubview(audioButton!)
            
            audioButton!.translatesAutoresizingMaskIntoConstraints = false
            answerImageView!.translatesAutoresizingMaskIntoConstraints = false
            
            // answerImageView constraints
            answerImageView!.leadingAnchor.constraint(equalTo: answererButton.leadingAnchor).isActive = true
            answerImageView!.heightAnchor.constraint(equalToConstant: 90).isActive = true
            answerImageView!.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
            answerImageView!.topAnchor.constraint(equalTo: answererButton.bottomAnchor, constant: 14).isActive = true
            tempYAxisAnchor = answerImageView!.bottomAnchor
            tempYOffSet = 10.0
            
            // audioButton constraints
            audioButton!.widthAnchor.constraint(equalToConstant: 40).isActive = true
            audioButton!.heightAnchor.constraint(equalToConstant: 40).isActive = true
            audioButton!.centerYAnchor.constraint(equalTo: answerImageView!.centerYAnchor).isActive = true
            audioButton!.centerXAnchor.constraint(equalTo: answerImageView!.centerXAnchor).isActive = true
        }
        
        // claps label constraints
        clapsLabel.leadingAnchor.constraint(equalTo: answererButton.leadingAnchor).isActive = true
        clapsLabel.topAnchor.constraint(equalTo: tempYAxisAnchor, constant: tempYOffSet).isActive = true
        clapsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12).isActive = true
        
        // comments label constraints
        commentLabel.leadingAnchor.constraint(equalTo: clapsLabel.trailingAnchor, constant: 10).isActive = true
        commentLabel.topAnchor.constraint(equalTo: clapsLabel.topAnchor).isActive = true
        
        // MARK: - Setup
        
        answererNameLabel.font = UIFont.sfpb(size: 12)
        answererNameLabel.textColor = UIColor.nonBodyTextColor
        answerTimeLabel.font = UIFont.sfpr(size: 10)
        answerTimeLabel.textColor = UIColor.nonBodyTextColor
        
        clapsLabel.font = UIFont.sfpr(size: 12)
        clapsLabel.textColor = UIColor.nonBodyTextColor
        commentLabel.font = UIFont.sfpr(size: 12)
        commentLabel.textColor = UIColor.nonBodyTextColor
        
        answererButton.layer.cornerRadius = 15
        answererButton.layer.masksToBounds = true
        answererButton.layer.borderColor = UIColor.clear.cgColor
        answererButton.layer.borderWidth = 0
        
        markImageView.image = #imageLiteral(resourceName: "answer_corner_tag")
        markImageView.contentMode = .scaleAspectFill
        trashButton.setImage(#imageLiteral(resourceName: "trash"), for: .normal)
        
        audioButton?.setBackgroundImage(#imageLiteral(resourceName: "play_btn"), for: .normal)
        audioButton?.isUserInteractionEnabled = false
        
        answerTitleTextView?.textAlignment = .left
        answerTitleTextView?.isEditable = false
        answerTitleTextView?.isScrollEnabled = false
        answerTitleTextView?.isSelectable = false
        answerTitleTextView?.isUserInteractionEnabled = false
        answerTitleTextView?.textContainer.lineFragmentPadding = 0 // left padding
        answerTitleTextView?.textContainerInset = .zero // top, left, bottom, right
        
        contentView.backgroundColor = UIColor.white
        contentView.layer.shadowColor = UIColor.shadowColor.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.layer.shadowOpacity = 1
        
        answerImageView?.contentMode = .scaleAspectFill
        answerImageView?.clipsToBounds = true
    }
    
    // MARK: - Bind
    
    func bind(viewModel: AnswerBriefTableViewCellViewModel) {
        guard viewModel.allowedAccess(self) else { return }
        
        self.viewModel = viewModel
        
        updateUI(with: viewModel)
        
        // bind
        viewModel.didUpdate = self.updateUI
        
        // actions
        viewModel.loadAnswerImage()
        trashButton.addTarget(self, action: #selector(trashButtonTapped(_:)), for: .touchUpInside)
    }

    func updateUI(with viewModel: AnswerBriefTableViewCellViewModel) {
        answererNameLabel.text = viewModel.answererNameText
        answerTimeLabel.text = viewModel.answerTimeText
        answererButton.image = viewModel.avator
        answerTitleTextView?.attributedText = viewModel.answerTitleText
        markImageView.isHidden = viewModel.markImageViewHidden
        trashButton.isHidden = viewModel.trashButtonHidden
        clapsLabel.text = viewModel.clapsText
        commentLabel.text = viewModel.commentsText
        answerImageView?.image = viewModel.answerImage
    }
    
    // MARK: - Actions
    
    func trashButtonTapped(_ sender: UIButton) {
        self.viewModel.deleteAnswer()
    }
}
