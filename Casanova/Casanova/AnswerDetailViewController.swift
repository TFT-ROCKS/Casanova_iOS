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
    var comments: [Comment]!
    
    var cellInUse = -1
    let cellVerticalSpace: CGFloat = 10.0
    let cellHorizontalSpace: CGFloat = 12.0
    
    // sub views
    let topicView: TopicHeaderView = TopicHeaderView(frame: .zero)
    let tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    
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
    
    init(withTopic topic: Topic, withAnswer answer: Answer) {
        self.topic = topic
        self.answer = answer
        self.comments = answer.comments
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()
        addConstraints()
        setTitle()
        
        // Other configs
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = UIColor.navTintColor
        
        view.backgroundColor = UIColor.bgdColor
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
    
    func setTitle() {
        let titleLabel = UILabel(frame: CGRect(x: 95, y: 11, width: 184, height: 22))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.text = "Answer"
        titleLabel.font = UIFont.mr(size: 17)
        titleLabel.textColor = UIColor.nonBodyTextColor
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
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
    }
    
    func addTopicViewConstraints() {
        topicView.topAnchor.constraint(equalTo: view.topAnchor, constant: 1).isActive = true
        topicView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topicView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
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
    }
    
    func registerCustomCell() {
        tableView.register(AnswerDetailTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerDefaultCell)
        tableView.register(AnswerDetailTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerWithoutAudioCell)
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: ReuseIDs.AnswerDetailVC.commentTableViewCell)
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
            label.font = UIFont.mr(size: 14)
            label.textColor = UIColor.nonBodyTextColor
            label.text = "Comments (\(comments.count))"
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
            
        } else { // Comments section
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.AnswerDetailVC.commentTableViewCell, for: indexPath) as! CommentTableViewCell
            cell.comment = comments[indexPath.row]
            
            return cell
            
        }
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
            
        } else if let cell = cell as? CommentTableViewCell {
            
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
    
    func likeButtonTapped(_ sender: UIButton) {
        let answerId = answer.id
        let topicId = topic.id
        let userId = Environment.shared.currentUser?.id
        LikeManager.shared.postLike(answerId: answerId, userId: userId, topicId: topicId, withCompletion: { (error, like) in
            if error == nil {
                self.answer.likes.append(like!)
            }
        })
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
        if let url = URL(string: answer.audioURL ?? "") {
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

// MARK: - UIScrollViewDelegate
extension AnswerDetailViewController: UIScrollViewDelegate {
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
