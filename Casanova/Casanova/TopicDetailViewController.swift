//
//  TopicDetailViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/31/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase

class TopicDetailViewController: UIViewController {
    
    // MARK: - Private
    fileprivate var viewModel: TopicDetailViewControllerViewModel
    
    var noNeedToRecord: Bool = false
    var cellInUse = -1
    let cellVerticalSpace: CGFloat = 10.0
    let cellHorizontalSpace: CGFloat = 12.0
    
    // audio task
    var isDownloading: Bool = false
    var downloadTask: URLSessionDownloadTask!
    
    // sub views
    let tableView: UITableView = UITableView(frame: .zero)
    let audioControlBar: AudioControlView = AudioControlView(frame: .zero)
    let answerButton: UIButton = UIButton(type: .custom) // floating button
    
    // sub views - prepare to answer
    let answerButton1: UIButton = UIButton(type: .custom)
    let answerLabel1: UILabel = UILabel(frame: .zero)
    let answerLabel2: UILabel = UILabel(frame: .zero)
    let skipAnswerButton: UIButton = UIButton(type: .custom)
    
    // sub views - answer (record)
    let recordHintLabel: UILabel = UILabel(frame: .zero)
    let recordButton: UIButton = UIButton(frame: .zero)
    let speakingImgView: UIImageView = UIImageView(frame: .zero)
    let skipButton: UIButton = UIButton(frame: .zero)
    let clockIcon: UIImageView = UIImageView(frame: .zero)
    let timeLabel: UILabel = UILabel(frame: .zero)
    
    // sub views - answer (play & ready to post)
    let audioBarButton: UIButton = UIButton(frame: .zero)
    let audioTimeLabel: UILabel = UILabel(frame: .zero)
    let postButton: UIButton = UIButton(frame: .zero)
    let progressView: UIProgressView = UIProgressView(frame: .zero)
    
    // sub views - answer (posted)
    let rewardImageView: UIImageView = UIImageView(frame: .zero)
    let rewardLabel: UILabel = UILabel(frame: .zero)
    
    var timer: Timer!
    var seconds: Int = 60
    let secs: Int = 60
    
    // record
    var audioSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    // MARK: - Lifecycle
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: TopicDetailViewControllerViewModel) {
        self.viewModel = viewModel
        audioSession = AVAudioSession.sharedInstance()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()
        addConstraints()
        viewModel.cellViewModelsTypes.forEach { $0.registerCell(tableView: tableView) }
        
        // Other configs
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = UIColor.navTintColor
        navigationController?.navigationBar.topItem?.title = " "
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = UIColor.bgdColor
        
        setTitle(title: "优秀答案")
        showTopicOnly(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Analytics.setScreenName("topic/\(viewModel.topicHeaderTableViewCellViewModel.topic.id)", screenClass: nil)
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
        
        bindToViewModel()
        reloadData()
    }
    
    func layoutSubviews() {
        layoutTableView()
        layoutRecordViews()
        layoutAnswerButton()
    }
    
    func addConstraints() {
        addTableViewConstraints()
        addRecordConstraints()
        addPrepareToAnswerViewsConstraints()
        addAnswerButtonConstraints()
    }
    
    // MARK: - ViewModel
    fileprivate func bindToViewModel() {
        // bind once
        if self.viewModel.binded { return }
        // bind
        self.viewModel.didUpdate = { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModelDidUpdate()
        }
        self.viewModel.didError = { [weak self] (error) in
            guard let `self` = self else { return }
            self.viewModelDidError(error)
        }
        self.viewModel.didSelectAnswer = { [weak self] (topic, answer) in
            guard let `self` = self else { return }
            self.viewModelDidSelect(topic, answer: answer)
        }
        self.viewModel.didDeleteAnswer = { [weak self] (answer) in
            guard let `self` = self else { return }
            self.presentDeleteAnswerAlertSheet(answer: answer)
        }
        self.viewModel.didWannaAnswer = { [weak self] _ in
            guard let `self` = self else { return }
            self.viewModelDidWannaAnswer()
        }
        // set binded
        self.viewModel.binded = true
    }
    
    fileprivate func viewModelDidUpdate() {
        // activity indicator
        if viewModel.isUpdating {
        }
        else {
            tableView.reloadData()
        }
    }
    
    fileprivate func viewModelDidError(_ error: Error) {
        
    }
    
    fileprivate func viewModelDidSelect(_ topic: Topic, answer: Answer) {
        let vc = AnswerDetailViewController(withTopic: topic, withAnswer: answer)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func viewModelDidWannaAnswer() {
        if audioPlayer != nil {
            audioPlayer.stop()
            audioPlayer = nil
        }
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
        showTopicOnly(true)
        audioControlBar.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration)
        initRecordViews()
        hidePrepareToAnswerViews()
        setTitle(title: "问题")
        answerButton.fadeOut()
        
        // Click the record button
        didTapRecordButton(recordButton)
    }
    
    // MARK: - Actions
    fileprivate func reloadData() {
        self.viewModel.reloadData()
    }
    
    fileprivate func deleteAnswer(_ answer: Answer) {
        self.viewModel.deleteAnswer(answer)
    }
    
    fileprivate func addAnswer(_ answer: Answer) {
        self.viewModel.addAnswer(answer)
    }
    
    func setTitle(title: String) {
        let titleLabel = UILabel(frame: CGRect(x: 95, y: 10, width: 184, height: 25))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.text = title
        titleLabel.font = UIFont.pfr(size: 18)
        titleLabel.textColor = UIColor.nonBodyTextColor
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }
    
    func showTopicOnly(_ flag: Bool) {
        if flag {
            initPrepareToAnswerViews()
            hideRecordViews()
            answerButton.isHidden = true
        }
        viewModel.showTopicOnly = flag
        tableView.reloadData()
    }
}

// MARK: - Answer Button
extension TopicDetailViewController {
    func layoutAnswerButton() {
        view.addSubview(answerButton)
        answerButton.translatesAutoresizingMaskIntoConstraints = false
        view.bringSubview(toFront: answerButton)
        configAnswerButton()
    }
    
    func configAnswerButton() {
        answerButton.setImage(UIImage.oriImage(named: "icon-voice"), for: .normal)
        
        answerButton.layer.cornerRadius = 28.0
        answerButton.layer.backgroundColor = UIColor.brandColor.cgColor
        answerButton.layer.shadowColor = UIColor.shadowColor.cgColor
        answerButton.layer.shadowOpacity = 1.0
        answerButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        answerButton.layer.shadowRadius = 6.0
        answerButton.layer.masksToBounds = false
        
        answerButton.addTarget(self, action: #selector(didTapAnswerButton(_:)), for: .touchUpInside)
    }
    
    func addAnswerButtonConstraints() {
        answerButton.widthAnchor.constraint(equalToConstant: 56.0).isActive = true
        answerButton.heightAnchor.constraint(equalToConstant: 56.0).isActive = true
        answerButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32.0).isActive = true
        answerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -82.0).isActive = true
    }
    
    func didTapAnswerButton(_ sender: UIButton) {
        viewModelDidWannaAnswer()
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
    }
    
    func registerCustomCell() {
        
    }
    
    func addTableViewConstraints() {
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return viewModel.topicHeaderTableViewCellViewModel.dequeueCell(tableView: tableView, indexPath: indexPath)
        } else {
            return viewModel.answersTableViewCellModels[indexPath.section - 1].dequeueCell(tableView: tableView, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 12))
        return footer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section <= 0 {
            // topic header cell
        } else {
            viewModel.answersTableViewCellModels[indexPath.section - 1].cellSelected()
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - AnswerDetailTableViewCellDelegate
extension TopicDetailViewController {
    // Delete comment alert sheet
    func presentDeleteAnswerAlertSheet(answer: Answer) {
        let alertController = AlertManager.alertController(title: "", msg: "删除回答", style: .actionSheet, actionT1: "删除", style1: .destructive, handler1: { [unowned self] _ in
            self.deleteAnswer(answer)
            }, actionT2: "取消", style2: .default, handler2: nil, viewForPopover: self.view)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Record Button and Skip Buttons
extension TopicDetailViewController: AVAudioRecorderDelegate {
    
    func registerButtons() {
        answerButton1.addTarget(self, action: #selector(didTapAnswerButton(_:)), for: .touchUpInside)
        skipAnswerButton.addTarget(self, action: #selector(didTapSkipAnswerButton(_:)), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(didTapRecordButton(_:)), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(didTapSkipButton(_:)), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(didTapPostButton(_:)), for: .touchUpInside)
    }
    
    func layoutRecordViews() {
        view.addSubview(answerButton1)
        view.addSubview(answerLabel1)
        view.addSubview(answerLabel2)
        view.addSubview(skipAnswerButton)
        view.addSubview(recordHintLabel)
        view.addSubview(recordButton)
        view.addSubview(skipButton)
        view.addSubview(clockIcon)
        view.addSubview(timeLabel)
        view.addSubview(audioBarButton)
        view.addSubview(progressView)
        view.addSubview(postButton)
        view.addSubview(rewardLabel)
        view.addSubview(rewardImageView)
        
        view.bringSubview(toFront: answerButton1)
        view.bringSubview(toFront: answerLabel1)
        view.bringSubview(toFront: answerLabel2)
        view.bringSubview(toFront: skipAnswerButton)
        view.bringSubview(toFront: recordHintLabel)
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
        configPrepareToAnswerViews()
        registerButtons()
    }
    
    func configPrepareToAnswerViews() {
        answerButton1.setImage(UIImage.oriImage(named: "icon-voice"), for: .normal)
        answerButton1.layer.cornerRadius = 28.0
        answerButton1.layer.backgroundColor = UIColor.brandColor.cgColor
        answerButton1.layer.shadowColor = UIColor.shadowColor.cgColor
        answerButton1.layer.shadowOpacity = 1.0
        answerButton1.layer.shadowOffset = CGSize(width: 0, height: 6)
        answerButton1.layer.shadowRadius = 6.0
        answerButton1.layer.masksToBounds = false
        answerButton1.translatesAutoresizingMaskIntoConstraints = false
        
        answerLabel1.font = UIFont.pfr(size: 14)
        answerLabel1.textColor = UIColor.tftCoolGrey
        answerLabel1.text = "自己试着先说一下，会有老师讲评哦"
        answerLabel1.textAlignment = .center
        answerLabel1.translatesAutoresizingMaskIntoConstraints = false
        
        answerLabel2.font = UIFont.pfr(size: 14)
        answerLabel2.textColor = UIColor.tftCoolGrey
        answerLabel2.text = "懒孩子才会直接"
        answerLabel2.textAlignment = .center
        answerLabel2.translatesAutoresizingMaskIntoConstraints = false
        
        skipAnswerButton.titleLabel?.font = UIFont.pfr(size: 14)
        skipAnswerButton.setTitleColor(UIColor.brandColor, for: .normal)
        skipAnswerButton.setTitle("看答案", for: .normal)
        skipAnswerButton.contentHorizontalAlignment = .center
        skipAnswerButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addPrepareToAnswerViewsConstraints() {
        answerButton1.widthAnchor.constraint(equalToConstant: 56.0).isActive = true
        answerButton1.heightAnchor.constraint(equalToConstant: 56.0).isActive = true
        answerButton1.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        answerButton1.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10.0).isActive = true
        
        answerLabel1.topAnchor.constraint(equalTo: answerButton1.bottomAnchor, constant: 29.0).isActive = true
        answerLabel1.centerXAnchor.constraint(equalTo: answerButton1.centerXAnchor).isActive = true
        
        answerLabel2.topAnchor.constraint(equalTo: answerLabel1.bottomAnchor, constant: 8.0).isActive = true
        answerLabel2.centerXAnchor.constraint(equalTo: answerLabel1.centerXAnchor, constant: -20).isActive = true
        
        skipAnswerButton.leftAnchor.constraint(equalTo: answerLabel2.rightAnchor, constant: 1.0).isActive = true
        skipAnswerButton.centerYAnchor.constraint(equalTo: answerLabel2.centerYAnchor).isActive = true
    }
    
    func configRecordViews() {
        // config recordHintLabel
        recordHintLabel.font = UIFont.pfr(size: 14)
        recordHintLabel.textColor = UIColor.tftCoolGrey
        recordHintLabel.text = "点击录音"
        recordHintLabel.textAlignment = .center
        recordHintLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
        timeLabel.font = UIFont.sfps(size: 14)
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
        audioTimeLabel.font = UIFont.sfps(size: 16)
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
        rewardLabel.text = "发布成功\n请在\"我的主页\"中查看"
        rewardLabel.font = UIFont.pfl(size: 17)
        rewardLabel.textColor = UIColor.nonBodyTextColor
        rewardLabel.numberOfLines = 0
    }
    
    func addRecordConstraints() {
        // record hint label constraints
        recordHintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordHintLabel.widthAnchor.constraint(equalToConstant: 130.0).isActive = true
        recordHintLabel.heightAnchor.constraint(equalToConstant: 20.0).isActive = true
        recordHintLabel.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -16).isActive = true
        
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
        timeLabel.widthAnchor.constraint(equalToConstant: 42).isActive = true
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
    
    func initPrepareToAnswerViews() {
        answerButton1.isHidden = false
        answerLabel1.isHidden = false
        answerLabel2.isHidden = false
        skipAnswerButton.isHidden = false
        answerButton1.fadeIn()
        answerLabel1.fadeIn()
        answerLabel2.fadeIn()
        skipAnswerButton.fadeIn()
    }
    
    func hidePrepareToAnswerViews() {
        answerButton1.isHidden = true
        answerLabel1.isHidden = true
        answerLabel2.isHidden = true
        skipAnswerButton.isHidden = true
    }
    
    func initRecordViews() {
        recordHintLabel.isHidden = false
        recordButton.isHidden = false
        skipButton.isHidden = false
        recordHintLabel.fadeIn()
        recordButton.fadeIn()
        skipButton.fadeIn()
        
        recordHintLabel.text = "点击录音"
        speakingImgView.image = #imageLiteral(resourceName: "speaking-h")
        recordButton.layer.borderWidth = 2
        recordButton.setBackgroundImage(nil, for: .normal)
        seconds = secs
        
        clockIcon.isHidden = true
        timeLabel.isHidden = true
        audioBarButton.isHidden = true
        progressView.isHidden = true
        progressView.progress = 0.0
        postButton.isHidden = true
        rewardLabel.isHidden = true
        rewardImageView.isHidden = true
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
        } catch {
            
        }
    }
    
    func hideRecordViews() {
        recordHintLabel.isHidden = true
        recordButton.isHidden = true
        skipButton.isHidden = true
        clockIcon.isHidden = true
        timeLabel.isHidden = true
        audioBarButton.isHidden = true
        progressView.isHidden = true
        postButton.isHidden = true
        rewardLabel.isHidden = true
        rewardImageView.isHidden = true
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(false)
        } catch {
            
        }
    }
    
    func didTapRecordButton(_ sender: UIButton) {
        if audioRecorder == nil {
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try audioSession.setActive(true)
                audioSession.requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
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
        } else {
            finishRecording(success: true)
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
    
    func didTapSkipButton(_ sender: UIButton) {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(false)
        } catch {
            
        }
        recordHintLabel.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration)
        recordButton.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration) { success in
            if success {
                self.skipButton.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration) { success in
                    if success {
                        self.showTopicOnly(false)
                        self.setTitle(title: "优秀答案")
                        self.answerButton.fadeIn()
                    }
                }
            }
        }
    }
    
    func didTapSkipAnswerButton(_ sender: UIButton) {
        didTapSkipButton(sender)
        hidePrepareToAnswerViews()
    }
    
    func didTapPlayButton() {
        // reset player
        if timer != nil {
            timer.invalidate()
        }
        seconds = Int(audioPlayer.duration)
        audioTimeLabel.text = TimeManager.shared.timeString(time: TimeInterval(seconds))
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimerForPlayer), userInfo: nil, repeats: true)
        audioPlayer.play()
        audioPlayer.currentTime = 0
    }
    
    func didTapDeleteButton() {
        // reset player
        audioPlayer.stop()
        audioPlayer = nil
        timer.invalidate()
        
        // reset record
        audioBarButton.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: { success in
            if success {
                self.initRecordViews()
            }
        })
    }
    
    func didTapPostButton(_ sender: UIButton) {
        if audioPlayer != nil {
            audioPlayer.stop()
        }
        if timer != nil {
            timer.invalidate()
        }
        if audioRecorder != nil {
            audioRecorder.stop()
        }
        seconds = secs
        animateAfterBeforeUploadAudio()
        let audioFile = self.getDocumentsDirectory().appendingPathComponent("\(self.viewModel.topic.id)-speaking.wav")
        OSSAPIService.shared.uploadAudioFile(url: audioFile, withProgressBlock: { (bytesSent, totalByteSent, totalBytesExpectedToSend) in
            //print(bytesSent, totalByteSent, totalBytesExpectedToSend)
            Utils.runOnMainThread {
                self.progressView.progress = Float(totalByteSent) / Float(totalBytesExpectedToSend)
            }
        }, withCompletionBlock: { (error, url, uuid) in
            if error == nil {
                // Upload answer
                AnswerAPIService.shared.postAnswer(topicId: self.viewModel.topic.id, userId: Environment.shared.currentUser?.id, title: "", audioUrl: url!, ref: "", withCompletion: { (error, answerId) in
                    if error == nil {
                        // success
                        self.reloadData()
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
                        self.showTopicOnly(false)
                        self.setTitle(title: "优秀答案")
                        self.answerButton.fadeIn()
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
            didTapPlayButton()
        } else {
            // delete audio
            didTapDeleteButton()
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
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(self.viewModel.topic.id)-speaking.wav")
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
                self.recordHintLabel.text = "点击结束"
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
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setActive(false)
        } catch {
            
        }
        // reset timer
        self.seconds = self.secs
        if success {
            timer.invalidate()
            // time up
            recordHintLabel.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration)
            recordButton.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration)
            clockIcon.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration)
            timeLabel.fadeOut(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: { success in
                if success {
                    // show audio bar button and post button
                    
                    self.audioBarButton.fadeIn(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: nil)
                    self.postButton.fadeIn(withDuration: Duration.TopicDetailVC.View.fadeInOrOutDuration, withCompletionBlock: nil)
                    
                    // Prepare for audio player
                    let audioFile = self.getDocumentsDirectory().appendingPathComponent("\(self.viewModel.topic.id)-speaking.wav")
                    do {
                        self.audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
                    } catch {
                        // couldn't load file :(
                        //print("couldn't load file :(")
                    }
                    self.audioPlayer.enableRate = true
                    self.audioPlayer.prepareToPlay()
                    
                    self.audioTimeLabel.text = TimeManager.shared.timeString(time: self.audioPlayer.duration)
                }
            })
        } else {
            // reset views
            self.initRecordViews()
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
