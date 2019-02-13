//
//  ProfileViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/14/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import Firebase
 

class ProfileViewController: UIViewController {

    // sub views
    var tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubViews()
        addSubViewConstraints()
        configSubViews()
        
        navigationController?.navigationBar.topItem?.title = " "
        registerNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setButtons()
        setTitle()
        
        Analytics.setScreenName("profile", screenClass: nil)
    }
    
    func layoutSubViews() {
        layoutTableView()
    }
    
    func configSubViews() {
        configTableView()
    }
    
    func addSubViewConstraints() {
        addTableViewConstraints()
    }
    
    func setTitle() {
        tabBarController?.navigationItem.title = "主页"
    }
    
    func setButtons() {
        tabBarController?.navigationItem.leftBarButtonItems = nil
        tabBarController?.navigationItem.rightBarButtonItems = nil
    }
}

// MARK: - Table View
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func layoutTableView() {
        view.addSubview(tableView)
        view.bringSubview(toFront: tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .zero
        tableView.backgroundColor = UIColor.bgdColor
        tableView.separatorStyle = .none
        
        let profileBriefTableViewCell = UINib(nibName: ReuseIDs.ProfileVC.profileBriefTableViewCell, bundle: nil)
        tableView.register(profileBriefTableViewCell, forCellReuseIdentifier: ReuseIDs.ProfileVC.profileBriefTableViewCell)
        
        let profileDetailTableViewCell = UINib(nibName: ReuseIDs.ProfileVC.profileDetailTableViewCell, bundle: nil)
        tableView.register(profileDetailTableViewCell, forCellReuseIdentifier: ReuseIDs.ProfileVC.profileDetailTableViewCell)
    }
    
    func addTableViewConstraints() {
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                if let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.ProfileVC.profileDetailTableViewCell, for: indexPath) as? ProfileDetailTableViewCell {
                    let user = Environment.shared.currentUser!
                    let avator = UIImage(named: "TFTicons_avator_\(user.id % 8)")
                    
                    cell.leftImageView.image = avator
                    cell.topTitleLabel.text = user.firstname != "" ? user.firstname : user.username
                    cell.bottomTitleLabel.text = user.email
                    
                    return cell
                }
            }
        case 1:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.ProfileVC.profileBriefTableViewCell, for: indexPath) as? ProfileBriefTableViewCell {
                if indexPath.row == 0 {
                    cell.titleLabel.text = "我的回答 (Coming soon...)"
                } else if indexPath.row == 1 {
                    cell.titleLabel.text = "任务 (Coming soon...)"
                }
                
                return cell
            }
        case 2:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.ProfileVC.profileBriefTableViewCell, for: indexPath) as? ProfileBriefTableViewCell {
                if indexPath.row == 0 {
                    cell.titleLabel.text = "设置"
                }
                
                return cell
            }
        case 3:
            if let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.ProfileVC.profileBriefTableViewCell, for: indexPath) as? ProfileBriefTableViewCell {
                if indexPath.row == 0 {
                    cell.titleLabel.text = "登出"
                }
                
                return cell
            }
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                // My Answers
                print("TODO")
//                presentUserAnswersVC()
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                // Settings
                let vc = SettingsViewController()
                navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
        case 3:
            switch indexPath.row {
            case 0:
                // Log out
                presentLogOutAlertSheet()
            default:
                break
            }
        default:
            break
        }
    }
}

extension ProfileViewController {
    // My Answers logic
    func presentUserAnswersVC() {
        let vc = UserAnswersViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Log out logic
    func presentLogOutAlertSheet() {
        let alertController = AlertManager.alertController(title: "", msg: "确认要退出登录吗", style: .actionSheet, actionT1: "登出", style1: .destructive, handler1: { [unowned self] _ in
            self.logOut()
            }, actionT2: "取消", style2: .default, handler2: nil, viewForPopover: self.view)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func logOut() {
        // logout
        UserAPIService.shared.logOut() { error in
            if error == nil {
                // success
                NotificationCenter.default.removeObserver(self)
                Environment.shared.currentUser = nil
                Environment.shared.resetLoginInfoOnDevice()
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: - Notification Handlers
extension ProfileViewController {
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleUserProfileUpdated(_:)), name: Notifications.userProfileUpdatedNotification, object: nil)
    }
    
    func handleUserProfileUpdated(_ notification: Notification) {
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
    }
}
