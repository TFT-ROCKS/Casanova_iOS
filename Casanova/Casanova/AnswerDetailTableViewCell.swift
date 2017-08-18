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
    
    var answererButton: UIWebView!
    var answererNameLabel: UILabel!
    var answerTimeLabel: UILabel!
    var likeButton: UIButton!
    var likeCountLabel: UILabel!
    var commentButton: UIButton!
    var commentCountLabel: UILabel!
    var audioTimeLabel: UILabel?
    var audioSlider: UISlider?
    var audioButton: UIButton?
    var answerTitleLabel: UILabel!
    
    var mode: AnswerMode!
    
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
        
        answererButton = UIWebView(frame: .zero)
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
        likeCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
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
            audioTimeLabel = UILabel(frame: .zero)
            audioButton = UIButton(frame: .zero)
            audioSlider = UISlider(frame: .zero)
            
            contentView.addSubview(audioSlider!)
            contentView.addSubview(audioButton!)
            contentView.addSubview(audioTimeLabel!)
            
            audioTimeLabel!.translatesAutoresizingMaskIntoConstraints = false
            audioButton!.translatesAutoresizingMaskIntoConstraints = false
            audioSlider!.translatesAutoresizingMaskIntoConstraints = false
            
            // audioTimeLabel constraints
            audioTimeLabel!.widthAnchor.constraint(equalToConstant: 34).isActive = true
            audioTimeLabel!.heightAnchor.constraint(equalToConstant: 14).isActive = true
            audioTimeLabel!.topAnchor.constraint(equalTo: answererButton.bottomAnchor, constant: 20).isActive = true
            audioTimeLabel!.leadingAnchor.constraint(equalTo: answererButton.leadingAnchor).isActive = true
            
            // audioButton constraints
            audioButton!.widthAnchor.constraint(equalToConstant: 24).isActive = true
            audioButton!.heightAnchor.constraint(equalToConstant: 24).isActive = true
            audioButton!.centerYAnchor.constraint(equalTo: audioTimeLabel!.centerYAnchor).isActive = true
            audioButton!.trailingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor).isActive = true
            
            // audioSlider constraints
            audioSlider!.heightAnchor.constraint(equalToConstant: 20).isActive = true
            audioSlider!.leadingAnchor.constraint(equalTo: audioTimeLabel!.trailingAnchor, constant: 12).isActive = true
            audioSlider!.trailingAnchor.constraint(equalTo: audioButton!.leadingAnchor, constant: -16).isActive = true
            audioSlider!.centerYAnchor.constraint(equalTo: audioTimeLabel!.centerYAnchor).isActive = true
            
            // answerTitleLabel top constraint
            answerTitleLabel.topAnchor.constraint(equalTo: audioTimeLabel!.bottomAnchor, constant: 30).isActive = true
            
            // config
            audioButton!.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
            audioTimeLabel!.font = Fonts.TopicDetailVC.Labels.audioTimeLabelFont()
            audioTimeLabel!.textColor = Colors.TopicDetailVC.Labels.audioTimeLabelTextColor()
        } else {
            answerTitleLabel.topAnchor.constraint(equalTo: answererButton.bottomAnchor, constant: 20).isActive = true
        }
        
        answerTitleLabel.leadingAnchor.constraint(equalTo: answererButton.leadingAnchor).isActive = true
        answerTitleLabel.trailingAnchor.constraint(equalTo: likeCountLabel.trailingAnchor).isActive = true
        answerTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -29).isActive = true
        
        answererNameLabel.font = Fonts.TopicDetailVC.Labels.answererNameLabelFont()
        answererNameLabel.textColor = Colors.TopicDetailVC.Labels.answererNameLabelTextColor()
        answerTimeLabel.font = Fonts.TopicDetailVC.Labels.answerTimeLabelFont()
        answerTimeLabel.textColor = Colors.TopicDetailVC.Labels.answerTimeLabelTextColor()
        
        likeCountLabel.font = Fonts.TopicDetailVC.Labels.likeCountLabelFont()
        likeCountLabel.textColor = Colors.TopicDetailVC.Labels.likeCountLabelTextColor()
        commentCountLabel.font = Fonts.TopicDetailVC.Labels.likeCountLabelFont()
        commentCountLabel.textColor = Colors.TopicDetailVC.Labels.likeCountLabelTextColor()
        
        likeButton.setImage(#imageLiteral(resourceName: "like_btn"), for: .normal)
        commentButton.setImage(#imageLiteral(resourceName: "cmt_btn"), for: .normal)
        
        answerTitleLabel.numberOfLines = 0
        answerTitleLabel.textAlignment = .left
        answerTitleLabel.font = UIFont(name: "Montserrat-Light", size: 16.0)!
        answerTitleLabel.textColor = UIColor(red: 74 / 255.0, green: 74 / 255.0, blue: 74 / 255.0, alpha: 1)
        
        answererButton.layer.cornerRadius = 15
        answererButton.layer.masksToBounds = true
        answererButton.layer.borderColor = UIColor.clear.cgColor
        answererButton.layer.borderWidth = 0
        answererButton.scrollView.isScrollEnabled = false
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
        
        // load image into webView
        let path: String = Bundle.main.path(forResource: "TFTicons_avatar_\(answer.user.id % 8)", ofType: "svg")!
        let url: URL = URL(fileURLWithPath: path)  //Creating a URL which points towards our path
        // Creating a page request which will load our URL (Which points to our path)
        let request: URLRequest = URLRequest(url: url)
        answererButton.delegate = self
        answererButton.loadRequest(request)  // Telling our webView to load our above request
        
        switch mode! {
        case .full:
            answerTitleLabel.text = answer.title
        case .short:
            // substring answer to 50 words
            let components = answer.title.components(separatedBy: " ")
            if components.count < 50 {
                answerTitleLabel.text = answer.title
            } else {
                answerTitleLabel.text = components[0...50].joined(separator: " ") + " ..."
            }
        }
    }
}

extension AnswerDetailTableViewCell: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
    }
}
