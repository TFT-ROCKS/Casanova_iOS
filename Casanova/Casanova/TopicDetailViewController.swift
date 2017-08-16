//
//  TopicDetailViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/31/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import AVFoundation

enum TopicDetailViewMode {
    case record
    case reward
}

class TopicDetailViewController: UIViewController {
    
    // class vars
    var mode: TopicDetailViewMode {
        didSet {
            if mode == .record {
                tableView.isScrollEnabled = false
            } else {
                tableView.isScrollEnabled = true
            }
        }
    }
    var topic: Topic!
    var answers: [Answer]?
    var cellInUse = -1
    
    // sub views
    let topicView: TopicHeaderView = TopicHeaderView(frame: .zero)
    let tableView: UITableView = UITableView(frame: .zero)
    
    let recordButton: UIButton = UIButton(frame: .zero)
    let speakingImgView: UIImageView = UIImageView(frame: .zero)
    let skipButton: UIButton = UIButton(frame: .zero)
    let clockIcon: UIImageView = UIImageView(frame: .zero)
    let timeLabel: UILabel = UILabel(frame: .zero)
    
    let audioBarButton: UIButton = UIButton(frame: .zero)
    let audioTimeLabel: UILabel = UILabel(frame: .zero)
    let postButton: UIButton = UIButton(frame: .zero)
    
    let rewardImageView: UIImageView = UIImageView(frame: .zero)
    let rewardLabel: UILabel = UILabel(frame: .zero)
    
    var timer: Timer!
    var seconds: Int = 60
    let secs: Int = 60
    
    // record
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    // init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(withTopic topic: Topic, withMode mode: TopicDetailViewMode) {
        self.topic = topic
        self.mode = mode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()
        addConstraints()
        fetchTopicDetail()
        setTitle()
        
        // Other configs
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = Colors.TopicDetailVC.NavBar.tintColor()
        
        if mode == .record {
            tableView.isHidden = true
        }
        
        view.backgroundColor = Colors.TopicDetailVC.View.backgroundColor()
        
        recordingSession = AVAudioSession.sharedInstance()
        
        // record setup
        if mode == .record {
            do {
                try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try recordingSession.setActive(true)
                recordingSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            self.layoutRecordViews()
                            self.addRecordConstraints()
                        } else {
                            // failed to record!
                        }
                    }
                }
            } catch {
                // failed to record!
            }
        }
    }
    
    func layoutSubviews() {
        layoutTopicView()
        layoutTableView()
    }
    
    func addConstraints() {
        addTopicViewConstraints()
        addTableViewConstraints()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func fetchTopicDetail() {
        TopicManager.shared.fetchTopicDetail(for: topic, withCompletion: { (error, topic) in
            if error == nil {
                // success
                self.topic = topic
                self.answers = topic?.answers
                // reload table view
                self.tableView.reloadData()
            }
        })
    }
    
    func setTitle() {
        let titleLabel = UILabel(frame: CGRect(x: 95, y: 11, width: 184, height: 22))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.text = "Question"
        titleLabel.font = Fonts.TopicDetailVC.NavBar.titleTextFont()
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
}

// MARK: - TopicView
extension TopicDetailViewController {
    func layoutTopicView() {
        view.addSubview(topicView)
        topicView.translatesAutoresizingMaskIntoConstraints = false
        view.bringSubview(toFront: topicView)
        topicView.topic = topic
        configTopicView()
    }
    
    func configTopicView() {
        // Add shadow layer to topic header view
        topicView.layer.shadowOffset = CGSize(width: 0, height: 1)
        topicView.layer.shadowColor = Colors.TopicDetailVC.TopicView.shadowColor().cgColor
        topicView.layer.shadowRadius = 3.0
        topicView.layer.shadowOpacity = 1.0
    }
    
    func addTopicViewConstraints() {
        topicView.topAnchor.constraint(equalTo: view.topAnchor, constant: 1).isActive = true
        topicView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topicView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TopicDetailViewController: UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    func layoutTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        configTableView()
        registerCustomCell()
    }
    
    func configTableView() {
        tableView.separatorStyle = .none
        
        tableView.backgroundColor = UIColor(red: 248/255.0, green: 250/255.0, blue: 252/255.0, alpha: 1)
        // Hack for table view top space in between with topic view
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
    }
    
    func registerCustomCell() {
        tableView.register(AnswerDetailTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerWithTextCell)
        tableView.register(AnswerDetailTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerWithoutTextCell)
    }
    
    func addTableViewConstraints() {
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topicView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let answers = answers {
            let answer = answers[indexPath.row]
            if answer.title == "" {
                let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerWithoutTextCell, for: indexPath) as! AnswerDetailTableViewCell
                cell.answer = answer
                cell.audioSlider.tag = indexPath.row
                cell.audioButton.tag = indexPath.row
                cell.audioButton.addTarget(self, action: #selector(self.audioButtonTapped(_:)), for: .touchUpInside)
                cell.audioSlider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerWithTextCell, for: indexPath) as! AnswerDetailTableViewCell
                cell.answer = answer
                cell.audioSlider.tag = indexPath.row
                cell.audioButton.tag = indexPath.row
                cell.audioButton.addTarget(self, action: #selector(self.audioButtonTapped(_:)), for: .touchUpInside)
                cell.audioSlider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func audioButtonTapped(_ sender: UIButton) {
        if cellInUse != -1 {
            // reset previous cell in use
            if let cell = tableView.cellForRow(at: IndexPath(row: cellInUse, section: 0)) as? AnswerDetailTableViewCell {
                cell.audioSlider.value = 0
                cell.audioSlider.isEnabled = false
                cell.audioTimeLabel.text = "00:00"
                if audioPlayer != nil {
                    audioPlayer.stop()
                    audioPlayer = nil
                }
                if timer != nil {
                    timer.invalidate()
                }
            }
        }
        if let url = URL(string: answers![sender.tag].audioURL ?? "") {
            let index = sender.tag
            cellInUse = sender.tag
            downloadFileFromURL(url: url, tag: index)
        }
    }
    
    func downloadFileFromURL(url: URL, tag: Int) {
        
        var downloadTask: URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { [weak self] (URL, response, error) -> Void in
            self?.play(url: URL!, row: tag)
        })
        downloadTask.resume()
    }
    
    func play(url: URL, row: Int) {
        print("playing \(url)")
        let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! AnswerDetailTableViewCell
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            cell.audioSlider.maximumValue = Float(audioPlayer.duration)
            cell.audioSlider.value = 0.0
            cell.audioSlider.isEnabled = true
            audioPlayer.volume = 1.0
            audioPlayer.play()
            Utils.runOnMainThread {
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime(_:)), userInfo: row, repeats: true)
            }
            
        } catch let error as NSError {
            //self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
        
    }
    
    func sliderValueChanged(_ sender: UISlider) {
        if sender.tag != cellInUse { return }
        let cell = tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! AnswerDetailTableViewCell
        if audioPlayer != nil {
            audioPlayer.currentTime = TimeInterval(sender.value)
            cell.audioTimeLabel.text = TimeManager.shared.timeString(time: audioPlayer.currentTime)
        }
    }
    
    func updateTime(_ timer: Timer) {
        if let cell = tableView.cellForRow(at: IndexPath(row: timer.userInfo as! Int, section: 0)) as? AnswerDetailTableViewCell {
            cell.audioSlider.value = Float(audioPlayer.currentTime)
            cell.audioTimeLabel.text = TimeManager.shared.timeString(time: audioPlayer.currentTime)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer.invalidate()
        if let cell = tableView.cellForRow(at: IndexPath(row: cellInUse, section: 0)) as? AnswerDetailTableViewCell {
            cell.audioSlider.isEnabled = false
        }
    }
}

// MARK: - Record Button and Skip Buttons
extension TopicDetailViewController: AVAudioRecorderDelegate {
    
    func registerButtons() {
        recordButton.addTarget(self, action: #selector(self.recordButtonClicked(_:)), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(self.skipButtonClicked(_:)), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(self.postButtonClicked(_:)), for: .touchUpInside)
    }
    
    func layoutRecordViews() {
        view.addSubview(recordButton)
        view.addSubview(skipButton)
        view.addSubview(clockIcon)
        view.addSubview(timeLabel)
        view.addSubview(audioBarButton)
        view.addSubview(postButton)
        view.addSubview(rewardLabel)
        view.addSubview(rewardImageView)
        
        view.bringSubview(toFront: recordButton)
        view.bringSubview(toFront: skipButton)
        view.bringSubview(toFront: clockIcon)
        view.bringSubview(toFront: timeLabel)
        view.bringSubview(toFront: audioBarButton)
        view.bringSubview(toFront: postButton)
        
        configRecordViews()
        initRecordViews()
        registerButtons()
    }
    
    func configRecordViews() {
        // config buttons
        recordButton.layer.borderColor = UIColor(red: 120/255.0, green: 215/255.0, blue: 245/255.0, alpha: 1).cgColor
        recordButton.layer.borderWidth = 2.0
        recordButton.layer.cornerRadius = 85.9 / 2
        recordButton.layer.masksToBounds = true
        recordButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        recordButton.layer.shadowRadius = 4
        recordButton.layer.shadowColor = Colors.TopicDetailVC.Buttons.shadowColor().cgColor
        recordButton.layer.shadowOpacity = 1
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        skipButton.layer.borderColor = UIColor(red: 164/255.0, green: 170/255.0, blue: 179/255.0, alpha: 1).cgColor
        skipButton.layer.borderWidth = 1.0
        skipButton.layer.cornerRadius = 29.9 / 2
        skipButton.layer.masksToBounds = true
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        
        // buttons' sub views
        speakingImgView.frame = CGRect(x: 31.6, y: 27.4, width: 22.9, height: 30.6)
        speakingImgView.image = #imageLiteral(resourceName: "speaking-h")
        recordButton.addSubview(speakingImgView)
        
        let skipLabel = UILabel(frame: CGRect(x: 14.4, y: 2.45, width: 35.2, height: 25))
        skipLabel.font = Fonts.TopicDetailVC.Buttons.skipButtonFont()
        skipLabel.text = "Skip"
        skipLabel.textColor = Colors.TopicDetailVC.Buttons.skipButtonTextColor()
        skipButton.addSubview(skipLabel)
        
        // clock icon and time label
        clockIcon.translatesAutoresizingMaskIntoConstraints = false
        clockIcon.image = #imageLiteral(resourceName: "clock")
        clockIcon.contentMode = .scaleAspectFit
        
        timeLabel.backgroundColor = UIColor.clear
        timeLabel.font = Fonts.TopicDetailVC.Labels.timeLabelFont()
        timeLabel.textColor = Colors.TopicDetailVC.Labels.timeLabelTextColor()
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = TimeManager.shared.timeString(time: TimeInterval(secs))
        
        // audioBarButton
        audioBarButton.translatesAutoresizingMaskIntoConstraints = false
        audioBarButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        audioBarButton.layer.shadowRadius = 4
        audioBarButton.layer.shadowColor = Colors.TopicDetailVC.Buttons.shadowColor().cgColor
        audioBarButton.layer.shadowOpacity = 1
        audioBarButton.setImage(#imageLiteral(resourceName: "audio_bar"), for: .normal)
        audioBarButton.imageView?.contentMode = .scaleAspectFit
        audioTimeLabel.frame = CGRect(x: 38, y: 8.5, width: 41, height: 22)
        audioTimeLabel.textColor = UIColor.white
        audioTimeLabel.font = Fonts.TopicDetailVC.Labels.timeLabelFont()
        audioBarButton.addSubview(audioTimeLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        audioBarButton.addGestureRecognizer(tap)
        
        // post button
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.layer.borderWidth = 1
        postButton.layer.borderColor = Colors.TopicDetailVC.Buttons.postButtonColor().cgColor
        postButton.layer.cornerRadius = 29.9 / 2
        postButton.layer.masksToBounds = true
        postButton.setTitle("Post", for: .normal)
        postButton.titleLabel?.font = Fonts.TopicDetailVC.Buttons.postButtonFont()
        postButton.setTitleColor(Colors.TopicDetailVC.Buttons.postButtonColor(), for: .normal)
    }
    
    func addRecordConstraints() {
        // record button constraints
        recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: 85.9).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 85.9).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -95.1).isActive = true
        
        // skip button constraints
        skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        skipButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        skipButton.heightAnchor.constraint(equalToConstant: 29.9).isActive = true
        skipButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -37.1).isActive = true
        
        // clock icon constraints
        clockIcon.widthAnchor.constraint(equalToConstant: 15.0).isActive = true
        clockIcon.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
        clockIcon.leadingAnchor.constraint(equalTo: recordButton.leadingAnchor, constant: 10).isActive = true
        clockIcon.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 35).isActive = true
        
        // time label constraints
        timeLabel.widthAnchor.constraint(equalToConstant: 41).isActive = true
        timeLabel.heightAnchor.constraint(equalToConstant: 19).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: clockIcon.trailingAnchor, constant: 6).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: clockIcon.centerYAnchor).isActive = true
        
        // audioBarButton constraints
        audioBarButton.widthAnchor.constraint(equalToConstant: 117).isActive = true
        audioBarButton.heightAnchor.constraint(equalToConstant: 39).isActive = true
        audioBarButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -119).isActive = true
        audioBarButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // post button constraints
        postButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 29.9).isActive = true
        postButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -37.1).isActive = true
        postButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func initRecordViews() {
        recordButton.isHidden = false
        skipButton.isHidden = false
        recordButton.fadeIn()
        skipButton.fadeIn()
        
        clockIcon.isHidden = true
        timeLabel.isHidden = true
        audioBarButton.isHidden = true
        postButton.isHidden = true
        rewardLabel.isHidden = true
        rewardImageView.isHidden = true
    }
    
    func recordButtonClicked(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func skipButtonClicked(_ sender: UIButton) {
        recordButton.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration) { success in
            if success {
                self.skipButton.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration) { success in
                    if success {
                        self.tableView.fadeIn(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration)
                    }
                }
            }
        }
    }
    
    func playButtonClicked() {
        seconds = Int(audioPlayer.duration)
        audioTimeLabel.text = TimeManager.shared.timeString(time: TimeInterval(seconds))
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerForPlayer), userInfo: nil, repeats: true)
        audioPlayer.play()
    }
    
    func deleteButtonClicked() {
        // reset player
        audioPlayer.stop()
        audioPlayer = nil
        timer.invalidate()
        
        // reset record
        audioBarButton.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: { success in
            if success {
                self.initRecordViews()
                self.speakingImgView.image = #imageLiteral(resourceName: "speaking-h")
                self.recordButton.layer.borderWidth = 2
                self.recordButton.setBackgroundImage(nil, for: .normal)
                
                // reset timer
                self.seconds = self.secs
            }
        })
    }
    
    func postButtonClicked(_ sender: UIButton) {
    }
    
    func handleSingleTap(_ sender: UIGestureRecognizer) {
        let leftPart = CGRect(x: 0, y: 0, width: audioBarButton.bounds.width / 2, height: audioBarButton.bounds.height)
        let point = sender.location(in: audioBarButton)
        if leftPart.contains(point) {
            // play audio
            playButtonClicked()
        } else {
            // delete audio
            deleteButtonClicked()
        }
    }
    
    func updateTimerForRecorder() {
        if seconds < 1 {
            finishRecording(success: true)
        } else {
            seconds -= 1
            timeLabel.text = TimeManager.shared.timeString(time: TimeInterval(seconds))
        }
    }
    
    func updateTimerForPlayer() {
        if seconds < 1 {
            timer.invalidate()
        } else {
            seconds -= 1
            audioTimeLabel.text = TimeManager.shared.timeString(time: TimeInterval(seconds))
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(topic.id)-speaking.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            // record button animation
            recordButton.blink()
            
        } catch {
            finishRecording(success: false)
            return
        }
        
        recordButton.setBackgroundImage(#imageLiteral(resourceName: "record_btn"), for: .normal)
        recordButton.layer.borderWidth = 0
        speakingImgView.image = #imageLiteral(resourceName: "speaking-w")
        skipButton.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: { success in
            if success {
                self.clockIcon.fadeIn(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: nil)
                self.timeLabel.text = TimeManager.shared.timeString(time: TimeInterval(self.secs))
                self.timeLabel.fadeIn(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: { success in
                    if success {
                        // start timer
                        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerForRecorder), userInfo: nil, repeats: true)
                    }
                })
            }
        })
    }
    
    func finishRecording(success: Bool) {
        recordButton.stopBlink()
        audioRecorder.stop()
        audioRecorder = nil
        // reset timer
        self.seconds = self.secs
        if success {
            timer.invalidate()
            // time up
            recordButton.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: nil)
            clockIcon.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: nil)
            timeLabel.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: { success in
                if success {
                    // show audio bar button and post button
                    
                    self.audioBarButton.fadeIn(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: nil)
                    self.postButton.fadeIn(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: nil)
                    
                    // Prepare for audio player
                    let audioFile = self.getDocumentsDirectory().appendingPathComponent("\(self.topic.id)-speaking.m4a")
                    do {
                        self.audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
                    } catch {
                        // couldn't load file :(
                    }
                    self.audioPlayer.prepareToPlay()
                    
                    self.audioTimeLabel.text = TimeManager.shared.timeString(time: self.audioPlayer.duration)
                }
            })
        } else {
            // reset views
            self.initRecordViews()
            self.speakingImgView.image = #imageLiteral(resourceName: "speaking-h")
            self.recordButton.layer.borderWidth = 2
            self.recordButton.setBackgroundImage(nil, for: .normal)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}
