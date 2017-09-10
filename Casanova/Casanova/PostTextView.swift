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
            placeholderLabel.text = "Say something before post"
            return
        }
        // post comment
        CommentManager.shared.postComment(answerId: answer.id, userId: Environment.shared.currentUser?.id, title: textView.text, withCompletion: { (error, comment) in
            if error == nil {
                // success
                self.answer.comments.insert(comment!, at: 0)
                self.delegate.reloadTableView()
                
                // remove text
                self.textView.text = ""
                self.placeholderLabel.text = "Comment this answer"
                self.placeholderLabel.isHidden = false
                self.textView.resignFirstResponder()
                self.fadeOut(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration)
            }
            self.postButton.isEnabled = true
        })
    }
    @IBOutlet weak var placeholderLabel: UILabel!
    
    weak var answer: Answer!
    weak var delegate: PostTextViewDelegate!
    
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
        
        textView.backgroundColor = UIColor(white: 245 / 255.0, alpha: 1)
        textView.font = UIFont.mr(size: 16)
        textView.textColor = UIColor.nonBodyTextColor
        textView.delegate = self
        
        placeholderLabel.text = "Comment this answer"
        placeholderLabel.textColor = UIColor.tftCoolGrey
        placeholderLabel.font = UIFont.mr(size: 16)
        
        postButton.layer.borderColor = UIColor.brandColor.cgColor
        postButton.layer.borderWidth = 1
        postButton.layer.cornerRadius = 3
        postButton.layer.masksToBounds = true
        postButton.setAttributedTitle(AttrString.titleAttrString("POST", textColor: UIColor.brandColor), for: .normal)
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
