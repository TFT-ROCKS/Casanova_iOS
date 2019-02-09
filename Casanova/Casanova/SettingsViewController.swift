//
//  SettingsViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 9/28/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Firebase

class SettingsViewController: UIViewController {
    
    var tableView: UITableView = UITableView(frame: .zero, style: .grouped)
    let activityIndicatorView: NVActivityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .pacman, color: .brandColor)
    
    // user info
    var email: String!
    var username: String!
    var firstname: String!
    var lastname: String!
    
    // init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // right nav bar button
        let saveButton = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(self.saveSettings))
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.largeTitleDisplayMode = .never
        
        // title
        setTitle(title: "设置")
        
        // layout subviews
        layoutTableView()
        addTableViewConstraints()
        
        // init user info
        email = Environment.shared.currentUser?.email
        username = Environment.shared.currentUser?.username
        firstname = Environment.shared.currentUser?.firstname
        lastname = Environment.shared.currentUser?.lastname
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Analytics.setScreenName("settings", screenClass: nil)
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
    
    func saveSettings() {
        self.view.endEditing(true)
        activityIndicatorView.startAnimating()
        UserAPIService.shared.update(userId: Environment.shared.currentUser!.id, email: email, username: username, firstname: firstname, lastname: lastname, withCompletion: { (error, user) in
            Utils.runOnMainThread {
                self.activityIndicatorView.stopAnimating()
                if error == nil && user != nil {
                    Environment.shared.updateUserEmailToDevice(userEmail: user!.email)
                    Environment.shared.currentUser = user
                    self.tableView.reloadData()
                    self.setTitle(title: "保存成功")
                } else {
                    self.setTitle(title: "保存失败")
                }
            }
        })
    }
}

// MARK: - TableViewDelegate, TableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
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
        tableView.addGestureRecognizer(tgr)
    }
    
    func registerCustomCell() {
        let settingsTableViewCell = UINib(nibName: ReuseIDs.ProfileVC.settingsTableViewCell, bundle: nil)
        tableView.register(settingsTableViewCell, forCellReuseIdentifier: ReuseIDs.ProfileVC.settingsTableViewCell)
    }
    
    func addTableViewConstraints() {
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 1).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        
        activityIndicatorView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.15).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalTo: activityIndicatorView.widthAnchor).isActive = true
        activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 90))
        let label = UILabel(frame: CGRect(x: 35, y: 15, width: 60, height: 28))
        label.font = UIFont.pfm(size: 12)
        label.textColor = UIColor.nonBodyTextColor
        label.text = "账户信息"
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.ProfileVC.settingsTableViewCell, for: indexPath) as? ProfileSettingsTableViewCell {
            
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Email"
                cell.textField.text = email
                cell.textField.isEnabled = false
            case 1:
                cell.titleLabel.text = "用户名"
                cell.textField.text = username
                cell.textField.tag = Tags.ProfileVC.SettingsVC.usernameTableViewCellTag
            case 2:
                cell.titleLabel.text = "姓"
                cell.textField.text = lastname
                cell.textField.tag = Tags.ProfileVC.SettingsVC.lastnameTableViewCellTag
            case 3:
                cell.titleLabel.text = "名"
                cell.textField.text = firstname
                cell.textField.tag = Tags.ProfileVC.SettingsVC.firstnameTableViewCellTag
            default:
                break
            }
            
            cell.textField.delegate = self
            
            return cell
        }
        
        return UITableViewCell()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SettingsViewController: UIGestureRecognizerDelegate {
    
    func viewTapped(_ tgr: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension SettingsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case Tags.ProfileVC.SettingsVC.usernameTableViewCellTag:
            username = textField.text
        case Tags.ProfileVC.SettingsVC.firstnameTableViewCellTag:
            firstname = textField.text
        case Tags.ProfileVC.SettingsVC.lastnameTableViewCellTag:
            lastname = textField.text
        default:
            break
        }
    }
}
