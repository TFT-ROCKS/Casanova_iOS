//
//  AnswerDetailTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/31/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class AnswerDetailTableViewCell: UITableViewCell {
    
    var answererButton: UIButton!
    var answererNameLabel: UILabel!
    var answerTimeLabel: UILabel!
    var likeButton: UIButton!
    var likeCountLabel: UILabel!
    var audioTimeLabel: UILabel!
    var audioSlider: UISlider!
    var audioButton: UIButton!
    var answerTitleLabel: UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        answererButton = UIButton(frame: .zero)
        answererNameLabel = UILabel(frame: .zero)
        answerTimeLabel = UILabel(frame: .zero)
        likeCountLabel = UILabel(frame: .zero)
        likeButton = UIButton(frame: .zero)
        audioTimeLabel = UILabel(frame: .zero)
        audioButton = UIButton(frame: .zero)
        audioSlider = UISlider(frame: .zero)
        
        contentView.addSubview(answererButton)
        contentView.addSubview(answererNameLabel)
        contentView.addSubview(answerTimeLabel)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(audioSlider)
        contentView.addSubview(audioButton)
        contentView.addSubview(audioTimeLabel)
        
        answererButton.translatesAutoresizingMaskIntoConstraints = false
        answererNameLabel.translatesAutoresizingMaskIntoConstraints = false
        answerTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        audioTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        audioButton.translatesAutoresizingMaskIntoConstraints = false
        audioSlider.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Constraints
        let margins = contentView.layoutMarginsGuide
        // answererButton constraints
        answererButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        answererButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        answererButton.topAnchor.constraint(equalTo: margins.topAnchor, constant: 12).isActive = true
        answererButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 12).isActive = true
        
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
        likeCountLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -12).isActive = true
        likeCountLabel.centerYAnchor.constraint(equalTo: answererButton.centerYAnchor).isActive = true
        
        // likeButton constraints
        likeButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        likeButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        likeButton.trailingAnchor.constraint(equalTo: likeCountLabel.leadingAnchor, constant: -5).isActive = true
        likeButton.centerYAnchor.constraint(equalTo: answererButton.centerYAnchor).isActive = true
        
        // audioTimeLabel constraints
        audioTimeLabel.widthAnchor.constraint(equalToConstant: 34).isActive = true
        audioTimeLabel.heightAnchor.constraint(equalToConstant: 14).isActive = true
        audioTimeLabel.topAnchor.constraint(equalTo: answerTimeLabel.bottomAnchor, constant: 8).isActive = true
        audioTimeLabel.leadingAnchor.constraint(equalTo: answererButton.leadingAnchor).isActive = true
        
        // audioButton constraints
        audioButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        audioButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        audioButton.centerYAnchor.constraint(equalTo: audioTimeLabel.centerYAnchor).isActive = true
        audioButton.trailingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor).isActive = true
        
        // audioSlider constraints
        audioSlider.heightAnchor.constraint(equalToConstant: 20).isActive = true
        audioSlider.leadingAnchor.constraint(equalTo: audioTimeLabel.trailingAnchor, constant: 12).isActive = true
        audioSlider.trailingAnchor.constraint(equalTo: audioButton.leadingAnchor, constant: -16).isActive = true
        audioSlider.centerYAnchor.constraint(equalTo: audioTimeLabel.centerYAnchor).isActive = true
        
        
        switch reuseIdentifier! {
        case "AnswerWithTextCell":
            answerTitleLabel = UILabel(frame: .zero)
            contentView.addSubview(answerTitleLabel!)
            answerTitleLabel?.translatesAutoresizingMaskIntoConstraints = false
            answerTitleLabel?.topAnchor.constraint(equalTo: audioButton.bottomAnchor, constant: 30).isActive = true
            answerTitleLabel?.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 24).isActive = true
            answerTitleLabel?.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -24).isActive = true
            answerTitleLabel?.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -24).isActive = true
            
        case "AnswerWithoutTextCell":
            audioButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -50).isActive = true
            
        default:
            break
        }

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
