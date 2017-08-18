//
//  CommentTableViewCell.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/17/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import AVFoundation

class CommentTableViewCell: UITableViewCell {
    
    var commenterButton: UIWebView!
    var commenterNameLabel: UILabel!
    var commentTimeLabel: UILabel!
//    var likeButton: UIButton!
//    var likeCountLabel: UILabel!
//    var audioTimeLabel: UILabel?
//    var audioSlider: UISlider?
//    var audioButton: UIButton?
    var commentTitleLabel: UILabel!
    
    var comment: Comment! {
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
        
        commenterButton = UIWebView(frame: .zero)
        commenterNameLabel = UILabel(frame: .zero)
        commentTimeLabel = UILabel(frame: .zero)
//        likeCountLabel = UILabel(frame: .zero)
//        likeButton = UIButton(frame: .zero)
        commentTitleLabel = UILabel(frame: .zero)
        
        contentView.addSubview(commenterButton)
        contentView.addSubview(commenterNameLabel)
        contentView.addSubview(commentTimeLabel)
//        contentView.addSubview(likeCountLabel)
//        contentView.addSubview(likeButton)
        contentView.addSubview(commentTitleLabel)
        
        commenterButton.translatesAutoresizingMaskIntoConstraints = false
        commenterNameLabel.translatesAutoresizingMaskIntoConstraints = false
        commentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
//        likeCountLabel.translatesAutoresizingMaskIntoConstraints = false
//        likeButton.translatesAutoresizingMaskIntoConstraints = false
        commentTitleLabel?.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - Constraints
        
        // commenterButton constraints
        commenterButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        commenterButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        commenterButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 17).isActive = true
        commenterButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24).isActive = true
        
        // commenterNameLabel constraints
        commenterNameLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        commenterNameLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        commenterNameLabel.leadingAnchor.constraint(equalTo: commenterButton.trailingAnchor, constant: 20).isActive = true
        commenterNameLabel.topAnchor.constraint(equalTo: commenterButton.topAnchor).isActive = true
        
        // commentTimeLabel constraints
        commentTimeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        commentTimeLabel.heightAnchor.constraint(equalToConstant: 19).isActive = true
        commentTimeLabel.leadingAnchor.constraint(equalTo: commenterNameLabel.leadingAnchor).isActive = true
        commentTimeLabel.topAnchor.constraint(equalTo: commenterNameLabel.bottomAnchor, constant: 5).isActive = true
        
//        // likeCountLabel constraints
//        likeCountLabel.widthAnchor.constraint(equalToConstant: 24).isActive = true
//        likeCountLabel.heightAnchor.constraint(equalToConstant: 19).isActive = true
//        likeCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
//        likeCountLabel.centerYAnchor.constraint(equalTo: commenterButton.centerYAnchor).isActive = true
//        
//        // likeButton constraints
//        likeButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
//        likeButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
//        likeButton.trailingAnchor.constraint(equalTo: likeCountLabel.leadingAnchor, constant: -8).isActive = true
//        likeButton.centerYAnchor.constraint(equalTo: commenterButton.centerYAnchor).isActive = true
        
//        audioTimeLabel = UILabel(frame: .zero)
//        audioButton = UIButton(frame: .zero)
//        audioSlider = UISlider(frame: .zero)
        
//        contentView.addSubview(audioSlider!)
//        contentView.addSubview(audioButton!)
//        contentView.addSubview(audioTimeLabel!)
        
//        audioTimeLabel!.translatesAutoresizingMaskIntoConstraints = false
//        audioButton!.translatesAutoresizingMaskIntoConstraints = false
//        audioSlider!.translatesAutoresizingMaskIntoConstraints = false
        
        // commentTitleLabel top constraint
        commentTitleLabel.topAnchor.constraint(equalTo: commenterButton.bottomAnchor, constant: 20).isActive = true
        commentTitleLabel.leadingAnchor.constraint(equalTo: commenterButton.leadingAnchor).isActive = true
        commentTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24).isActive = true
        commentTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -29).isActive = true
        
//        // audioTimeLabel constraints
//        audioTimeLabel!.widthAnchor.constraint(equalToConstant: 34).isActive = true
//        audioTimeLabel!.heightAnchor.constraint(equalToConstant: 14).isActive = true
//        audioTimeLabel!.topAnchor.constraint(equalTo: commenterButton.bottomAnchor, constant: 20).isActive = true
//        audioTimeLabel!.leadingAnchor.constraint(equalTo: commenterButton.leadingAnchor).isActive = true
//        
//        // audioButton constraints
//        audioButton!.widthAnchor.constraint(equalToConstant: 24).isActive = true
//        audioButton!.heightAnchor.constraint(equalToConstant: 24).isActive = true
//        audioButton!.centerYAnchor.constraint(equalTo: audioTimeLabel!.centerYAnchor).isActive = true
//        audioButton!.trailingAnchor.constraint(equalTo: commentTitleLabel.trailingAnchor).isActive = true
//        
//        // audioSlider constraints
//        audioSlider!.heightAnchor.constraint(equalToConstant: 20).isActive = true
//        audioSlider!.leadingAnchor.constraint(equalTo: audioTimeLabel!.trailingAnchor, constant: 12).isActive = true
//        audioSlider!.trailingAnchor.constraint(equalTo: audioButton!.leadingAnchor, constant: -16).isActive = true
//        audioSlider!.centerYAnchor.constraint(equalTo: audioTimeLabel!.centerYAnchor).isActive = true
        
        // config
//        audioButton!.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
//        audioTimeLabel!.font = Fonts.AnswerDetailVC.Labels.audioTimeLabelFont()
//        audioTimeLabel!.textColor = Colors.AnswerDetailVC.Labels.audioTimeLabelTextColor()
        
        commenterNameLabel.font = Fonts.AnswerDetailVC.Labels.commenterNameLabelFont()
        commenterNameLabel.textColor = Colors.AnswerDetailVC.Labels.commenterNameLabelTextColor()
        commentTimeLabel.font = Fonts.AnswerDetailVC.Labels.commentTimeLabelFont()
        commentTimeLabel.textColor = Colors.AnswerDetailVC.Labels.commentTimeLabelTextColor()
        
//        likeCountLabel.font = Fonts.AnswerDetailVC.Labels.likeCountLabelFont()
//        likeCountLabel.textColor = Colors.AnswerDetailVC.Labels.likeCountLabelTextColor()
        
//        likeButton.setImage(#imageLiteral(resourceName: "like_btn"), for: .normal)
        
        commentTitleLabel.numberOfLines = 0
        commentTitleLabel.textAlignment = .left
        commentTitleLabel.font = UIFont(name: "Montserrat-Light", size: 16.0)!
        commentTitleLabel.textColor = UIColor(red: 74 / 255.0, green: 74 / 255.0, blue: 74 / 255.0, alpha: 1)
        
        commenterButton.layer.cornerRadius = 15
        commenterButton.layer.masksToBounds = true
        commenterButton.layer.borderColor = UIColor.clear.cgColor
        commenterButton.layer.borderWidth = 0
        commenterButton.scrollView.isScrollEnabled = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func updateUI() {
        commenterNameLabel.text = comment.user.username
        commentTimeLabel.text = TimeManager.shared.elapsedDateString(fromString: comment.createdAt)
//        likeCountLabel.text = "\(comment.likes.count)"
        
        // load image into webView
        let path: String = Bundle.main.path(forResource: "TFTicons_avatar_\(comment.user.id % 8)", ofType: "svg")!
        let url: URL = URL(fileURLWithPath: path)  //Creating a URL which points towards our path
        // Creating a page request which will load our URL (Which points to our path)
        let request: URLRequest = URLRequest(url: url)
        commenterButton.delegate = self
        commenterButton.loadRequest(request)  // Telling our webView to load our above request
        commentTitleLabel.text = comment.title
        
    }
}

extension CommentTableViewCell: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
    }
}
