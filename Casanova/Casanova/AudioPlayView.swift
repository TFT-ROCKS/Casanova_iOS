//
//  AudioPlayView.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 12/10/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!
    
    var seconds: Int!
    var timer: Timer!
    var audioPlayer: AVAudioPlayer!
    var audioFile: URL! {
        didSet {
            // Prepare for audio player
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
            } catch {
                // couldn't load file :(
                //print("couldn't load file :(")
            }
            audioPlayer.enableRate = true
            audioPlayer.prepareToPlay()
            seconds = Int(audioPlayer.duration)
            timeLabel.text = TimeManager.shared.timeString(time: audioPlayer.duration)
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
        Bundle.main.loadNibNamed("AudioPlayView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        controlButton.addTarget(self, action: #selector(controlButtonTapped(_:)), for: .touchUpInside)
        
        layer.masksToBounds = true
        layer.cornerRadius = bounds.height / 2
    }

    func playButtonClicked(_ sender: UIButton) {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerForPlayer), userInfo: nil, repeats: true)
        }
        audioPlayer.play()
        controlButton.setImage(#imageLiteral(resourceName: "pause_btn"), for: .normal)
    }
    
    func pauseButtonClicked(_ sender: UIButton) {
        if audioPlayer != nil && audioPlayer.isPlaying {
            audioPlayer.pause()
            timer.invalidate()
            timer = nil
            controlButton.setImage(#imageLiteral(resourceName: "play_btn"), for: .normal)
        }
    }
    
    func updateTimerForPlayer() {
        if seconds < 1 {
            timer.invalidate()
            timer = nil
            controlButton.setImage(#imageLiteral(resourceName: "play_btn"), for: .normal)
            seconds = Int(audioPlayer.duration)
            timeLabel.text = TimeManager.shared.timeString(time: TimeInterval(seconds))
        } else {
            seconds = seconds - 1
            timeLabel.text = TimeManager.shared.timeString(time: TimeInterval(seconds))
        }
    }
    
    func controlButtonTapped(_ sender: UIButton) {
        if audioPlayer == nil { return }
        if audioPlayer.isPlaying {
            pauseButtonClicked(sender)
        } else {
            playButtonClicked(sender)
        }
    }
}
