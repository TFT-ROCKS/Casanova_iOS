//
//  TopicDetailViewControllerViewModel.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 12/18/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class TopicDetailViewControllerViewModel {
    // MARK: - Private
    // TODO: Make topic public for now, private once MVVM architecture migration is done
    let topic: Topic
    private var answers: [Answer]
    var showTopicOnly: Bool
    
    // MARK: - Table view
    var numOfSections: Int {
        get {
            if self.showTopicOnly {
                return 1
            } else {
                return self.answersTableViewCellModels != nil ? self.answersTableViewCellModels.count + 1 : 1
            }
        }
    }
    
    var numOfRows: Int {
        get {
            if self.showTopicOnly {
                return 1
            } else {
                return 1
            }
        }
    }
    
    // MARK: - Lifecycle
    init(topic: Topic) {
        self.topic = topic
        self.answers = []
        self.showTopicOnly = true
    }
    
    // MARK: - Events
    var didError: ((Error) -> Void)?
    var didUpdate: ((TopicDetailViewControllerViewModel) -> Void)?
    // MARK: - Events Topic
    var didWannaAnswer: (() -> Void)?
    // MARK: - Events Answer
    var didSelectAnswer: ((Topic, Answer) -> Void)?
    var didDeleteAnswer: ((Answer) -> Void)?
    
    // MARK: - Properties
    let cellViewModelsTypes: [CellRepresentable.Type] = [TopicHeaderTableViewCellViewModel.self, AnswerBriefTableViewCellViewModel.self]
    lazy var topicHeaderTableViewCellViewModel: TopicHeaderTableViewCellViewModel = {
        let vm = TopicHeaderTableViewCellViewModel(topic: self.topic)
        return vm
    }()
    var answersTableViewCellModels: [CellRepresentable]!
    var isUpdating: Bool = false {
        didSet {
            self.didUpdate?(self)
        }
    }
    var binded: Bool = false
    
    // MARK: - Actions
    func reloadData() {
        self.isUpdating = true
        AnswerAPIService.shared.fetchAnswers(num: 1000, offset: 0, topicID: topic.id) { (error, answers) in
            if error == nil {
                // success
                self.answers = answers!
                self.answersTableViewCellModels = self.answers.map { self.viewModelFor(answer: $0, topic: self.topic) }
            }
            self.isUpdating = false
        }
    }
    
    func deleteAnswer(_ answer: Answer) {
        AnswerAPIService.shared.deleteAnswer(answerId: answer.id) { (error) in
            self.reloadData()
        }
    }
    
    func addAnswer(_ answer: Answer) {
//        topic.answers.append(answer)
//        answersTableViewCellModels = self.topic.answers.map { self.viewModelFor(answer: $0, topic: self.topic) }
//        didUpdate?(self)
    }
    
    //MARK: - Helpers
    private func viewModelFor(answer: Answer, topic: Topic) -> CellRepresentable {
        let viewModel = AnswerBriefTableViewCellViewModel(answer: answer, topic: topic)
        viewModel.didSelect = { [unowned self] answer in
            self.didSelectAnswer?(topic, answer)
        }
        viewModel.didError = { [unowned self] error in
            self.didError?(error)
        }
        viewModel.didDeleteAnswer = { [unowned self] answer in
            self.didDeleteAnswer?(answer)
        }
        return viewModel
    }
    
}
