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
    func slowDownButtonTappedOnBar()
    func speedUpButtonTappedOnBar()
}

class AudioControlView: UIView, UIWebViewDelegate {
    
    weak var delegate: AudioControlViewDelegate!
    var cellInUse: Int = -1
    var indexPathInUse: IndexPath!
    var isPlaying: Bool = false

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var audioBar: UISlider!
    @IBOutlet weak var slowDownButton: UIButton!
    @IBOutlet weak var audioButton: UIButton!
    @IBOutlet weak var speedUpButton: UIButton!
    @IBAction func slowDownButtonTapped(_ sender: UIButton) {
        delegate.slowDownButtonTappedOnBar()
    }
    @IBAction func audioButtonTapped(_ sender: UIButton) {
        delegate.audioButtonTappedOnBar()
    }
    @IBAction func speedUpButtonTapped(_ sender: UIButton) {
        delegate.speedUpButtonTappedOnBar()
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
        playTimeLabel.font = UIFont.sfps(size: 12)
        playTimeLabel.textColor = UIColor.tftCoolGrey
        speedLabel.font = UIFont.pfl(size: 12)
        speedLabel.textColor = UIColor.nonBodyTextColor
        
        slowDownButton.setImage(#imageLiteral(resourceName: "icon-slow-down"), for: .normal)
        speedUpButton.setImage(#imageLiteral(resourceName: "icon-speed-up"), for: .normal)
        updateSpeedLabel(withSpeed: 1.0)
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

    func updateUI(withIndexPath indexPath: IndexPath?, answer: Answer, comment: Comment?) {
        if indexPathInUse != indexPath {
            indexPathInUse = indexPath
            // Update UI
            
            // avator
            let user = comment == nil ? answer.user : comment!.user
            let avator = UIImage(named: "TFTicons_avator_\(user.id % 8)")
            profileView.image = avator
            
            usernameLabel.text = user.username
            
            isPlaying = true
            audioButton.setImage(#imageLiteral(resourceName: "pause_btn-h"), for: .normal)
        }
    }
    
    func reset() {
        indexPathInUse = IndexPath(row: -100, section: -100)
    }
    
    func updateSpeedLabel(withSpeed speed: Float) {
        speedLabel.text = String(format: "%.1f x", speed)
    }
}
