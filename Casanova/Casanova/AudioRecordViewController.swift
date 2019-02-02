//
//  AudioRecordViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 11/15/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioRecordViewControllerDelegate: class {
    func reloadTableView()
}

class AudioRecordViewController: UIViewController {
    
    // UI
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var audioRecordView: AudioRecordView!
    let postTextView: AudioCommentPostView = AudioCommentPostView(frame: .zero)
    var toggle: JTMaterialSwitch!
    var togglePlaced = false // Used for placing toggle after didLayoutSubviews
    
    // constraints
    var bottomConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    var topConstraint: NSLayoutConstraint!
    
    // delegate
    weak var delegate: AudioRecordViewControllerDelegate!
    // vars
    var answer: Answer!
    // record
    var audioSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    // comment
    var cmtAudioUrl: String!
    var cmtAudioUUID: String?
    
    // lazy vars
    lazy var noteTitle: String = {
        return self.answer.note
    }()
    
    lazy var engTitle: String = {
        return self.answer.title
    }()
    
    lazy var chiTitle: String = {
        return self.answer.chineseTitle
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config
        mainTitleLabel.font = UIFont.pfs(size: 18)
        mainTitleLabel.textColor = UIColor.tftCoolGrey
        mainTitleLabel.textAlignment = .center
        mainTitleLabel.text = "跟读"
        
        textView.isEditable = false
        showEngTitle()
        
        audioRecordView.delegate = self
        
        audioSession = AVAudioSession.sharedInstance()
        
        // Post Text View
        layoutPostTextView()
        addPostTextViewConstraints()
        postTextView.answer = answer
        
        // Toggle
        createToggle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        audioRecordView.disableTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        prepareRecord()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        placeToggle()
    }
    
    // MARK: - Utils
    func showEngTitle() {
        textView.attributedText = AttrString.answerAttrString(engTitle)
    }
    
    func showChiTitle() {
        textView.attributedText = AttrString.answerAttrStringChinese(chiTitle)
    }
    
    func prepareRecord() {
        audioRecordView.setup(with: 60)
    }
}

// MARK: - Audio Record

extension AudioRecordViewController: AudioRecordViewDelegate {
    
    // MARK: - AudioRecordViewDelegate
    
    func startRecord() {
        record()
    }
    
    func stopRecord() {
        finishRecord(success: true)
    }
    
    func finishRecord(success: Bool) {
        audioRecordView.endRecord()
        audioRecorder.stop()
        audioRecorder = nil
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(false)
        } catch {
            
        }
        if success {
            uploadAudio()
        } else {
            // reset audio record view
            prepareRecord()
        }
    }
    
    func uploadAudio() {
        let audioFile = self.getDocumentsDirectory().appendingPathComponent("\(answer.id)-speaking-answer.wav")
        OSSAPIService.shared.uploadAudioFile(url: audioFile, withProgressBlock: { (bytesSent, totalByteSent, totalBytesExpectedToSend) in
            //print(bytesSent, totalByteSent, totalBytesExpectedToSend)
            Utils.runOnMainThread {
                let progress = Float(totalByteSent) / Float(totalBytesExpectedToSend)
                self.audioRecordView.upload(with: progress)
            }
        }, withCompletionBlock: { (error, url, uuid) in
            if error == nil {
                //print("upload audio success")
                Utils.runOnMainThread {
                    self.audioRecordView.finishUploading()
                    self.cmtAudioUrl = url!
                    self.cmtAudioUUID = uuid!
                    self.postTextView.fadeIn()
                    self.postTextView.audioUrl = url!
                    self.postTextView.audioFile = audioFile
                    self.postTextView.textView.becomeFirstResponder()
                }
            } else {
                // upload error
                self.prepareRecord()
            }
        })
    }
    
    func record() {
        if audioRecorder == nil {
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try audioSession.setActive(true)
                audioSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            self.audioRecordView.record()
                            self.startRecording()
                        } else {
                            // failed to record!
                            self.handleMicNotEnabled()
                        }
                    }
                }
            } catch {
                // failed to record!
            }
        }
    }
    
    func handleMicNotEnabled() {
        let alertController = AlertManager.alertController(title: "TFT无法获取麦克风权限", msg: "请在隐私中打开麦克风允许", style: .alert, actionT1: "打开隐私设置", style1: .default, handler1: { value in
            let path = UIApplicationOpenSettingsURLString
            if let settingsURL = URL(string: path), UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }, actionT2: "取消", style2: .default, handler2: nil, viewForPopover: self.view)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(answer.id)-speaking-answer.wav")
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: audioFilename.path) {
            do {
                try fileManager.removeItem(at: audioFilename)
            } catch {
                
            }
        }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecord(success: false)
            return
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecordViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecord(success: false)
        }
    }
}

// MARK: - Custom toggle

extension AudioRecordViewController {
    func createToggle() {
        toggle = JTMaterialSwitch(size: JTMaterialSwitchSizeSmall, state: JTMaterialSwitchStateOff)!
        toggle.thumbOnTintColor = UIColor.white
        toggle.thumbOffTintColor = UIColor.white
        toggle.trackOnTintColor = UIColor.brandColor
        toggle.trackOffTintColor = UIColor.tftCoolGrey
        toggle.rippleFillColor = UIColor.brandColor
        toggle.font = UIFont.pfm(size: 8)
        toggle.onText = "中"
        toggle.offText = "中"
        toggle.onTextColor = UIColor.brandColor
        toggle.offTextColor = UIColor.tftCoolGrey
    }
    
    func placeToggle() {
        if togglePlaced { return }
        // Calculate center for toggle
        let centerX = view.bounds.width - 30.0
        let centerY = mainTitleLabel.center.y
        toggle.center = CGPoint(x: centerX, y: centerY)
        toggle.addTarget(self, action: #selector(toggleStateChanged), for: .valueChanged)
        view.addSubview(toggle)
        togglePlaced = true
    }
    
    func toggleStateChanged() {
        if toggle.isOn {
            showChiTitle()
        } else {
            showEngTitle()
        }
    }
}

// MARK: - AudioCommentPostViewDelegate

extension AudioRecordViewController: AudioCommentPostViewDelegate {
    func layoutPostTextView() {
        view.addSubview(postTextView)
        postTextView.translatesAutoresizingMaskIntoConstraints = false
        view.bringSubview(toFront: postTextView)
        postTextView.delegate = self
        postTextView.isHidden = true
    }
    
    func addPostTextViewConstraints() {
        NSLayoutConstraint(item: postTextView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: postTextView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        
        heightConstraint = NSLayoutConstraint(item: postTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 150)
        heightConstraint.isActive = true
        
        topConstraint = NSLayoutConstraint(item: postTextView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1.0, constant: 0.0)
        topConstraint.isActive = false
        
        bottomConstraint = NSLayoutConstraint(item: postTextView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant:0.0)
        bottomConstraint.isActive = true
    }
    
    // Deal with keyboard notification
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.height {
                bottomConstraint.constant = 0
            } else {
                bottomConstraint.constant = -(endFrame?.size.height ?? 0)
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func reloadTableView() {
        dismiss(animated: true, completion: { _ in
            self.delegate.reloadTableView()
        })
    }
    
    func reset() {
        // delete audio file on OSS
        if let cmtAudioUUID = cmtAudioUUID {
            OSSAPIService.shared.deleteAudioFile(uuid: cmtAudioUUID)
        }
        prepareRecord()
    }
}
