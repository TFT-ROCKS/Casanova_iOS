//
//  TopicDetailToolBar.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 9/9/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

protocol TopicDetailToolBarDelegate: class {
    func questionButtonClickedOnToolBar()
    func saveButtonClickedOnToolBar()
    func answerButtonClickedOnToolBar()
}

class TopicDetailToolBar: UIView {
    
    weak var delegate: TopicDetailToolBarDelegate!
    
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
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBAction func questionButtonClicked(_ sender: UIButton) {
        isQuestion = !isQuestion
        delegate.questionButtonClickedOnToolBar()
    }
    @IBOutlet weak var saveButton: UIButton!
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        delegate.saveButtonClickedOnToolBar()
    }
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var answerLabel: UILabel!
    @IBAction func answerButtonClicked(_ sender: UIButton) {
        delegate.answerButtonClickedOnToolBar()
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
        Bundle.main.loadNibNamed("TopicDetailToolBar", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        // text color
        questionLabel.textColor = UIColor.tftCoolGrey
        answerLabel.textColor = UIColor.tftCoolGrey
        
        // button image mode
        questionButton.imageView?.contentMode = .scaleAspectFit
        answerButton.imageView?.contentMode = .scaleAspectFit
    }
    
}
