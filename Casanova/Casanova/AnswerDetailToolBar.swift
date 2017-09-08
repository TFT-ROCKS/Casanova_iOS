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
    func likeButtonClickedOnToolBar()
    func commentButtonClickedOnToolBar()
}

class AnswerDetailToolBar: UIView {
    
    weak var delegate: AnswerDetailToolBarDelegate!

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var questionButton: UIButton!
    @IBAction func questionButtonClicked(_ sender: UIButton) {
        delegate.questionButtonClickedOnToolBar()
    }
    @IBOutlet weak var likeButton: UIButton!
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        delegate.likeButtonClickedOnToolBar()
    }
    @IBOutlet weak var commentButton: UIButton!
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
        
    }

}
