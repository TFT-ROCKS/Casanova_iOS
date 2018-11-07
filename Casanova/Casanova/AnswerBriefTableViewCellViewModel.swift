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
    fileprivate let topic: Topic
    fileprivate let answer: Answer
    fileprivate var restrictedTo: IndexPath?
    
    // MARK: - Lifecycle
    init(answer: Answer, topic: Topic) {
        self.answer = answer
        self.topic = topic
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
        return answer.username
    }
    
    var answerTimeText: String {
        return TimeManager.shared.elapsedDateString(fromString: answer.updateTime)
    }
    
    var avator: UIImage? {
        return UIImage(named: "TFTicons_avator_\(answer.userID % 8)")
    }
    
    var answerTitleText: NSAttributedString {
        let title = answer.title != "" ? answer.title : Placeholder.answerTitlePlaceholderStr
        return AttrString.answerBriefAttrString(title)
    }
    
    var answerImage: UIImage?
    
    var markImageViewHidden: Bool {
        return !(answer.username == "TFT")
    }
    
    var trashButtonHidden: Bool {
        return !(answer.userID == Environment.shared.currentUser?.id)
    }
    
    var clapsText: String {
        // TODO: Use count of likes for now, replace with num of claps later
        return "\(answer.likesNum) 鼓掌"
    }
    
    var commentsText: String {
        return "\(answer.commentsNum) 跟读"
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
        if answer.audio != nil {
            if let imageURL = URL(string: answer.pic) {
                Manager.shared.loadImage(with: imageURL) { image in
                    self.answerImage = image.value
                    self.didUpdate?(self)
                }
            } else {
                self.answerImage = imageForAnswer
                self.didUpdate?(self)
            }
        }
    }
    
    @objc func deleteAnswer() {
        self.didDeleteAnswer?(answer)
    }
    
    // MARK: - Utils
    private var imageForAnswer: UIImage {
        let id = answer.id
        let tags = topic.tags.components(separatedBy: ",")
        let tagToUse = tags[id % tags.count].lowercased()
        let imageName = tagToUse + "\(id % 3 + 1)" // 1, 2, 3
        
        return UIImage(named: imageName) ?? UIImage(named: "others")!
    }
}

extension AnswerBriefTableViewCellViewModel: CellRepresentable {
    static func registerCell(tableView: UITableView) {
        tableView.register(AnswerBriefTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerTextAudioCell)
        tableView.register(AnswerBriefTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerOnlyTextCell)
        tableView.register(AnswerBriefTableViewCell.self, forCellReuseIdentifier: ReuseIDs.TopicDetailVC.View.answerOnlyAudioCell)
    }
    
    func dequeueCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        var cell: AnswerBriefTableViewCell
        
        if answer.audio != nil && answer.title != "" {
            // Answer with text and audio
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerTextAudioCell, for: indexPath) as! AnswerBriefTableViewCell
        } else if answer.audio == nil {
            // Answer with only text
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerOnlyTextCell, for: indexPath) as! AnswerBriefTableViewCell
        } else {
            // Answer with only audio
            cell = tableView.dequeueReusableCell(withIdentifier: ReuseIDs.TopicDetailVC.View.answerOnlyAudioCell, for: indexPath) as! AnswerBriefTableViewCell
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
