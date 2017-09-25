//
//  UserAnswersViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 9/20/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import AVFoundation

class UserAnswersViewController: UIViewController {
    
    // class vars
    var answers: [Answer] = [] {
        didSet {
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
    let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    let audioControlBar: AudioControlView = AudioControlView(frame: .zero)
    
    var timer: Timer!
    
    // audio
    var audioPlayer: AVAudioPlayer!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()
        addConstraints()
        
        // Other configs
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = UIColor.navTintColor
        navigationController?.navigationBar.topItem?.title = " "
        
        view.backgroundColor = UIColor.bgdColor
        
        registerObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        fetchUserAnswers()
        setTitle(title: "我的回答")
        tableView.reloadData()
        if let answers = Environment.shared.answers {
            self.answers = answers
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
        layoutAudioControlBar()
    }
    
    func addConstraints() {
        addTableViewConstraints()
        addAudioControlBarConstraints()
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
//    func fetchUserAnswers() {
//        AnswerManager.shared.fetchUserAnswers(forUser: Environment.shared.currentUser!, withCompletion: { (error, answers) in
//            if error == nil {
//                // success
//                self.answers = answers!
//                self.tableView.reloadData()
//            }
//        })
//    }
    
    func setTitle(title: String) {
        let titleLabel = UILabel(frame: CGRect(x: 95, y: 11, width: 184, height: 22))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.text = title
        titleLabel.font = UIFont.pfr(size: 18)
        titleLabel.textColor = UIColor.nonBodyTextColor
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }
    
}

// MARK: - trashButtonTapped
extension UserAnswersViewController {
    func trashButtonTappedOnAnswerDetailTableViewCell(_ sender: UIButton) {
        presentDeleteAnswerAlertSheet(answerIdx: sender.tag)
    }
    
    // Delete answer alert sheet
    func presentDeleteAnswerAlertSheet(answerIdx: Int) {
        let answerId = answers[answerIdx].id
        let topicId = answers[answerIdx].topic?.id
        let alert = UIAlertController(title: "", message: "删除回答", preferredStyle: .actionSheet)
        let confirm = UIAlertAction(title: "删除", style: .destructive, handler: { [unowned self] _ in
            AnswerManager.shared.deleteAnswer(topicId: topicId, answerId: answerId, withCompletion: { error in
                self.answers.remove(at: answerIdx)
                Environment.shared.removeAnswer(answerId)
            })
        })
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Audio Control Bar
extension UserAnswersViewController: AudioControlViewDelegate {
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
        audioControlBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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

// MARK: - UITableViewDelegate, UITableViewDataSource
extension UserAnswersViewController: UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
    func layoutTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        configTableView()
        registerCustomCell()
    }
    
    func configTableView() {
        tableView.separatorStyle = .singleLineEtched
        tableView.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
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
        let topicBriefAppendTableViewCell = UINib(nibName: ReuseIDs.HomeVC.View.topicBriefTableViewCell, bundle: nil)
        tableView.register(topicBriefAppendTableViewCell, forCellReuseIdentifier: ReuseIDs.SavedVC.View.topicBriefAppendTableViewCell)
    }
    
    func addTableViewConstraints() {
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 1).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return answers.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let answer = answers[indexPath.section]
        if indexPath.row == 0 {
            var cell: AnswerDetailTableViewCell
            if answer.audioURL == nil {
                cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerWithoutAudioCell, for: indexPath) as! AnswerDetailTableViewCell
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerDefaultCell, for: indexPath) as! AnswerDetailTableViewCell
            }
            if answer.user.id == Environment.shared.currentUser?.id {
                cell.canBeDeleted = true
                cell.trashButton.tag = indexPath.section
                cell.trashButton.addTarget(self, action: #selector(self.trashButtonTappedOnAnswerDetailTableViewCell(_:)), for: .touchUpInside)
            }
            cell.isLikedCard = true
            cell.mode = .short
            cell.answer = answer
            let img = Utils.doesCurrentUserLikeThisAnswer(answer) ? #imageLiteral(resourceName: "like_btn-fill") : #imageLiteral(resourceName: "like_btn")
            cell.likeButton.tag = indexPath.section
            cell.likeButton.addTarget(self, action: #selector(self.likeButtonTapped(_:)), for: .touchUpInside)
            cell.likeButton.setImage(img, for: .normal)
            cell.audioButton?.tag = indexPath.section
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
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.SavedVC.View.topicBriefAppendTableViewCell, for: indexPath) as! TopicBriefTableViewCell
            cell.isLikedCard = true
            cell.topic = answer.topic
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // Visualize the margin surrounding the table view cell
            cell.contentView.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
            
            // remove small whiteRoundedView before adding new one
            cell.viewWithTag(100)?.removeFromSuperview()
            
            let whiteRoundedView : UIView = UIView(frame: CGRect(x: cellHorizontalSpace, y: 0, width: self.view.bounds.width - (2 * cellHorizontalSpace), height: cell.bounds.height))
            whiteRoundedView.tag = 100
            whiteRoundedView.layer.backgroundColor = UIColor.white.cgColor
            whiteRoundedView.layer.masksToBounds = false
            whiteRoundedView.layer.shadowColor = UIColor.shadowColor.cgColor
            whiteRoundedView.layer.shadowOffset = CGSize(width: 0, height: -1)
            whiteRoundedView.layer.shadowOpacity = 1
            
            cell.contentView.addSubview(whiteRoundedView)
            cell.contentView.sendSubview(toBack: whiteRoundedView)
        } else if indexPath.row == 1 {
            // Visualize the margin surrounding the table view cell
            cell.contentView.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
            
            // remove small whiteRoundedView before adding new one
            cell.viewWithTag(100)?.removeFromSuperview()
            
            let whiteRoundedView : UIView = UIView(frame: CGRect(x: cellHorizontalSpace, y: 0, width: self.view.bounds.width - (2 * cellHorizontalSpace), height: cell.bounds.height))
            whiteRoundedView.tag = 100
            whiteRoundedView.layer.backgroundColor = UIColor.white.cgColor
            whiteRoundedView.layer.masksToBounds = false
            whiteRoundedView.layer.shadowColor = UIColor.shadowColor.cgColor
            whiteRoundedView.layer.shadowOffset = CGSize(width: 0, height: 1)
            whiteRoundedView.layer.shadowOpacity = 1
            
            cell.contentView.addSubview(whiteRoundedView)
            cell.contentView.sendSubview(toBack: whiteRoundedView)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let answer = answers[indexPath.section]
        if indexPath.row == 0 {
            let vc = AnswerDetailViewController(withTopic: answer.topic!, withAnswer: answer)
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.row == 1 {
            let vc = TopicDetailViewController(withTopic: answer.topic!, withMode: .record)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func likeButtonTapped(_ sender: UIButton) {
        let answer = answers[sender.tag]
        let topicId = answer.topic!.id
        let userId = Environment.shared.currentUser?.id
        let answerId = answer.id
        if Utils.doesCurrentUserLikeThisAnswer(answer) {
            // un-like it
            let likeId = Utils.likeIdFromAnswer(answer)
            LikeManager.shared.deleteLike(likeId: likeId, answerId: answerId, userId: userId, topicId: topicId, withCompletion: { error in
                if error == nil {
                    answer.removeLike(withId: likeId!)
                    self.tableView.reloadData()
                }
            })
        } else {
            // like it
            LikeManager.shared.postLike(answerId: answerId, userId: userId, topicId: topicId, withCompletion: { (error, like) in
                if error == nil {
                    answer.likes.append(like!)
                    self.tableView.reloadData()
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
        if let url = URL(string: answers[sender.tag].audioURL ?? "") {
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
                self.audioControlBar.updateUI(withTag: self.cellInUse, answer: self.answers[self.cellInUse])
            }
            
            if audioControlBar.isHidden {
                audioControlBar.fadeIn(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration, withCompletionBlock: nil)
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
        audioControlBar.audioBar.value = 0
        audioControlBar.audioBar.isEnabled = false
        audioControlBar.playTimeLabel.text = "00:00"
        
        audioPlayer.stop()
        audioPlayer = nil
        cellInUse = -1
        timer.invalidate()
    }
}

// MARK: - UIScrollViewDelegate
extension UserAnswersViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0{
            // Hide
            
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

// MARK: - Notification
extension UserAnswersViewController {
    func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleUserInfoPrepared(_:)), name: Notifications.userInfoPreparedNotification, object: nil)
    }
    
    // MARK: - Observer Handlers
    func handleUserInfoPrepared(_ notification: Notification) {
        self.answers = Environment.shared.answers!
    }
}


