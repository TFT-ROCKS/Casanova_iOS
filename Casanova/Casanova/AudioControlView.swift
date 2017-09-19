//
//  AudioControlView.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 9/7/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
 

protocol AudioControlViewDelegate: class {
    func audioButtonTappedOnBar()
}

class AudioControlView: UIView, UIWebViewDelegate {
    
    weak var delegate: AudioControlViewDelegate!
    var cellInUse: Int = -1
    var isPlaying: Bool = false

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var audioBar: UISlider!
    @IBOutlet weak var audioButton: UIButton!
    @IBAction func audioButtonTapped(_ sender: UIButton) {
        delegate.audioButtonTappedOnBar()
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
        Bundle.main.loadNibNamed("AudioControlView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        profileView.layer.cornerRadius = profileView.bounds.width / 2
        profileView.layer.masksToBounds = true
        profileView.layer.borderColor = UIColor.clear.cgColor
        profileView.layer.borderWidth = 0
        
        usernameLabel.font = UIFont.pfl(size: 14)
        usernameLabel.textColor = UIColor.nonBodyTextColor
        playTimeLabel.font = UIFont.mr(size: 12)
        playTimeLabel.textColor = UIColor.tftCoolGrey
    }
    
    func updateUI(withTag tag: Int, answer: Answer) {
        if cellInUse != tag {
            cellInUse = tag
            // Update UI
            
            // avator
            let avator = UIImage(named: "TFTicons_avator_\(answer.user.id % 8)")
            profileView.image = avator
            
            usernameLabel.text = answer.user.username
            
            isPlaying = true
            audioButton.setImage(#imageLiteral(resourceName: "pause_btn-h"), for: .normal)
        }
    }

}
