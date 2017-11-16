//
//  PostTextView.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/20/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

protocol PostTextViewDelegate: class {
    func reloadTableView()
    func toggleButtonTapped(_ sender: UIButton)
}

class PostTextView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBAction func postButtonClicked(_ sender: UIButton) {
        postButton.isEnabled = false
        // check comment text
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            textView.text = ""
            placeholderLabel.isHidden = false
            placeholderLabel.text = "你啥也没说呢"
            return
        }
        // post comment
        postButton.setAttributedTitle(AttrString.titleAttrString("发布中", textColor: UIColor.brandColor), for: .normal)
        if let audioUrl = audioUrl {
            // comment with audio url
            CommentManager.shared.postComment(answerId: answer.id, userId: Environment.shared.currentUser?.id, title: textView.text, audioUrl: audioUrl, withCompletion: { (error, comment) in
                if error == nil {
                    self.answer.comments.insert(comment!, at: 0)
                    self.success()
                }
                self.whatever()
            })
        } else {
            // comment without audio url
            CommentManager.shared.postComment(answerId: answer.id, userId: Environment.shared.currentUser?.id, title: textView.text, withCompletion: { (error, comment) in
                if error == nil {
                    self.answer.comments.insert(comment!, at: 0)
                    self.success()
                }
                self.whatever()
            })
        }
    }
    
    func success() {
        // success
        self.delegate.reloadTableView()
        
        // remove text
        self.textView.text = ""
        self.placeholderLabel.text = "评论这个答案"
        self.placeholderLabel.isHidden = false
        self.textView.resignFirstResponder()
        self.fadeOut(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration)
    }
    
    func whatever() {
        self.postButton.setAttributedTitle(AttrString.titleAttrString("发布", textColor: UIColor.brandColor), for: .normal)
        self.postButton.isEnabled = true
    }
    
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    @IBAction func toggleButtonTapped(_ sender: UIButton) {
        // function
        delegate.toggleButtonTapped(sender)
        // switch image
        isExpanded = !isExpanded
        if isExpanded {
            toggleButton.setImage(#imageLiteral(resourceName: "collapse"), for: .normal)
        } else {
            toggleButton.setImage(#imageLiteral(resourceName: "expand"), for: .normal)
        }
    }
    
    weak var answer: Answer!
    var audioUrl: String?
    weak var delegate: PostTextViewDelegate!
    var isExpanded: Bool = false
    
    override init(frame: CGRect) { // For using custom view in code
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) { // For using custom view in IB
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("PostTextView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        textView.backgroundColor = UIColor.cmtBgdColor
        textView.font = UIFont.pfr(size: 16)
        textView.textColor = UIColor.nonBodyTextColor
        textView.delegate = self
        
        placeholderLabel.text = "评论这个答案"
        placeholderLabel.textColor = UIColor.tftCoolGrey
        placeholderLabel.font = UIFont.pfl(size: 16)
        
        postButton.layer.borderColor = UIColor.brandColor.cgColor
        postButton.layer.borderWidth = 1
        postButton.layer.cornerRadius = 3
        postButton.layer.masksToBounds = true
        postButton.setAttributedTitle(AttrString.titleAttrString("发布", textColor: UIColor.brandColor), for: .normal)
    }
}

extension PostTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
            
        }
    }
}
