//
//  TopicDetailViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/31/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView

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
    var answers: [Answer]? {
        didSet {
            activityIndicatorView.stopAnimating()
            tableView.reloadData()
        }
    }
    var cellInUse = -1
    let cellVerticalSpace: CGFloat = 10.0
    let cellHorizontalSpace: CGFloat = 12.0
    
    // audio task
    var isDownloading: Bool = false
    var downloadTask: URLSessionDownloadTask!
    
    // status bar
    var statusBarShouldBeHidden = false
    
    // sub views
    let topicView: TopicHeaderView = TopicHeaderView(frame: .zero)
    let tableView: UITableView = UITableView(frame: .zero)
    let toolBar: TopicDetailToolBar = TopicDetailToolBar(frame: .zero)
    let audioControlBar: AudioControlView = AudioControlView(frame: .zero)
    
    let activityIndicatorView: NVActivityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .pacman, color: .brandColor)
    var needsToShowIndicatorView: Bool {
        get {
           return answers == nil || answers!.count == 0
        }
    }
    let recordButton: UIButton = UIButton(frame: .zero)
    let speakingImgView: UIImageView = UIImageView(frame: .zero)
    let skipButton: UIButton = UIButton(frame: .zero)
    let clockIcon: UIImageView = UIImageView(frame: .zero)
    let timeLabel: UILabel = UILabel(frame: .zero)
    
    let audioBarButton: UIButton = UIButton(frame: .zero)
    let audioTimeLabel: UILabel = UILabel(frame: .zero)
    let postButton: UIButton = UIButton(frame: .zero)
    let progressView: UIProgressView = UIProgressView(frame: .zero)
    
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
        setTitle(title: "问题")
        
        // Other configs
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = UIColor.navTintColor
        navigationController?.navigationBar.topItem?.title = " "
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
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
        if downloadTask != nil {
            downloadTask.cancel()
        }
        isDownloading = false
        cellInUse = -1
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
        layoutTableView()
        layoutToolBar()
        layoutAudioControlBar()
        layoutTopicView()
    }
    
    func addConstraints() {
        addTopicViewConstraints()
        addTableViewConstraints()
        addToolBarConstraints()
        addAudioControlBarConstraints()
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
            }
        })
    }
    
    func setTitle(title: String) {
        let titleLabel = UILabel(frame: CGRect(x: 95, y: 11, width: 184, height: 22))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.text = title
        titleLabel.font = UIFont.pfr(size: 17)
        titleLabel.textColor = UIColor.nonBodyTextColor
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
}

// MARK: - Tool Bar
extension TopicDetailViewController: TopicDetailToolBarDelegate {
    func layoutToolBar() {
        view.addSubview(toolBar)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        view.bringSubview(toFront: toolBar)
        configToolBar()
    }
    
    func configToolBar() {
        toolBar.delegate = self
        toolBar.isHidden = true
    }
    
    func addToolBarConstraints() {
        toolBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolBar.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
    // MARK: - TopicDetailToolBarDelegate
    
    func questionButtonClickedOnToolBar() {
        if toolBar.isQuestion {
            showTopicView()
        } else {
            hideTopicView()
        }
    }
    
    func saveButtonClickedOnToolBar() {
        
    }
    
    func answerButtonClickedOnToolBar() {
        if audioPlayer != nil {
            audioPlayer.stop()
            audioPlayer = nil
        }
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        showTopicView()
        audioControlBar.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration)
        tableView.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration)
        toolBar.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration)
        initRecordViews()
    }
}

// MARK: - Audio Control Bar
extension TopicDetailViewController: AudioControlViewDelegate {
    func layoutAudioControlBar() {
        view.addSubview(audioControlBar)
        audioControlBar.translatesAutoresizingMaskIntoConstraints = false
        view.bringSubview(toFront: audioControlBar)
        configAudioControlBar()
    }
    
    func configAudioControlBar() {
        audioControlBar.isHidden = true
        audioControlBar.delegate = self
        audioControlBar.audioBar.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
    }
    
    func addAudioControlBarConstraints() {
        audioControlBar.bottomAnchor.constraint(equalTo: toolBar.topAnchor).isActive = true
        audioControlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        audioControlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        audioControlBar.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
    // MARK: - AudioControlViewDelegate
    
    func audioButtonTappedOnBar() {
        if audioControlBar.isPlaying {
            // pause -> ready to play
            audioControlBar.isPlaying = false
            audioControlBar.audioButton.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
            if audioPlayer != nil {
                audioPlayer.pause()
            }
            if timer != nil {
                timer.invalidate()
            }
        } else {
            // play -> ready to pause
            audioControlBar.isPlaying = true
            audioControlBar.audioButton.setImage(#imageLiteral(resourceName: "pause_btn-h"), for: .normal)
            if audioPlayer != nil {
                audioPlayer.play()
            }
            Utils.runOnMainThread {
                self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime(_:)), userInfo: nil, repeats: true)
            }
        }
        tableView.reloadData()
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
    
    func hideTopicView() {
        if topicView.isHidden == true { return }
        toolBar.isQuestion = false
        topicView.fadeOut(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration, withCompletionBlock: nil)
    }
    
    func showTopicView() {
        if topicView.isHidden == false { return }
        toolBar.isQuestion = true
        topicView.fadeIn(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration, withCompletionBlock: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TopicDetailViewController: UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    func layoutTableView() {
        view.addSubview(tableView)
        view.addSubview(activityIndicatorView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
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
        tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 1).isActive = true
        tableView.bottomAnchor.constraint(equalTo: toolBar.topAnchor, constant: -5).isActive = true
        
        activityIndicatorView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalTo: activityIndicatorView.widthAnchor).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
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
            let img = Utils.doesCurrentUserLikeThisAnswer(answer) ? #imageLiteral(resourceName: "like_btn-fill") : #imageLiteral(resourceName: "like_btn")
            cell.likeButton.tag = indexPath.row
            cell.likeButton.addTarget(self, action: #selector(self.likeButtonTapped(_:)), for: .touchUpInside)
            cell.likeButton.setImage(img, for: .normal)
            cell.audioButton?.tag = indexPath.row
            cell.audioButton?.isEnabled = true
            cell.audioButton?.addTarget(self, action: #selector(self.audioButtonTapped(_:)), for: .touchUpInside)
            if indexPath.row != cellInUse {
                cell.audioButton?.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
            } else {
                if audioPlayer != nil && audioControlBar.isPlaying {
                    cell.audioButton?.setImage(#imageLiteral(resourceName: "pause_btn-h"), for: .normal)
                } else {
                    cell.audioButton?.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
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
            cell.viewWithTag(100)?.removeFromSuperview()
            
            let whiteRoundedView : UIView = UIView(frame: CGRect(x: cellHorizontalSpace, y: cellVerticalSpace / 2, width: self.view.bounds.width - (2 * cellHorizontalSpace), height: cell.bounds.height - cellVerticalSpace / 2))
            whiteRoundedView.tag = 100
            whiteRoundedView.layer.cornerRadius = 5.0
            whiteRoundedView.layer.backgroundColor = UIColor.white.cgColor
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
    
    func likeButtonTapped(_ sender: UIButton) {
        let topicId = topic.id
        let userId = Environment.shared.currentUser?.id
        let answer = answers?[sender.tag]
        let answerId = answer?.id
        if Utils.doesCurrentUserLikeThisAnswer(answer!) {
            // un-like it
            let likeId = Utils.likeIdFromAnswer(answer!)
            LikeManager.shared.deleteLike(likeId: likeId, answerId: answerId, userId: userId, topicId: topicId, withCompletion: { error in
                if error == nil {
                    answer?.removeLike(withId: likeId!)
                    self.tableView.reloadData()
                }
            })
        } else {
            // like it
            LikeManager.shared.postLike(answerId: answerId, userId: userId, topicId: topicId, withCompletion: { (error, like) in
                if error == nil {
                    if let answers = self.answers {
                        let answer = answers[sender.tag]
                        answer.likes.append(like!)
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    func audioButtonTapped(_ sender: UIButton) {
        if isDownloading { return }
        
        if cellInUse == sender.tag {
            let img = audioControlBar.isPlaying ? #imageLiteral(resourceName: "play_btn-h") : #imageLiteral(resourceName: "pause_btn-h")
            sender.setImage(img, for: .normal)
            audioButtonTappedOnBar()
            return
        }
        if cellInUse != -1 {
            // reset previous cell in use
            
            if audioPlayer != nil {
                audioPlayer.stop()
                audioPlayer = nil
            }
            if timer != nil {
                timer.invalidate()
                timer = nil
            }
            
        }
        if let url = URL(string: answers![sender.tag].audioURL ?? "") {
            cellInUse = sender.tag
            sender.isEnabled = false
            downloadFileFromURL(url, sender: sender)
        }
    }
    
    func downloadFileFromURL(_ url: URL, sender: UIButton) {
        isDownloading = true
        // activity indicator
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicatorView.tag = 5
        indicatorView.frame = sender.bounds
        sender.addSubview(indicatorView)
        indicatorView.startAnimating()
        // end of activity indicator
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { [unowned self] (URL, response, error) -> Void in
            if error == nil {
                self.play(url: URL!, sender: sender)
            }
        })
        downloadTask.resume()
    }
    
    func play(url: URL, sender: UIButton) {
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            audioPlayer.play()
            
            isDownloading = false
            
            Utils.runOnMainThread {
                // remove indicator view
                if let indicatorView = sender.viewWithTag(5) as? UIActivityIndicatorView {
                    indicatorView.stopAnimating()
                    indicatorView.removeFromSuperview()
                }
                
                self.tableView.reloadData()
                
                sender.isEnabled = true
                sender.setImage(#imageLiteral(resourceName: "pause_btn-h"), for: .normal)
                
                self.audioControlBar.audioBar.maximumValue = Float(self.audioPlayer.duration)
                self.audioControlBar.audioBar.value = 0.0
                self.audioControlBar.playTimeLabel.text = "00:00"
                self.audioControlBar.audioBar.isEnabled = true
                self.audioControlBar.updateUI(withTag: self.cellInUse, answer: self.answers![self.cellInUse])
                
                if self.audioControlBar.isHidden {
                    self.audioControlBar.fadeIn(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration, withCompletionBlock: nil)
                }
            }
            
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
    
    func sliderValueChanged(_ sender: UISlider) {
        if audioPlayer != nil {
            audioPlayer.currentTime = TimeInterval(sender.value)
            audioControlBar.playTimeLabel.text = TimeManager.shared.timeString(time: audioPlayer.currentTime)
        }
    }
    
    func updateTime(_ timer: Timer) {
        
        audioControlBar.audioBar.value = Float(audioPlayer.currentTime)
        audioControlBar.playTimeLabel.text = TimeManager.shared.timeString(time: audioPlayer.currentTime)
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer.stop()
        audioPlayer = nil
        cellInUse = -1
        timer.invalidate()
        tableView.reloadData()
        audioControlBar.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: nil)
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
        view.addSubview(progressView)
        view.addSubview(postButton)
        view.addSubview(rewardLabel)
        view.addSubview(rewardImageView)
        
        view.bringSubview(toFront: recordButton)
        view.bringSubview(toFront: skipButton)
        view.bringSubview(toFront: clockIcon)
        view.bringSubview(toFront: timeLabel)
        view.bringSubview(toFront: audioBarButton)
        view.bringSubview(toFront: progressView)
        view.bringSubview(toFront: postButton)
        view.bringSubview(toFront: rewardLabel)
        view.bringSubview(toFront: rewardImageView)
        
        configRecordViews()
        initRecordViews()
        registerButtons()
    }
    
    func configRecordViews() {
        // config buttons
        recordButton.layer.borderColor = UIColor.tftSkyBlue.cgColor
        recordButton.layer.borderWidth = 2.0
        recordButton.layer.cornerRadius = 85.0 / 2
        recordButton.layer.masksToBounds = true
        recordButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        recordButton.layer.shadowRadius = 4
        recordButton.layer.shadowColor = UIColor.shadowColor.cgColor
        recordButton.layer.shadowOpacity = 1
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        
        skipButton.layer.borderColor = UIColor.tftCoolGrey.cgColor
        skipButton.layer.borderWidth = 2.0
        skipButton.layer.cornerRadius = 35.0 / 2
        skipButton.layer.masksToBounds = true
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        
        // buttons' sub views
        speakingImgView.frame = CGRect(x: 31.1, y: 27.2, width: 22.9, height: 30.6)
        speakingImgView.image = #imageLiteral(resourceName: "speaking-h")
        recordButton.addSubview(speakingImgView)
        
        let skipLabel = UILabel(frame: CGRect(x: 15.0, y: 5.5, width: 50, height: 24))
        skipLabel.textAlignment = .center
        skipLabel.font = UIFont.pfl(size: 17)
        skipLabel.text = "跳过"
        skipLabel.textColor = UIColor.tftCoolGrey
        skipButton.addSubview(skipLabel)
        
        // clock icon and time label
        clockIcon.translatesAutoresizingMaskIntoConstraints = false
        clockIcon.image = #imageLiteral(resourceName: "clock")
        clockIcon.contentMode = .scaleAspectFit
        
        timeLabel.backgroundColor = UIColor.clear
        timeLabel.font = UIFont.mr(size: 14)
        timeLabel.textColor = UIColor.nonBodyTextColor
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.text = TimeManager.shared.timeString(time: TimeInterval(secs))
        
        // audioBarButton
        audioBarButton.translatesAutoresizingMaskIntoConstraints = false
        audioBarButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        audioBarButton.layer.shadowRadius = 4
        audioBarButton.layer.shadowColor = UIColor.shadowColor.cgColor
        audioBarButton.layer.shadowOpacity = 1
        audioBarButton.setImage(#imageLiteral(resourceName: "audio_bar_new"), for: .normal)
        audioBarButton.imageView?.contentMode = .scaleAspectFit
        audioTimeLabel.frame = CGRect(x: 60.5, y: 11.5, width: 59, height: 22)
        audioTimeLabel.textColor = UIColor.white
        audioTimeLabel.font = UIFont.mr(size: 16)
        audioTimeLabel.textAlignment = .center
        audioBarButton.addSubview(audioTimeLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap(_:)))
        audioBarButton.addGestureRecognizer(tap)
        
        // post button
        postButton.translatesAutoresizingMaskIntoConstraints = false
        postButton.layer.borderWidth = 2
        postButton.layer.borderColor = UIColor.tftSkyBlue.cgColor
        postButton.layer.cornerRadius = 35.0 / 2
        postButton.layer.masksToBounds = true
        postButton.setTitle("发布", for: .normal)
        postButton.titleLabel?.font = UIFont.pfl(size: 17)
        postButton.titleLabel?.textAlignment = .center
        postButton.setTitleColor(UIColor.tftSkyBlue, for: .normal)
        
        // progress view
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.layer.borderWidth = 3
        progressView.layer.borderColor = UIColor.progressBarColor.cgColor
        progressView.layer.cornerRadius = 39 / 2.0
        progressView.layer.masksToBounds = true
        progressView.progressTintColor = UIColor.progressBarColor
        progressView.trackTintColor = UIColor.clear
        
        // reward image
        rewardImageView.translatesAutoresizingMaskIntoConstraints = false
        rewardImageView.contentMode = .scaleToFill
        rewardImageView.image = #imageLiteral(resourceName: "check")
        
        // reward label
        rewardLabel.translatesAutoresizingMaskIntoConstraints = false
        rewardLabel.textAlignment = .center
        rewardLabel.text = "Successfully posted! Check it again in \"Profile\""
        rewardLabel.font = UIFont.mr(size: 17)
        rewardLabel.textColor = UIColor.nonBodyTextColor
        rewardLabel.numberOfLines = 0
    }
    
    func addRecordConstraints() {
        // record button constraints
        recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: 85).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 85).isActive = true
        recordButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -96).isActive = true
        
        // skip button constraints
        skipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        skipButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        skipButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        skipButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
        
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
        audioBarButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
        audioBarButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        audioBarButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -116).isActive = true
        audioBarButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // progressView constraints
        progressView.widthAnchor.constraint(equalTo: audioBarButton.widthAnchor).isActive = true
        progressView.heightAnchor.constraint(equalTo: audioBarButton.heightAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: audioBarButton.bottomAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: audioBarButton.leadingAnchor).isActive = true
        
        // post button constraints
        postButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        postButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        postButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
        postButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // reward image constraints
        rewardImageView.widthAnchor.constraint(equalToConstant: 37).isActive = true
        rewardImageView.heightAnchor.constraint(equalToConstant: 23.7).isActive = true
        rewardImageView.centerXAnchor.constraint(equalTo: audioBarButton.centerXAnchor).isActive = true
        rewardImageView.centerYAnchor.constraint(equalTo: audioBarButton.centerYAnchor).isActive = true
        
        // reward label constraints
        rewardLabel.widthAnchor.constraint(equalToConstant: 245).isActive = true
        rewardLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        rewardLabel.bottomAnchor.constraint(equalTo: audioBarButton.topAnchor, constant: -100).isActive = true
    }
    
    func initRecordViews() {
        recordButton.isHidden = false
        skipButton.isHidden = false
        recordButton.fadeIn()
        skipButton.fadeIn()
        
        clockIcon.isHidden = true
        timeLabel.isHidden = true
        audioBarButton.isHidden = true
        progressView.isHidden = true
        progressView.progress = 0.0
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
                        self.toolBar.fadeIn(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration)
                        self.hideTopicView()
                        self.setTitle(title: "优秀答案")
                        if self.needsToShowIndicatorView {
                            self.activityIndicatorView.startAnimating()
                        }
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
        if audioPlayer != nil {
            audioPlayer.stop()
        }
        if timer != nil {
            timer.invalidate()
        }
        if audioRecorder != nil {
            audioRecorder.stop()
        }
        self.seconds = self.secs
        animateAfterBeforeUploadAudio()
        let audioFile = self.getDocumentsDirectory().appendingPathComponent("\(self.topic.id)-speaking.wav")
        OSSManager.shared.uploadAudioFile(url: audioFile, withProgressBlock: { (bytesSent, totalByteSent, totalBytesExpectedToSend) in
            print(bytesSent, totalByteSent, totalBytesExpectedToSend)
            Utils.runOnMainThread {
                self.progressView.progress = Float(totalByteSent) / Float(totalBytesExpectedToSend)
            }
        }, withCompletionBlock: { (error, url) in
            if error == nil {
                print("upload audio success")
                // Upload answer
                AnswerManager.shared.postAnswer(topicId: self.topic.id, userId: Environment.shared.currentUser?.id, title: "", audioUrl: url!, ref: "", withCompletion: { (error, answer) in
                    if error == nil {
                        // success
                        self.answers?.append(answer!)
                        // animation
                        Utils.runOnMainThread {
                            self.animateAfterPostAnswer()
                        }
                    }
                })
            }
        })
    }
    
    func animateAfterBeforeUploadAudio() {
        self.postButton.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: nil)
        self.audioBarButton.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: { success in
            if success {
                self.progressView.fadeIn(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: nil)
            }
        })
    }
    
    func animateAfterPostAnswer() {
        // Animation: reward image and reward label fade in
        self.rewardImageView.fadeIn(withDuration: Duration.TopicDetailVC.View.rewardFadeInDuration, withCompletionBlock: nil)
        self.rewardLabel.fadeIn(withDuration: Duration.TopicDetailVC.View.rewardFadeInDuration, withCompletionBlock: { success in
            if success {
                self.progressView.fadeOut(withDuration: Duration.TopicDetailVC.View.rewardFadeOutDuration, withCompletionBlock: nil)
                self.rewardImageView.fadeOut(withDuration: Duration.TopicDetailVC.View.rewardFadeOutDuration, withCompletionBlock: nil)
                self.rewardLabel.fadeOut(withDuration: Duration.TopicDetailVC.View.rewardFadeOutDuration, withCompletionBlock: { success in
                    if success {
                        self.tableView.fadeIn(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration)
                        self.toolBar.fadeIn(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration)
                        self.hideTopicView()
                        self.setTitle(title: "优秀答案")
                        if self.needsToShowIndicatorView {
                            self.activityIndicatorView.startAnimating()
                        }
                    }
                })
            }
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
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(topic.id)-speaking.wav")
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: audioFilename.path) {
            do {
                try fileManager.removeItem(at: audioFilename)
            } catch {
                
            }
        }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
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
                    let audioFile = self.getDocumentsDirectory().appendingPathComponent("\(self.topic.id)-speaking.wav")
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
            hideTopicView()
        } else {
            
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y < 0 {
            // Un-Hide
            
        } else {
            
        }
    }
}
