//
//  AnswerDetailViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/17/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import AVFoundation
import NVActivityIndicatorView
import Firebase

class AnswerDetailViewController: UIViewController {
    
    // class vars
    var topic: Topic!
    var answer: Answer!
    
    var comments: [Comment]! {
        didSet {
            tableView.reloadData()
        }
    }
    
    var cellInUse: IndexPath!
    let cellVerticalSpace: CGFloat = 10.0
    let cellHorizontalSpace: CGFloat = 12.0
    
    // audio downloading flag
    var isDownloading: Bool = false
    
    // U.S and U.K english flag
    var isUKAudioEnabled: Bool = false
    var audioChanged: Bool = false
    
    // sub views
    let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    let postTextView: PostTextView = PostTextView(frame: .zero)
    let audioControlBar: AudioControlView = AudioControlView(frame: .zero)
    let activityIndicatorView: NVActivityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .pacman, color: .brandColor)
    let commentButton: UIButton = UIButton(type: .custom)
    
    // bottom constraint
    var bottomConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    var topConstraint: NSLayoutConstraint!
    
    var timer: Timer!
    var seconds: Int = 60
    let secs: Int = 60
    
    // audio
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
        self.comments = []
        self.postTextView.answer = answer
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()
        addConstraints()
        setTitle(title: "答案详情")
        setButtons()
        preDefinePlatforms()
        fetchComments()
        
        // Other configs
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = UIColor.navTintColor
        navigationController?.navigationBar.topItem?.title = " "
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = UIColor.bgdColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        Analytics.setScreenName("answer/\(answer.id)", screenClass: nil)
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
        layoutAudioControlBar()
        layoutPostTextView()
        layoutCommentButton()
    }
    
    func addConstraints() {
        addTableViewConstraints()
        addAudioControlBarConstraints()
        addPostTextViewConstraints()
        addCommentButtonConstraints()
    }
    
    func setTitle(title: String) {
        let titleLabel = UILabel(frame: CGRect(x: 95, y: 10, width: 184, height: 25))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.text = title
        titleLabel.font = UIFont.pfr(size: 18)
        titleLabel.textColor = UIColor.nonBodyTextColor
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
    
    func setButtons() {
        let shareButton = UIBarButtonItem(image: #imageLiteral(resourceName: "share"), style: .plain, target: self, action: #selector(shareButtonClicked(_:)))
        self.navigationItem.rightBarButtonItem = shareButton
    }
    
    // Fetch comments
    func fetchComments() {
        CommentAPIService.shared.fetchComments(num: 1000, offset: 0, answerID: answer.id) { (error, comments) in
            if error == nil {
                self.comments = comments!
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - Comment Button
extension AnswerDetailViewController {
    func layoutCommentButton() {
        view.addSubview(commentButton)
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        view.bringSubview(toFront: commentButton)
        configCommentButton()
    }
    
    func configCommentButton() {
        commentButton.setImage(UIImage.oriImage(named: "icon-comment"), for: .normal)
        
        commentButton.layer.cornerRadius = 28.0
        commentButton.layer.backgroundColor = UIColor.brandColor.cgColor
        commentButton.layer.shadowColor = UIColor.shadowColor.cgColor
        commentButton.layer.shadowOpacity = 1.0
        commentButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        commentButton.layer.shadowRadius = 6.0
        commentButton.layer.masksToBounds = false
        
        commentButton.addTarget(self, action: #selector(didTapCommentButton(_:)), for: .touchUpInside)
    }
    
    func addCommentButtonConstraints() {
        commentButton.widthAnchor.constraint(equalToConstant: 56.0).isActive = true
        commentButton.heightAnchor.constraint(equalToConstant: 56.0).isActive = true
        commentButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32.0).isActive = true
        commentButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -82.0).isActive = true
    }
    
    func didTapCommentButton(_ sender: UIButton) {
        postTextView.fadeIn(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration)
        postTextView.textView.becomeFirstResponder()
    }
}

// MARK: - Comment Audio Record View Controller
extension AnswerDetailViewController: AudioRecordViewControllerDelegate {
    func presentCommentRecordViewController() {
        let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: StoryboadIDs.audioRecordViewController) as! AudioRecordViewController
        vc.answer = answer
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
//    func reloadTableView() {
//        fetchComments()
//    }
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
        audioControlBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        audioControlBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        audioControlBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
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
    
    func slowDownButtonTappedOnBar() {
        if !audioControlBar.isPlaying { return; }
        if audioPlayer.rate > 0.599999 {
            audioPlayer.rate -= 0.1
            audioControlBar.updateSpeedLabel(withSpeed: audioPlayer.rate)
        }
    }
    
    func speedUpButtonTappedOnBar() {
        if !audioControlBar.isPlaying { return; }
        if audioPlayer.rate < 1.900001 {
            audioPlayer.rate += 0.1
            audioControlBar.updateSpeedLabel(withSpeed: audioPlayer.rate)
        }
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
        
        heightConstraint = NSLayoutConstraint(item: postTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 115)
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
        fetchComments()
    }
    
    func toggleButtonTapped(_ sender: UIButton) {
        if postTextView.isExpanded {
            // collapse
            topConstraint.isActive = false
            heightConstraint.isActive = true
        } else {
            // expand
            topConstraint.isActive = true
            heightConstraint.isActive = false
        }
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveLinear,
                       animations: { self.view.layoutIfNeeded() },
                       completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AnswerDetailViewController: UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate {
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
        tableView.register(AnswerNoteTableViewCell.self, forCellReuseIdentifier: ReuseIDs.AnswerDetailVC.answerNoteTableViewCell)
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: ReuseIDs.AnswerDetailVC.commentTableViewCell)
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: ReuseIDs.AnswerDetailVC.commentTableViewCellForCurrentUser)
        let loadMoreTableViewCell = UINib(nibName: ReuseIDs.HomeVC.View.loadMoreTableViewCell, bundle: nil)
        tableView.register(loadMoreTableViewCell, forCellReuseIdentifier: ReuseIDs.HomeVC.View.loadMoreTableViewCell)
    }
    
    func addTableViewConstraints() {
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        
        activityIndicatorView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalTo: activityIndicatorView.widthAnchor).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { // Answer section
            return answer.noteURL == nil ? 1 : 2
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
            if indexPath.row == 0 {
                var cell: AnswerDetailTableViewCell
                if answer.usAudio == nil {
                    cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerWithoutAudioCell, for: indexPath) as! AnswerDetailTableViewCell
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerDefaultCell, for: indexPath) as! AnswerDetailTableViewCell
                }
                cell.mode = .full
                cell.canAudioToggle = answer.ukAudio != nil
                cell.answer = answer
                cell.audioToggle.addTarget(self, action: #selector(self.audioToggleValueChanged(_:)), for: .valueChanged)
                let img = Utils.doesCurrentUserLikeThisAnswer(answer) ? #imageLiteral(resourceName: "like_btn-fill") : #imageLiteral(resourceName: "like_btn")
                cell.likeButton.addTarget(self, action: #selector(self.likeButtonTapped(_:)), for: .touchUpInside)
                cell.likeButton.setImage(img, for: .normal)
                cell.audioButton?.isEnabled = true
                cell.audioButton?.addTarget(self, action: #selector(self.audioButtonTapped(_:)), for: .touchUpInside)
                if audioPlayer != nil && audioControlBar.isPlaying {
                    if cellInUse == IndexPath(row: 0, section: 0) {
                        cell.audioButton?.setImage(#imageLiteral(resourceName: "pause_btn-h"), for: .normal)
                    } else {
                        cell.audioButton?.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
                    }
                } else {
                    cell.audioButton?.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
                }
                
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.AnswerDetailVC.answerNoteTableViewCell, for: indexPath) as! AnswerNoteTableViewCell
                cell.answer = answer
                cell.noteAudioButton.isEnabled = true
                cell.noteAudioButton.addTarget(self, action: #selector(self.audioButtonTapped(_:)), for: .touchUpInside)
                if audioPlayer != nil && audioControlBar.isPlaying {
                    if cellInUse == IndexPath(row: 1, section: 0) {
                        cell.noteAudioButton.setImage(#imageLiteral(resourceName: "pause_btn-h"), for: .normal)
                    } else {
                        cell.noteAudioButton.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
                    }
                } else {
                    cell.noteAudioButton.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
                }
                
                return cell
            } else {
                return UITableViewCell()
            }
        } else { // Comments section
            let comment = comments[indexPath.row]
            var cell: CommentTableViewCell
            if comment.userID == Environment.shared.currentUser?.id {
                // current user's comment
                cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.AnswerDetailVC.commentTableViewCellForCurrentUser, for: indexPath) as! CommentTableViewCell
                cell.delegate = self
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.AnswerDetailVC.commentTableViewCell, for: indexPath) as! CommentTableViewCell
            }
            cell.comment = comment
            cell.audioButton?.isEnabled = true
            cell.audioButton?.addTarget(self, action: #selector(self.audioButtonTapped(_:)), for: .touchUpInside)
            if audioPlayer != nil && audioControlBar.isPlaying {
                if cellInUse == IndexPath(row: indexPath.row, section: 1) {
                    cell.audioButton?.setImage(#imageLiteral(resourceName: "pause_btn-h"), for: .normal)
                } else {
                    cell.audioButton?.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
                }
            } else {
                cell.audioButton?.setImage(#imageLiteral(resourceName: "play_btn-h"), for: .normal)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let cell = cell as? LoadMoreTableViewCell {
            
            // Visualize the margin surrounding the table view cell
            cell.contentView.backgroundColor = UIColor.clear
            cell.backgroundColor = UIColor.clear
        } else {
            
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
        }
    }
    
    func audioToggleValueChanged(_ sender: JTMaterialSwitch) {
        isUKAudioEnabled = sender.isOn
        audioChanged = true
        if audioControlBar.isPlaying {
            audioButtonTappedOnBar()
            audioControlBar.reset()
        }
    }
    
    func likeButtonTapped(_ sender: UIButton) {
        sender.isEnabled = false
        let answerId = answer.id
        let userId = Environment.shared.currentUser?.id
        
        // like it
        LikeAPIService.shared.postLike(answerId: answerId, userId: userId) { (error, insertId) in
            if error == nil {
                self.answer.likesNum += 1
                // Update
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
            sender.isEnabled = true
        }
    }
    
    func audioButtonTapped(_ sender: UIButton) {
        let touchPoint = sender.convert(CGPoint.zero, to: tableView)
        let indexPath = tableView.indexPathForRow(at: touchPoint)
        
        if isDownloading { return }
        
        if cellInUse == indexPath && !audioChanged {
            let img = audioControlBar.isPlaying ? #imageLiteral(resourceName: "play_btn-h") : #imageLiteral(resourceName: "pause_btn-h")
            sender.setImage(img, for: .normal)
            audioButtonTappedOnBar()
            return
        }
        if cellInUse != nil {
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
        var url: URL?
        var isComment: Bool = false
        if indexPath?.section == 0 {
            if indexPath?.row == 0 {
                audioChanged = false
                // answer audio
                url = isUKAudioEnabled ? URL(string: answer.ukAudio ?? "") : URL(string: answer.usAudio ?? "")
            } else if indexPath?.row == 1 {
                // note audio
                url = URL(string: answer.noteURL ?? "")
            }
        } else if indexPath?.section == 1 {
            url = URL(string: comments[(indexPath?.row)!].audioURL ?? "")
            isComment = true
        }
        if let url = url {
            cellInUse = indexPath
            sender.isEnabled = false
            if isComment {
                downloadFileFromURL(url, sender: sender, comment: comments[(indexPath?.row)!])
            } else {
                downloadFileFromURL(url, sender: sender, comment: nil)
            }
        }
    }
    
    func downloadFileFromURL(_ url: URL, sender: UIButton, comment: Comment?) {
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
            self?.play(url: URL!, sender: sender, comment: comment)
        })
        downloadTask.resume()
    }
    
    func play(url: URL, sender: UIButton, comment: Comment?) {
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            audioPlayer.enableRate = true
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
                self.audioControlBar.updateUI(withIndexPath: self.cellInUse, answer: self.answer, comment: comment)
                
                if self.audioControlBar.isHidden {
                    self.audioControlBar.fadeIn(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration, withCompletionBlock: nil)
                }
                
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
        if audioPlayer != nil {
            audioPlayer.stop()
            audioPlayer = nil
        }
        cellInUse = nil
        if timer != nil {
            timer.invalidate()
        }
        tableView.reloadData()
        audioControlBar.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: nil)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AnswerDetailViewController: UIGestureRecognizerDelegate {
    func viewTapped(_ tgr: UITapGestureRecognizer) {
        self.view.endEditing(true)
        postTextView.fadeOut(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration)
    }
}

// MARK: - UIScrollViewDelegate
extension AnswerDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
        postTextView.fadeOut(withDuration: Duration.AnswerDetailVC.fadeInOrOutDuration)
    }
}

// MARK: - CommentTableViewCellDelegate
extension AnswerDetailViewController: CommentTableViewCellDelegate {
    func menuButtonTappedOnCommentTableViewCell(_ sender: UIButton) {
        presentDeleteCommentAlertSheet(commentId: sender.tag)
    }
    
    // Delete answer alert sheet
    func presentDeleteCommentAlertSheet(commentId: Int) {
        let alertController = AlertManager.alertController(title: "", msg: "删除评论", style: .actionSheet, actionT1: "删除", style1: .destructive, handler1: { [unowned self] _ in
            self.activityIndicatorView.startAnimating()
            CommentAPIService.shared.deleteComment(commentId: commentId, withCompletion: { error in
                Utils.runOnMainThread {
                    self.activityIndicatorView.stopAnimating()
                }
                if error == nil {
                    self.fetchComments()
                }
            })
            }, actionT2: "取消", style2: .default, handler2: nil, viewForPopover: self.view)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension AnswerDetailViewController {
    func preDefinePlatforms() {
        UMSocialUIManager.setPreDefinePlatforms(
            [NSNumber(integerLiteral:UMSocialPlatformType.wechatSession.rawValue),
             NSNumber(integerLiteral:UMSocialPlatformType.wechatTimeLine.rawValue),
             NSNumber(integerLiteral:UMSocialPlatformType.wechatFavorite.rawValue),
             NSNumber(integerLiteral:UMSocialPlatformType.sms.rawValue),
             NSNumber(integerLiteral:UMSocialPlatformType.email.rawValue)]
        )
    }
    
    func shareButtonClicked(_ sender: UIBarButtonItem) {
        UMSocialSwiftInterface.showShareMenuViewInWindowWithPlatformSelectionBlock(selectionBlock: {(platformType, userinfo) in
            var entity: GeneralShareEntity!
            switch platformType {
            case .wechatTimeLine:
                entity = AnswerToWeChatTimeLineEntity(topic: self.topic, answer: self.answer)
            case .wechatSession, .wechatFavorite, .sms, .email:
                entity = AnswerToWeChatSessionEntity(topic: self.topic, answer: self.answer)
            default:
                break
            }
            self.shareWebPage(withPlatformType: platformType, withEntity: entity)
        })
    }
    
    // Share webpage
    func shareWebPage(withPlatformType platformType: UMSocialPlatformType, withEntity entity: GeneralShareEntity) {
        let messageObject = UMSocialMessageObject()
        var shareObject: UMShareWebpageObject!
        if entity.isKind(of: AnswerToWeChatSessionEntity.self) {
            let entity = entity as! AnswerToWeChatSessionEntity
            shareObject = UMShareWebpageObject.shareObject(withTitle: entity.title, descr: entity.desc, thumImage: entity.image)
            shareObject?.webpageUrl = entity.webpageUrl
        } else if entity.isKind(of: AnswerToWeChatTimeLineEntity.self) {
            let entity = entity as! AnswerToWeChatTimeLineEntity
            shareObject = UMShareWebpageObject.shareObject(withTitle: entity.title, descr: entity.desc, thumImage: entity.image)
            shareObject?.webpageUrl = entity.webpageUrl
        }
        messageObject.shareObject = shareObject
        UMSocialSwiftInterface.share(plattype: platformType, messageObject: messageObject, viewController: self, completion: {(resp, error) in
            if error != nil {
                // uncomment below if need alert for debug
                // self.showAlert(withError: error!)
            }
        })
    }
    
    func showAlert(withError error: Error) {
        let alertController = UIAlertController(title: "Error Found", message: "error: \(error.localizedDescription)", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(ok)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
}
