//
//  AnswerDetailViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/17/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import AVFoundation

class AnswerDetailViewController: UIViewController {
    
    // class vars
    var topic: Topic!
    var answer: Answer!
    var comments: [Comment]! {
        didSet {
            tableView.reloadData()
        }
    }
    
    var cellInUse = -1
    let cellVerticalSpace: CGFloat = 10.0
    let cellHorizontalSpace: CGFloat = 12.0
    
    // audio downloading flag
    var isDownloading: Bool = false
    
    // status bar
    var statusBarShouldBeHidden = false
    
    // sub views
    let topicView: TopicHeaderView = TopicHeaderView(frame: .zero)
    let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    let postTextView: PostTextView = PostTextView(frame: .zero)
    let toolBar: AnswerDetailToolBar = AnswerDetailToolBar(frame: .zero)
    let audioControlBar: AudioControlView = AudioControlView(frame: .zero)
    
    // bottom constraint
    var bottomConstraint: NSLayoutConstraint!
    
    var timer: Timer!
    var seconds: Int = 60
    let secs: Int = 60
    
    // record
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    // button
    lazy var cmtBtn: UIButton = {
        let minimumTappableHeight: CGFloat = 60
        let button = UIButton(frame: CGRect(x: self.view.bounds.width - minimumTappableHeight, y: self.view.center.y,
                                            width: minimumTappableHeight,
                                            height: minimumTappableHeight))
        button.layer.cornerRadius = minimumTappableHeight / 2
        button.layer.masksToBounds = true
        button.setBackgroundImage(#imageLiteral(resourceName: "comment_btn"), for: .normal)
        
        return button
    }()
    var center: CGPoint!
    let threshold: CGFloat = 20.0
    
    // init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(withTopic topic: Topic, withAnswer answer: Answer) {
        self.topic = topic
        self.answer = answer
        self.comments = answer.comments
        self.postTextView.answer = answer
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()
        addConstraints()
        setTitle(title: "答案详情")
        
        // Other configs
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = UIColor.navTintColor
        navigationController?.navigationBar.topItem?.title = " "
        
        view.backgroundColor = UIColor.bgdColor
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Hide the status bar
        statusBarShouldBeHidden = true
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarShouldBeHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
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
        
        // Remove Notifications
        NotificationCenter.default.removeObserver(self)
    }
    
    func layoutSubviews() {
        layoutTableView()
        layoutToolBar()
        layoutAudioControlBar()
        layoutTopicView()
        layoutPostTextView()
    }
    
    func addConstraints() {
        addTopicViewConstraints()
        addTableViewConstraints()
        addToolBarConstraints()
        addAudioControlBarConstraints()
        addPostTextViewConstraints()
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
extension AnswerDetailViewController: AnswerDetailToolBarDelegate {
    func layoutToolBar() {
        view.addSubview(toolBar)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        view.bringSubview(toFront: toolBar)
        configToolBar()
    }
    
    func configToolBar() {
        toolBar.delegate = self
        toolBar.isLike = Utils.doesCurrentUserLikeThisAnswer(answer)
    }
    
    func addToolBarConstraints() {
        toolBar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolBar.heightAnchor.constraint(equalToConstant: 54).isActive = true
    }
    
    // MARK: - AnswerDetailToolBarDelegate
    
    func questionButtonClickedOnToolBar() {
        if toolBar.isQuestion {
            showTopicView()
        } else {
            hideTopicView()
        }
    }
    
    func likeButtonClickedOnToolBar(_ sender: UIButton) {
        likeButtonTapped(sender)
    }
    
    func commentButtonClickedOnToolBar() {
        postTextView.fadeIn(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration)
        postTextView.textView.becomeFirstResponder()
    }
}

// MARK: - Audio Control Bar
extension AnswerDetailViewController: AudioControlViewDelegate {
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
extension AnswerDetailViewController {
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
        
        // Hide topic view
        topicView.isHidden = true
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

// MARK: - PostTextView
extension AnswerDetailViewController: PostTextViewDelegate {
    func layoutPostTextView() {
        view.addSubview(postTextView)
        postTextView.translatesAutoresizingMaskIntoConstraints = false
        view.bringSubview(toFront: postTextView)
        postTextView.delegate = self
        postTextView.isHidden = true
        
        view.addSubview(cmtBtn)
        cmtBtn.addTarget(self, action: #selector(cmtBtnDragged(control:event:)), for: .touchDragInside)
        cmtBtn.addTarget(self, action: #selector(cmtBtnDragged(control:event:)), for: [.touchDragExit, .touchDragOutside])
        cmtBtn.addTarget(self, action: #selector(cmtBtnTapped(_:)), for: .touchUpInside)
        cmtBtn.addTarget(self, action: #selector(cmtBtnTouchedDown(_:)), for: .touchDown)
        cmtBtn.isHidden = true
    }
    
    func cmtBtnDragged(control: UIControl, event: UIEvent) {
        if let center = event.allTouches?.first?.location(in: self.view) {
            control.center = center
        }
    }
    
    func cmtBtnTouchedDown(_ sender: UIButton) {
        // record cmtBtn pos
        center = cmtBtn.center
    }
    
    func distanceBetweenPoints(_ p1: CGPoint, p2: CGPoint) -> CGFloat {
        return sqrt((pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2)))
    }
    
    func cmtBtnTapped(_ sender: UIButton) {
        if distanceBetweenPoints(cmtBtn.center, p2: center) > threshold { return }
        cmtBtn.fadeOut(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration, withCompletionBlock: nil)
        postTextView.fadeIn(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration, withCompletionBlock: nil)
    }
    
    func addPostTextViewConstraints() {
        NSLayoutConstraint(item: postTextView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
        
        NSLayoutConstraint(item: postTextView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
        
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
        comments = answer.comments
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .bottom, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AnswerDetailViewController: UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
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
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
        tableView.estimatedSectionHeaderHeight = 40
        
        // tap gesture added to table view
        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(_:)))
        tgr.cancelsTouchesInView = false
        tgr.delegate = self
        self.tableView.addGestureRecognizer(tgr)
    }
    
    func registerCustomCell() {
        tableView.register(AnswerDetailTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerDefaultCell)
        tableView.register(AnswerDetailTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerWithoutAudioCell)
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: ReuseIDs.AnswerDetailVC.commentTableViewCell)
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: ReuseIDs.AnswerDetailVC.commentTableViewCellForCurrentUser)
        let loadMoreTableViewCell = UINib(nibName: ReuseIDs.HomeVC.View.loadMoreTableViewCell, bundle: nil)
        tableView.register(loadMoreTableViewCell, forCellReuseIdentifier: ReuseIDs.HomeVC.View.loadMoreTableViewCell)
    }
    
    func addTableViewConstraints() {
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 1).isActive = true
        tableView.bottomAnchor.constraint(equalTo: toolBar.topAnchor, constant: -5).isActive = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { // Answer section
            return 1
        } else { // Comments section
            return comments.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { // Answer section
            return nil
        } else { // Comments section
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 40))
            let label = UILabel(frame: CGRect(x: 24, y: 5, width: 130, height: 20))
            label.font = UIFont.pfr(size: 14)
            label.textColor = UIColor.nonBodyTextColor
            label.text = "评论 (\(comments.count))"
            headerView.addSubview(label)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { // Answer section
            
            var cell: AnswerDetailTableViewCell
            
            if answer.audioURL == nil {
                cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerWithoutAudioCell, for: indexPath) as! AnswerDetailTableViewCell
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerDefaultCell, for: indexPath) as! AnswerDetailTableViewCell
            }
            cell.mode = .full
            cell.answer = answer
            let img = Utils.doesCurrentUserLikeThisAnswer(answer) ? #imageLiteral(resourceName: "like_btn-fill") : #imageLiteral(resourceName: "like_btn")
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
            
        } else { // Comments section
            let comment = comments[indexPath.row]
            var cell: CommentTableViewCell? = nil
            if comment.user.id == Environment.shared.currentUser?.id {
                // current user's comment
                cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.AnswerDetailVC.commentTableViewCellForCurrentUser, for: indexPath) as? CommentTableViewCell
                cell?.delegate = self
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.AnswerDetailVC.commentTableViewCell, for: indexPath) as? CommentTableViewCell
            }
            cell!.comment = comment
            
            return cell!
        }
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
            
        } else if let cell = cell as? CommentTableViewCell {
            
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
    
    func likeButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
        let answerId = answer.id
        let topicId = topic.id
        let userId = Environment.shared.currentUser?.id
        if Utils.doesCurrentUserLikeThisAnswer(answer) {
            // un-like it
            let likeId = Utils.likeIdFromAnswer(answer)
            LikeManager.shared.deleteLike(likeId: likeId, answerId: answerId, userId: userId, topicId: topicId, withCompletion: { error in
                if error == nil {
                    self.answer.removeLike(withId: likeId!)
                    self.tableView.reloadData()
                    self.toolBar.isLike = false
                    
                }
                sender.isEnabled = true
            })
        } else {
            // like it
            LikeManager.shared.postLike(answerId: answerId, userId: userId, topicId: topicId, withCompletion: { (error, like) in
                if error == nil {
                    self.answer.likes.append(like!)
                    self.tableView.reloadData()
                    self.toolBar.isLike = true
                    
                }
                sender.isEnabled = true
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
        if let url = URL(string: answer.audioURL ?? "") {
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
        var downloadTask: URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { [weak self] (URL, response, error) -> Void in
            self?.play(url: URL!, sender: sender)
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
                self.audioControlBar.updateUI(withTag: self.cellInUse, answer: self.answer)
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
        
//        audioControlBar.audioBar.value = 0
//        audioControlBar.audioBar.isEnabled = false
//        audioControlBar.playTimeLabel.text = "00:00"
//        audioControlBar.audioButton.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
//        audioControlBar.isPlaying = false
        
        audioPlayer.stop()
        audioPlayer = nil
        cellInUse = -1
        timer.invalidate()
        tableView.reloadData()
        audioControlBar.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: nil)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AnswerDetailViewController: UIGestureRecognizerDelegate {
    
    func viewTapped(_ tgr: UITapGestureRecognizer) {
        self.view.endEditing(true)
        if postTextView.isHidden == false {
            postTextView.fadeOut(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension AnswerDetailViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0{
            // Hide
            hideTopicView()
            postTextView.fadeOut(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration, withCompletionBlock: nil)
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

// MARK: - CommentTableViewCellDelegate
extension AnswerDetailViewController: CommentTableViewCellDelegate {
    func menuButtonTappedOnCommentTableViewCell(_ sender: UIButton) {
        presentDeleteCommentAlertSheet(commentId: sender.tag)
    }
    
    // Delete comment alert sheet
    func presentDeleteCommentAlertSheet(commentId: Int) {
        let alert = UIAlertController(title: "", message: "删除评论", preferredStyle: .actionSheet)
        let confirm = UIAlertAction(title: "删除", style: .destructive, handler: { [unowned self] _ in
            CommentManager.shared.deleteComment(answerId: self.answer.id, commentId: commentId, withCompletion: { error in
                if error == nil {
                    // delete comment successfully
                    // remove comment from this answer locally
                    self.removeComment(commentId)
                }
            })
        })
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    // Remove local cached comments
    func removeComment(_ commentId: Int) {
        var index: Int? = nil
        for i in 0..<comments.count {
            if commentId == comments[i].id {
                index = i
            }
        }
        if index != nil {
            comments.remove(at: index!)
        }
    }
}
