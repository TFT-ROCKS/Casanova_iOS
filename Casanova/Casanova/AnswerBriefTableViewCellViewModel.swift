//
//  AnswerBriefTableViewCellViewModel.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 12/19/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

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
    
    var answerTitleText: NSAttributedString {
        return AttrString.answerAttrString(answer.title)
    }
    
    var answerImage: UIImage?
    
    // MARK: - Actions
    func allowedAccess(_ object: CellIdentifiable) -> Bool {
        guard
            let restrictedTo = restrictedTo,
            let uniqueId = object.uniqueId
            else { return true }
        
        return uniqueId == restrictedTo
    }
}

extension AnswerBriefTableViewCellViewModel: CellRepresentable {
    static func registerCell(tableView: UITableView) {
        tableView.register(AnswerBriefTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerDefaultCell)
        tableView.register(AnswerBriefTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerWithoutAudioCell)
    }
    
    func dequeueCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AnswerBriefTableViewCell.self), for: indexPath) as! AnswerBriefTableViewCell
        cell.uniqueId = indexPath
        restrictedTo = indexPath
        cell.bind(viewModel: self)
        return cell
    }
    
    func cellSelected() {
        self.didSelect?(self.answer)
    }
}
