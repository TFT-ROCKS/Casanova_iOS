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
    let cellVerticalSpace: CGFloat = 10.0
    let cellHorizontalSpace: CGFloat = 12.0
    
    // status bar
    var statusBarShouldBeHidden = false
    
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
        navigationController?.navigationBar.tintColor = UIColor.navTintColor
        
        if mode == .record {
            tableView.isHidden = true
        }
        
        view.backgroundColor = UIColor.bgdColor
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if audioPlayer != nil {
            audioPlayer.stop()
        }
        if timer != nil {
            timer.invalidate()
        }
        if audioRecorder != nil {
            audioRecorder.stop()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Hide the status bar
        statusBarShouldBeHidden = true
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
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
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
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
        titleLabel.font = UIFont.mr(size: 17)
        titleLabel.textColor = UIColor.nonBodyTextColor
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
        topicView.layer.shadowColor = UIColor.shadowColor.cgColor
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
        
        tableView.backgroundColor = UIColor.bgdColor
        // Hack for table view top space in between with topic view
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
    }
    
    func registerCustomCell() {
        tableView.register(AnswerDetailTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerDefaultCell)
        tableView.register(AnswerDetailTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerWithoutAudioCell)
        let loadMoreTableViewCell = UINib(nibName: ReuseIDs.HomeVC.View.loadMoreTableViewCell, bundle: nil)
        tableView.register(loadMoreTableViewCell, forCellReuseIdentifier: ReuseIDs.HomeVC.View.loadMoreTableViewCell)
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
            var cell: AnswerDetailTableViewCell
            
            if answer.audioURL == nil {
                cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerWithoutAudioCell, for: indexPath) as! AnswerDetailTableViewCell
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerDefaultCell, for: indexPath) as! AnswerDetailTableViewCell
            }
            cell.mode = .short
            cell.answer = answer
            cell.audioButton?.tag = indexPath.row
            cell.audioSlider?.tag = indexPath.row
            cell.audioButton?.addTarget(self, action: #selector(self.audioButtonTapped(_:)), for: .touchUpInside)
            cell.audioSlider?.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
            if indexPath.row != cellInUse {
                cell.audioTimeLabel?.text = "00:00"
                cell.audioSlider?.isEnabled = false
                cell.audioSlider?.value = 0
            } else {
                if audioPlayer != nil {
                    cell.audioSlider?.isEnabled = true
                    cell.audioTimeLabel?.text = TimeManager.shared.timeString(time: audioPlayer.currentTime)
                    cell.audioSlider?.value = Float(audioPlayer.currentTime)
                    cell.audioSlider?.maximumValue = Float(audioPlayer.duration)
                } else {
                    
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let cell = cell as? AnswerDetailTableViewCell {
            
            // Visualize the margin surrounding the table view cell
            cell.contentView.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
            
            // remove small whiteRoundedView before adding new one
            for view in cell.contentView.subviews {
                if view.tag == 100 {
                    view.removeFromSuperview()
                }
            }
            
            let whiteRoundedView : UIView = UIView(frame: CGRect(x: cellHorizontalSpace, y: cellVerticalSpace / 2, width: self.view.bounds.width - (2 * cellHorizontalSpace), height: cell.bounds.height - cellVerticalSpace / 2))
            whiteRoundedView.tag = 100
            whiteRoundedView.layer.cornerRadius = 5.0
            whiteRoundedView.layer.backgroundColor = UIColor.bgdColor.cgColor
            whiteRoundedView.layer.masksToBounds = false
            whiteRoundedView.layer.shadowColor = UIColor.shadowColor.cgColor
            whiteRoundedView.layer.shadowOffset = CGSize(width: 0, height: 1)
            whiteRoundedView.layer.shadowOpacity = 1
            
            cell.contentView.addSubview(whiteRoundedView)
            cell.contentView.sendSubview(toBack: whiteRoundedView)
            
        } else if let cell = cell as? LoadMoreTableViewCell {
            
            // Visualize the margin surrounding the table view cell
            cell.contentView.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = AnswerDetailViewController(withTopic: topic, withAnswer: answers![indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func audioButtonTapped(_ sender: UIButton) {
        if cellInUse == sender.tag {
            return
        }
        if cellInUse != -1 {
            // reset previous cell in use
            if let cell = tableView.cellForRow(at: IndexPath(row: cellInUse, section: 0)) as? AnswerDetailTableViewCell {
                cell.audioTimeLabel?.text = "00:00"
                cell.audioSlider?.isEnabled = false
                cell.audioSlider?.value = 0
                if audioPlayer != nil {
                    audioPlayer.stop()
                    audioPlayer = nil
                }
                if timer != nil {
                    timer.invalidate()
                    timer = nil
                }
            }
        }
        if let url = URL(string: answers![sender.tag].audioURL ?? "") {
            cellInUse = sender.tag
            downloadFileFromURL(url)
        }
    }
    
    func downloadFileFromURL(_ url: URL) {
        
        var downloadTask: URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { [weak self] (URL, response, error) -> Void in
            self?.play(url: URL!)
        })
        downloadTask.resume()
    }
    
    func play(url: URL) {
        if let cell = tableView.cellForRow(at: IndexPath(row: cellInUse, section: 0)) as? AnswerDetailTableViewCell {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
                audioPlayer.volume = 1.0
                audioPlayer.play()
                
                cell.audioSlider?.maximumValue = Float(audioPlayer.duration)
                cell.audioSlider?.value = 0.0
                cell.audioSlider?.isEnabled = true
                
                Utils.runOnMainThread {
                    self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime(_:)), userInfo: nil, repeats: true)
                }
                
            } catch let error as NSError {
                audioPlayer = nil
                print(error.localizedDescription)
            } catch {
                print("AVAudioPlayer init failed")
            }
        }
    }
    
    func sliderValueChanged(_ sender: UISlider) {
        if sender.tag != cellInUse { return }
        guard let cell = tableView.cellForRow(at: IndexPath(row: cellInUse, section: 0)) as? AnswerDetailTableViewCell else { return }
        if audioPlayer != nil {
            audioPlayer.currentTime = TimeInterval(sender.value)
            cell.audioTimeLabel?.text = TimeManager.shared.timeString(time: audioPlayer.currentTime)
        }
    }
    
    func updateTime(_ timer: Timer) {
        if let cell = tableView.cellForRow(at: IndexPath(row: cellInUse, section: 0)) as? AnswerDetailTableViewCell {
            cell.audioSlider?.value = Float(audioPlayer.currentTime)
            cell.audioTimeLabel?.text = TimeManager.shared.timeString(time: audioPlayer.currentTime)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let cell = tableView.cellForRow(at: IndexPath(row: cellInUse, section: 0)) as? AnswerDetailTableViewCell {
            cell.audioSlider?.value = 0
            cell.audioSlider?.isEnabled = false
            cell.audioTimeLabel?.text = "00:00"
        }
        audioPlayer.stop()
        audioPlayer = nil
        cellInUse = -1
        timer.invalidate()
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
        recordButton.layer.shadowColor = UIColor.shadowColor.cgColor
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
        skipLabel.font = UIFont.mr(size: 14)
        skipLabel.text = "Skip"
        skipLabel.textColor = UIColor.tftCoolGrey
        skipButton.addSubview(skipLabel)
        
        // clock icon and time label
        clockIcon.translatesAutoresizingMaskIntoConstraints = false
        clockIcon.image = #imageLiteral(resourceName: "clock")
        clockIcon.contentMode = .scaleAspectFit
        
        timeLabel.backgroundColor = UIColor.clear
        timeLabel.font = UIFont.mr(size: 12)
        timeLabel.textColor = UIColor.nonBodyTextColor
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = TimeManager.shared.timeString(time: TimeInterval(secs))
        
        // audioBarButton
        audioBarButton.translatesAutoresizingMaskIntoConstraints = false
        audioBarButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        audioBarButton.layer.shadowRadius = 4
        audioBarButton.layer.shadowColor = UIColor.shadowColor.cgColor
        audioBarButton.layer.shadowOpacity = 1
        audioBarButton.setImage(#imageLiteral(resourceName: "audio_bar"), for: .normal)
        audioBarButton.imageView?.contentMode = .scaleAspectFit
        audioTimeLabel.frame = CGRect(x: 38, y: 8.5, width: 41, height: 22)
        audioTimeLabel.textColor = UIColor.white
        audioTimeLabel.font = UIFont.mr(size: 12)
        audioBarButton.addSubview(audioTimeLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        audioBarButton.addGestureRecognizer(tap)
        
        // post button
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.layer.borderWidth = 1
        postButton.layer.borderColor = UIColor.brandColor.cgColor
        postButton.layer.cornerRadius = 29.9 / 2
        postButton.layer.masksToBounds = true
        postButton.setTitle("Post", for: .normal)
        postButton.titleLabel?.font = UIFont.mr(size: 14)
        postButton.setTitleColor(UIColor.brandColor, for: .normal)
        
        // reward image
        rewardImageView.translatesAutoresizingMaskIntoConstraints = false
        rewardImageView.contentMode = .scaleAspectFit
        rewardImageView.image = #imageLiteral(resourceName: "reward_image")
        
        // reward label 
        rewardLabel.translatesAutoresizingMaskIntoConstraints = false
        rewardLabel.textAlignment = .center
        rewardLabel.text = "Successfully posted! Check it again in \"Profile\""
        rewardLabel.font = UIFont.mr(size: 14)
        rewardLabel.textColor = UIColor.nonBodyTextColor
        rewardLabel.numberOfLines = 0
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
        
        // reward image constraints
        rewardImageView.widthAnchor.constraint(equalToConstant: 138).isActive = true
        rewardImageView.heightAnchor.constraint(equalToConstant: 138).isActive = true
        rewardImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        rewardImageView.topAnchor.constraint(equalTo: topicView.bottomAnchor, constant: 29).isActive = true
        
        // reward label constraints
        rewardLabel.widthAnchor.constraint(equalToConstant: 245).isActive = true
        rewardLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        rewardLabel.topAnchor.constraint(equalTo: rewardImageView.bottomAnchor, constant: 10).isActive = true
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
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
        } catch {
            
        }
    }
    
    func recordButtonClicked(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func skipButtonClicked(_ sender: UIButton) {
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayback)
            try recordingSession.setActive(false)
        } catch {
            
        }
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
        // TODO: post audio
        
        // Animation: reward image and reward label fade in
        postButton.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: nil)
        audioBarButton.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: { success in
            self.rewardImageView.fadeIn(withDuration: Duration.TopicDetailVC.View.rewardFadeInDuration, withCompletionBlock: nil)
            self.rewardLabel.fadeIn(withDuration: Duration.TopicDetailVC.View.rewardFadeInDuration, withCompletionBlock: { success in
                if success {
                    self.rewardImageView.fadeOut(withDuration: Duration.TopicDetailVC.View.rewardFadeOutDuration, withCompletionBlock: nil)
                    self.rewardLabel.fadeOut(withDuration: Duration.TopicDetailVC.View.rewardFadeOutDuration, withCompletionBlock: { success in
                        if success {
                            self.tableView.fadeIn(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration)
                        }
                    })
                }
            })
        })
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
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: audioFilename.path) {
            do {
                try fileManager.removeItem(at: audioFilename)
            } catch {
                
            }
        }
        
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
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayback)
            try recordingSession.setActive(false)
        } catch {
            
        }
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
                        print("couldn't load file :(")
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

// MARK: - UIScrollViewDelegate
extension TopicDetailViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0{
            // Hide
            navigationController?.setNavigationBarHidden(true, animated: true)
            topicView.cool()
        } else {
            
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y < 0 {
            // Un-Hide
            navigationController?.setNavigationBarHidden(false, animated: true)
            topicView.plain()
        } else {

        }
    }
}
