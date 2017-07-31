//
//  TopicDetailViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 7/31/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class TopicDetailViewController: UIViewController {

    var tableView: UITableView
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        tableView = UITableView(frame: CGRect.zero)
        
        super.init(nibName: nil, bundle: nil)

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 300
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutSubviews()
        addConstraints()
        registerCustomCell()
    }
    
    func layoutSubviews() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func registerCustomCell() {
        tableView.register(AnswerDetailTableViewCell.self, forCellReuseIdentifier: "AnswerWithTextCell")
        tableView.register(AnswerDetailTableViewCell.self, forCellReuseIdentifier: "AnswerWithoutTextCell")
    }
    
    func addConstraints() {
        let margins = self.view.layoutMarginsGuide
        tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 100).isActive = true
        tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TopicDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
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
