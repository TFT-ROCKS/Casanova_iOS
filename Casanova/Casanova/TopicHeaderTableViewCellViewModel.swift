//
//  TopicHeaderTableViewCellViewModel.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 12/18/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class TopicHeaderTableViewCellViewModel {
    
    // MARK: - Private
    fileprivate let topic: Topic
    fileprivate var restrictedTo: IndexPath?
    fileprivate let difficulties: [String] = ["Beginner", "Easy", "Medium", "Hard", "Ridiculous"]
    
    // MARK: - Lifecycle
    init(topic: Topic) {
        self.topic = topic
    }
    
    deinit {
        // do nothing for now
    }
    
    // MARK: - Events
    var didError: ((Error) -> Void)?
    var didUpdate: ((TopicHeaderTableViewCellViewModel) -> Void)?
    var didSelect: ((Topic) -> Void)?
    
    // MARK: - Properties
    var answersCountText: String {
        get {
            return "\(topic.answersCount)个回答"
        }
    }
    var titleText: NSAttributedString {
        get {
            return AttrString.topicAttrString(topic.title)
        }
    }
    var level: Int {
        get {
            return topic.level
        }
    }
    var difficultyText: String {
        get {
            return difficulties[topic.level - 1]
        }
    }
    var tags: [String] {
        get {
            return topic.tags.components(separatedBy: ",")
        }
    }
    
    // MARK: - Actions
    func allowedAccess(_ object: CellIdentifiable) -> Bool {
        guard
            let restrictedTo = restrictedTo,
            let uniqueId = object.uniqueId
            else { return true }
        
        return uniqueId == restrictedTo
    }
}

extension TopicHeaderTableViewCellViewModel: CellRepresentable {
    static func registerCell(tableView: UITableView) {
        tableView.register(UINib(nibName: String(describing: TopicHeaderTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: TopicHeaderTableViewCell.self))
    }
    
    func dequeueCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TopicHeaderTableViewCell.self), for: indexPath) as! TopicHeaderTableViewCell
        cell.uniqueId = indexPath
        restrictedTo = indexPath
        cell.bind(viewModel: self)
        return cell
    }
    
    func cellSelected() {
        self.didSelect?(self.topic)
    }
}
