//
//  AudioRecordView.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 11/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

protocol AudioRecordViewDelegate: class {
    func startRecord()
    func stopRecord()
    func finishRecord(success: Bool)
}

class AudioRecordView: UIView, AnimatedCircleViewDelegate {
    // sub views
    var recordCircleView: AnimatedCircleView!
    var recordImageView: UIImageView!
    var uploadCircleView: AnimatedCircleView!
    var uploadImageView: UIImageView!
    var label: UILabel!
    
    // vars
    var isRecording: Bool = false
    var recordDuration: Int = 0 // in seconds
    var timeRemained: Int = 0
    var recordTimer: Timer!
    
    // delegate
    weak var delegate: AudioRecordViewDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func config() {
        // config
        label.font = UIFont.pfr(size: 17)
        label.textColor = UIColor.tftCoolGrey
        label.textAlignment = .center
        
        // image
        recordImageView.image = #imageLiteral(resourceName: "speaking_bar_h")
        recordImageView.contentMode = .scaleAspectFit
        uploadImageView.image = #imageLiteral(resourceName: "check_green")
        uploadImageView.contentMode = .scaleAspectFit
        
        // delegate
        uploadCircleView.delegate = self
        recordCircleView.delegate = self
    }
    
    override func layoutSubviews() {
        // subviews contraints
        recordCircleView = AnimatedCircleView(frame: .zero, strokeColor: UIColor(red: 15/255.0, green: 181/255.0, blue: 228/255.0, alpha: 1).cgColor, fillColor: UIColor(red: 15/255.0, green: 181/255.0, blue: 228/255.0, alpha: 0.2).cgColor)
        recordImageView = UIImageView(frame: .zero)
        uploadCircleView = AnimatedCircleView(frame: .zero, strokeColor: UIColor(red: 85/255.0, green: 222/255.0, blue: 166/255.0, alpha: 1).cgColor, fillColor: UIColor(red: 85/255.0, green: 222/255.0, blue: 166/255.0, alpha: 0.2).cgColor)
        uploadImageView = UIImageView(frame: .zero)
        label = UILabel(frame: .zero)
        
        addSubview(uploadCircleView)
        addSubview(uploadImageView)
        addSubview(recordCircleView)
        addSubview(recordImageView)
        addSubview(label)
        uploadCircleView.addSubview(uploadImageView)
        recordCircleView.addSubview(recordImageView)
        
        recordCircleView.translatesAutoresizingMaskIntoConstraints = false
        recordImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadCircleView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        uploadCircleView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        uploadCircleView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        uploadCircleView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        uploadCircleView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -20).isActive = true
        
        uploadImageView.leadingAnchor.constraint(equalTo: uploadCircleView.leadingAnchor, constant: 19).isActive = true
        uploadImageView.trailingAnchor.constraint(equalTo: uploadCircleView.trailingAnchor, constant: -19).isActive = true
        uploadImageView.topAnchor.constraint(equalTo: uploadCircleView.topAnchor, constant: 19).isActive = true
        uploadImageView.bottomAnchor.constraint(equalTo: uploadCircleView.bottomAnchor, constant: -19).isActive = true
        
        recordCircleView.leadingAnchor.constraint(equalTo: uploadCircleView.leadingAnchor, constant: 0).isActive = true
        recordCircleView.trailingAnchor.constraint(equalTo: uploadCircleView.trailingAnchor, constant: 0).isActive = true
        recordCircleView.topAnchor.constraint(equalTo: uploadCircleView.topAnchor, constant: 0).isActive = true
        recordCircleView.bottomAnchor.constraint(equalTo: uploadCircleView.bottomAnchor, constant: 0).isActive = true
        
        recordImageView.leadingAnchor.constraint(equalTo: recordCircleView.leadingAnchor, constant: 19).isActive = true
        recordImageView.trailingAnchor.constraint(equalTo: recordCircleView.trailingAnchor, constant: -19).isActive = true
        recordImageView.topAnchor.constraint(equalTo: recordCircleView.topAnchor, constant: 19).isActive = true
        recordImageView.bottomAnchor.constraint(equalTo: recordCircleView.bottomAnchor, constant: -19).isActive = true
        
        label.widthAnchor.constraint(equalToConstant: 100).isActive = true
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        label.centerXAnchor.constraint(equalTo: uploadCircleView.centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: uploadCircleView.bottomAnchor, constant: 15).isActive = true
        
        config()
    }
    
    func setup(with duration: Int) {
        recordDuration = duration
        timeRemained = duration
        isRecording = false
        disableTimer()
        // hide upload view
        uploadCircleView.isHidden = true
        uploadCircleView.alpha = 1
        uploadImageView.isHidden = true
        uploadImageView.alpha = 1
        // un-hide record view
        recordCircleView.isHidden = false
        recordCircleView.alpha = 1
        // setup label text
        label.text = "点击开始"
        // remove anims if have
        uploadCircleView.reset()
        recordCircleView.reset()
    }
    
    func record() {
        isRecording = true
        // label reset time
        label.text = TimeManager.shared.timeString(time: TimeInterval(recordDuration))
        // set timer
        recordTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerForRecorder), userInfo: nil, repeats: true)
        // record animation
        recordCircleView.animateForRecording(duration: Float(recordDuration), toValue: 1)
    }
    
    func endRecord() {
        isRecording = false
        uploadCircleView.isUserInteractionEnabled = false
        // label text
        label.text = "正在上传"
        // timer invalidation
        disableTimer()
        // view hide and show
        recordCircleView.fadeOut()
        uploadCircleView.fadeIn()
    }
    
    func upload(with progress: Float) {
        uploadCircleView.animateForUploading(with: progress)
    }
    
    func finishUploading() {
        uploadImageView.fadeIn()
        label.text = "成功上传"
    }
    
    func updateTimerForRecorder() {
        if timeRemained < 1 {
            delegate.finishRecord(success: true)
        } else {
            timeRemained -= 1
            label.text = TimeManager.shared.timeString(time: TimeInterval(timeRemained))
        }
    }
    
    func disableTimer() {
        if recordTimer != nil {
            recordTimer.invalidate()
            recordTimer = nil
        }
    }
    
    // MARK: - AnimatedCircleViewDelegate
    
    func animatedCircleViewDidTapped(_ tap: UITapGestureRecognizer) {
        if isRecording {
            delegate.stopRecord()
        } else {
            delegate.startRecord()
        }
    }
}
