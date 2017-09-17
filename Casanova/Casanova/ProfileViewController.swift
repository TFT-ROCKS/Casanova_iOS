//
//  ProfileViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/14/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import SVGKit

class ProfileViewController: UIViewController {

    // sub views
    var headerView: UIView = UIView(frame: .zero)
    var tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    var avatorView: SVGKImageView = SVGKFastImageView(frame: .zero)
    var usernameLabel: UILabel = UILabel(frame: .zero)
    var emailLabel: UILabel = UILabel(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubViews()
        addSubViewConstraints()
        configSubViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setButtons()
        setTitle(title: "我的主页")
    }
    
    func layoutSubViews() {
        layoutHeaderView()
        layoutTableView()
    }
    
    func configSubViews() {
        configHeaderView()
        configTableView()
    }
    
    func addSubViewConstraints() {
        addHeaderViewConstraints()
        addTableViewConstraints()
    }
    
    func setTitle(title: String) {
        let titleLabel = UILabel(frame: CGRect(x: 95, y: 11, width: 184, height: 22))
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.text = title
        titleLabel.font = UIFont.pfr(size: 18)
        titleLabel.textColor = UIColor.nonBodyTextColor
        titleLabel.sizeToFit()
        tabBarController?.navigationItem.titleView = titleLabel
    }
    
    func setButtons() {
        tabBarController?.navigationItem.leftBarButtonItem = nil
        tabBarController?.navigationItem.rightBarButtonItem = nil
    }
}

// MARK: - Header View
extension ProfileViewController {
    func layoutHeaderView() {
        view.addSubview(headerView)
        view.bringSubview(toFront: headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        // sub views
        headerView.addSubview(avatorView)
        headerView.addSubview(usernameLabel)
        headerView.addSubview(emailLabel)
        
        avatorView.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configHeaderView() {
        avatorView.layer.cornerRadius = avatorView.bounds.width / 2
        avatorView.layer.masksToBounds = true
        
        usernameLabel.font = UIFont.mr(size: 20)
        usernameLabel.textColor = UIColor.tftFadedBlue
        usernameLabel.textAlignment = .center
        
        emailLabel.font = UIFont.mr(size: 14)
        emailLabel.textColor = UIColor.tftCoolGrey
        emailLabel.textAlignment = .center
        
        // data
        let user = Environment.shared.currentUser!
        
        let avator = SVGKImage(named: "TFTicons_avator_\(user.id % 8)")
        avatorView.image = avator
        usernameLabel.text = user.firstname != "" ? user.firstname : user.username
        emailLabel.text = user.email
    }
    
    func addHeaderViewConstraints() {
        headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        headerView.bottomAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20).isActive = true
        
        // sub views
        avatorView.widthAnchor.constraint(equalToConstant: view.bounds.width*0.25).isActive = true
        avatorView.heightAnchor.constraint(equalToConstant: view.bounds.width*0.25).isActive = true
        avatorView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 18).isActive = true
        avatorView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        
        usernameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 50).isActive = true
        usernameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -50).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: avatorView.bottomAnchor, constant: 6).isActive = true
        
        emailLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 50).isActive = true
        emailLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -50).isActive = true
        emailLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 5).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: 17).isActive = true
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ReuseIDs.ProfileVC.profileTableViewCell)
        tableView.backgroundColor = UIColor.bgdColor
    }
    
    func addTableViewConstraints() {
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.ProfileVC.profileTableViewCell, for: indexPath)
        cell.textLabel?.textColor = UIColor.tftFadedBlue
        cell.textLabel?.font = UIFont.pfr(size: 17)
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.textLabel?.text = "我的回答"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "任务"
            }
        case 1:
            if indexPath.row == 0 {
                cell.textLabel?.text = "设置"
            }
        case 2:
            if indexPath.row == 0 {
                cell.textLabel?.text = "登出"
            }
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 2:
            switch indexPath.row {
            case 0:
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
    func presentLogOutAlertSheet() {
        let alert = UIAlertController(title: "", message: "确认要退出登录吗", preferredStyle: .actionSheet)
        let confirm = UIAlertAction(title: "登出", style: .default, handler: { [unowned self] _ in
            self.logOut()
        })
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func logOut() {
        // logout
        UserManager.shared.logOut() { error in
            if error == nil {
                // success
                Environment.shared.currentUser = nil
                Environment.shared.resetLoginInfoOnDevice()
                self.showSignInViewController()
            }
        }
    }
    
    func showSignInViewController() {
        let signInVC = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.navigationController?.setViewControllers([signInVC], animated: false)
    }
}
