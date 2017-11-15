//
//  AudioRecordViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 11/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class AudioRecordViewController: UIViewController {

    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var audioRecordView: AudioRecordView!
    
    // vars
    var answer: Answer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // config
        mainTitleLabel.font = UIFont.pfr(size: 20)
        mainTitleLabel.textColor = UIColor.tftCoolGrey
        mainTitleLabel.textAlignment = .center
        mainTitleLabel.text = "录音"
        
        textView.attributedText = AttrString.answerAttrString(answer.title)
        textView.isEditable = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        audioRecordView.animate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
