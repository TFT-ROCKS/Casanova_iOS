//
//  AudioCommentPostView.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 12/10/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

protocol AudioCommentPostViewDelegate: class {
    func reloadTableView()
    func reset()
}

class AudioCommentPostView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var audioPlayerView: AudioPlayView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var answer: Answer!
    weak var delegate: AudioCommentPostViewDelegate!
    var audioUrl: String!
    var audioFile: URL! {
        didSet {
            audioPlayerView.audioFile = audioFile
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
        Bundle.main.loadNibNamed("AudioCommentPostView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        textView.backgroundColor = UIColor.cmtBgdColor
        textView.font = UIFont.pfr(size: 16)
        textView.textColor = UIColor.nonBodyTextColor
        textView.delegate = self
        
        placeholderLabel.text = "说点什么..."
        placeholderLabel.textColor = UIColor.tftCoolGrey
        placeholderLabel.font = UIFont.pfl(size: 16)
        
        cancelButton.layer.borderColor = UIColor.brandColor.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 3
        cancelButton.layer.masksToBounds = true
        cancelButton.setAttributedTitle(AttrString.titleAttrString("重录一遍", textColor: UIColor.brandColor), for: .normal)
        
        postButton.layer.backgroundColor = UIColor.brandColor.cgColor
        postButton.layer.cornerRadius = 3
        postButton.layer.masksToBounds = true
        postButton.setAttributedTitle(AttrString.titleAttrString("发布", textColor: UIColor.white), for: .normal)
    }
    
    @IBAction func postButtonClicked(_ sender: UIButton) {
        // check comment text
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            textView.text = ""
            placeholderLabel.isHidden = false
            placeholderLabel.text = "你啥也没说呢"
            return
        }
        // post comment
        postButton.isEnabled = false
        postButton.setAttributedTitle(AttrString.titleAttrString("发布中", textColor: UIColor.white), for: .normal)
        if let audioUrl = audioUrl {
            // comment with audio url
//            CommentAPIService.shared.postComment(answerId: answer.id, userId: Environment.shared.currentUser?.id, title: textView.text, audioUrl: audioUrl, withCompletion: { (error, comment) in
//                if error == nil {
//                    self.answer.comments.insert(comment!, at: 0)
//                    self.success()
//                }
//                self.whatever()
//            })
        }
    }
    
    func success() {
        delegate.reloadTableView()
        doSomethingAndDisappear()
    }
    
    func doSomethingAndDisappear() {
        textView.text = ""
        placeholderLabel.text = "说点什么..."
        placeholderLabel.isHidden = false
        textView.resignFirstResponder()
        fadeOut(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration)
    }
    
    func whatever() {
        postButton.setAttributedTitle(AttrString.titleAttrString("发布", textColor: UIColor.white), for: .normal)
        postButton.isEnabled = true
    }

    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        doSomethingAndDisappear()
        delegate.reset()
    }
    
}

extension AudioCommentPostView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
    }
}
