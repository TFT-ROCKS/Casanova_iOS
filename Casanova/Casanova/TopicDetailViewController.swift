//
//  TopicDetailViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/31/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

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
    
    // sub views
    let topicView: TopicHeaderView
    let tableView: UITableView
    let recordButton: UIButton = UIButton(frame: .zero)
    let skipButton: UIButton = UIButton(frame: .zero)
    
    // init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(withTopic topic: Topic) {
        self.topic = topic
        topicView = TopicHeaderView(frame: .zero)
        tableView = UITableView(frame: .zero)
        mode = .record
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutSubviews()
        addConstraints()
        registerCustomCell()
        configRecordAndSkipButtons()
        fetchTopicDetail()
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = Colors.TopicDetailVC.NavBar.tintColor()
        tableView.isHidden = true
        view.backgroundColor = UIColor.white
        setTitle()
        setButtons()
    }
    
    func layoutSubviews() {
        layoutTableView()
        layoutRecordAndSkipButtons()
        layoutTopicView()
    }
    
    func addConstraints() {
        addTableViewConstraints()
        addRecordAndSkipButtonsConstraints()
        addTopicViewConstraints()
    }
    
    func fetchTopicDetail() {
        TopicManager.shared.fetchTopicDetail(for: topic, withCompletion: { (error, topic) in
            if error == nil {
                // success
                self.topic = topic
                // reload table view
                
            }
        })
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
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
    
    func setButtons() {
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
}

// MARK: - TopicView
extension TopicDetailViewController {
    func layoutTopicView() {
        view.addSubview(topicView)
        topicView.translatesAutoresizingMaskIntoConstraints = false
        view.bringSubview(toFront: topicView)
        topicView.topic = topic
    }
    
    func addTopicViewConstraints() {
        topicView.topAnchor.constraint(equalTo: view.topAnchor, constant: (navigationController?.navigationBar.bounds.height)!).isActive = true
        topicView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topicView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TopicDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func layoutTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        configTableView()
    }
    
    func configTableView() {
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor(red: 248/255.0, green: 250/255.0, blue: 252/255.0, alpha: 1)
        tableView.isScrollEnabled = false
        // Hack for table view top space in between with topic view
        self.automaticallyAdjustsScrollViewInsets = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
    }
    
    func registerCustomCell() {
        tableView.register(AnswerDetailTableViewCell.self, forCellReuseIdentifier: "AnswerWithTextCell")
        tableView.register(AnswerDetailTableViewCell.self, forCellReuseIdentifier: "AnswerWithoutTextCell")
    }
    
    func addTableViewConstraints() {
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topicView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch mode {
        case .record:
            return 1
        case .reward:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .record:
            return 1
        case .reward:
            switch section {
            case 0:
                return 1
            default:
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerWithTextCell", for: indexPath) as? AnswerDetailTableViewCell {
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerWithoutTextCell", for: indexPath) as? AnswerDetailTableViewCell {
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - Record Button and Skip Buttons
extension TopicDetailViewController {
    
    func registerRecordAndSkipButtons() {
        recordButton.addTarget(self, action: #selector(self.recordButtonClicked(_:)), for: .touchUpInside)
        skipButton.addTarget(self, action: #selector(self.skipButtonClicked(_:)), for: .touchUpInside)
    }
    
    func layoutRecordAndSkipButtons() {
        view.addSubview(recordButton)
        view.addSubview(skipButton)
        view.bringSubview(toFront: recordButton)
        view.bringSubview(toFront: skipButton)
    }
    
    func configRecordAndSkipButtons() {
        // config buttons
        recordButton.layer.borderColor = UIColor(red: 120/255.0, green: 215/255.0, blue: 245/255.0, alpha: 1).cgColor
        recordButton.layer.borderWidth = 2.0
        recordButton.layer.cornerRadius = 85.9 / 2
        recordButton.layer.masksToBounds = true
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.layer.borderColor = UIColor(red: 164/255.0, green: 170/255.0, blue: 179/255.0, alpha: 1).cgColor
        skipButton.layer.borderWidth = 1.0
        skipButton.layer.cornerRadius = 29.9 / 2
        skipButton.layer.masksToBounds = true
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        // buttons' sub views
        let speakingImgView = UIImageView(frame: CGRect(x: 31.6, y: 27.4, width: 22.9, height: 30.6))
        speakingImgView.image = #imageLiteral(resourceName: "speaking-h")
        recordButton.addSubview(speakingImgView)
        let skipLabel = UILabel(frame: CGRect(x: 14.4, y: 2.45, width: 35.2, height: 25))
        skipLabel.font = UIFont(name: "Avenir-Medium", size: 18.0)
        skipLabel.text = "Skip"
        skipLabel.textColor = UIColor(red: 164/255.0, green: 170/255.0, blue: 179/255.0, alpha: 1)
        skipButton.addSubview(skipLabel)
    }
    
    func addRecordAndSkipButtonsConstraints() {
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
    }
    
    func recordButtonClicked(_ sender: UIButton) {
        
    }
    
    func skipButtonClicked(_ sender: UIButton) {
    
    }
}
