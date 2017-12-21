//
//  AnswerBriefTableViewCellViewModel.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 12/19/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation
import Nuke

class AnswerBriefTableViewCellViewModel {
    
    // MARK: - Private
    fileprivate let answer: Answer
    fileprivate var restrictedTo: IndexPath?
    
    // MARK: - Lifecycle
    init(answer: Answer) {
        self.answer = answer
    }
    
    deinit {
        // do nothing for now
    }
    
    // MARK: - Events
    var didError: ((Error) -> Void)?
    var didUpdate: ((AnswerBriefTableViewCellViewModel) -> Void)?
    var didSelect: ((Answer) -> Void)?
    var didDeleteAnswer: ((Answer) -> Void)?
    
    // MARK: - Properties
    var answererNameText: String {
        return answer.user.username
    }
    
    var answerTimeText: String {
        return TimeManager.shared.elapsedDateString(fromString: answer.updatedAt)
    }
    
    var avator: UIImage? {
        return UIImage(named: "TFTicons_avator_\(answer.user.id % 8)")
    }
    
    var answerTitleText: String {
        return answer.title != "" ? answer.title : Placeholder.answerTitlePlaceholderStr
    }
    
    var answerImage: UIImage?
    
    var trashButtonHidden: Bool {
        return !(answer.user.id == Environment.shared.currentUser?.id)
    }
    
    var clapsText: String {
        // TODO: Use count of likes for now, replace with num of claps later
        return "\(answer.likes.count) 鼓掌"
    }
    
    var commentsText: String {
        return "\(answer.comments.count) 跟读"
    }
    
    // MARK: - Actions
    func allowedAccess(_ object: CellIdentifiable) -> Bool {
        guard
            let restrictedTo = restrictedTo,
            let uniqueId = object.uniqueId
            else { return true }
        
        return uniqueId == restrictedTo
    }
    
    func loadAnswerImage() {
        if answer.audioURL != nil {
            if let imageURL = URL(string: answer.imageURL ?? "") {
                Manager.shared.loadImage(with: imageURL) { image in
                    self.answerImage = image.value
                    self.didUpdate?(self)
                }
            } else {
                self.answerImage = UIImage(named: answer.topic?.tags.components(separatedBy: ",").first?.lowercased() ?? "others")!
                self.didUpdate?(self)
            }
        }
    }
    
    @objc func deleteAnswer() {
        self.didDeleteAnswer?(answer)
    }
}

extension AnswerBriefTableViewCellViewModel: CellRepresentable {
    static func registerCell(tableView: UITableView) {
        tableView.register(AnswerBriefTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerDefaultCell)
        tableView.register(AnswerBriefTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerWithoutAudioCell)
    }
    
    func dequeueCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        var cell: AnswerBriefTableViewCell
        
        if answer.audioURL == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerWithoutAudioCell, for: indexPath) as! AnswerBriefTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerDefaultCell, for: indexPath) as! AnswerBriefTableViewCell
        }
        
        cell.uniqueId = indexPath
        restrictedTo = indexPath
        cell.bind(viewModel: self)
        return cell
    }
    
    func cellSelected() {
        self.didSelect?(self.answer)
    }
}
