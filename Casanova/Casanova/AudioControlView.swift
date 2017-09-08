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
    @IBOutlet weak var profileView: UIWebView!
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
        profileView.scrollView.isScrollEnabled = false
    }
    
    func updateUI(withTag tag: Int, answer: Answer) {
        if cellInUse != tag {
            cellInUse = tag
            // Update UI
            // load image into webView
            let path: String = Bundle.main.path(forResource: "TFTicons_avatar_\(answer.user.id % 8)", ofType: "svg")!
            let url: URL = URL(fileURLWithPath: path)  //Creating a URL which points towards our path
            // Creating a page request which will load our URL (Which points to our path)
            let request: URLRequest = URLRequest(url: url)
            profileView.delegate = self
            profileView.loadRequest(request)  // Telling our webView to load our above request
            
            usernameLabel.text = answer.user.username
            
            isPlaying = true
            audioButton.setImage(#imageLiteral(resourceName: "pause_btn-h"), for: .normal)
        }
    }

}
