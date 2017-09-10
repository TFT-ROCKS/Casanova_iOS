//
//  AnswerDetailToolBar.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 9/7/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

protocol AnswerDetailToolBarDelegate: class {
    func questionButtonClickedOnToolBar()
    func likeButtonClickedOnToolBar(_ sender: UIButton)
    func commentButtonClickedOnToolBar()
}

class AnswerDetailToolBar: UIView {
    
    weak var delegate: AnswerDetailToolBarDelegate!
    
    var isQuestion: Bool = false {
        didSet {
            if isQuestion {
                questionButton.setImage(#imageLiteral(resourceName: "question_bar_h"), for: .normal)
                questionLabel.textColor = UIColor.brandColor
            } else {
                questionButton.setImage(#imageLiteral(resourceName: "question_bar"), for: .normal)
                questionLabel.textColor = UIColor.tftCoolGrey
            }
        }
    }
    var isLike: Bool = false {
        didSet {
            if isLike {
                likeButton.setImage(#imageLiteral(resourceName: "like_bar_h"), for: .normal)
                likeLabel.textColor = UIColor.brandColor
            } else {
                likeButton.setImage(#imageLiteral(resourceName: "like_bar"), for: .normal)
                likeLabel.textColor = UIColor.tftCoolGrey
            }
        }
    }

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBAction func questionButtonClicked(_ sender: UIButton) {
        isQuestion = !isQuestion
        delegate.questionButtonClickedOnToolBar()
    }
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        isLike = !isLike
        delegate.likeButtonClickedOnToolBar(sender)
    }
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBAction func commentButtonClicked(_ sender: UIButton) {
        delegate.commentButtonClickedOnToolBar()
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
        Bundle.main.loadNibNamed("AnswerDetailToolBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        // text color
        questionLabel.textColor = UIColor.tftCoolGrey
        likeLabel.textColor = UIColor.tftCoolGrey
        commentLabel.textColor = UIColor.tftCoolGrey
        
        // button image mode
        questionButton.imageView?.contentMode = .scaleAspectFit
        likeButton.imageView?.contentMode = .scaleAspectFit
        commentButton.imageView?.contentMode = .scaleAspectFit
    }

}
