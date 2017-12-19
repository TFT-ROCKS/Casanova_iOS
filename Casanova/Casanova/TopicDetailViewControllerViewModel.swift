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
    fileprivate let topic: Topic
    
    // MARK: - Lifecycle
    init(topic: Topic) {
        self.topic = topic
    }
    
    // MARK: - Events
    var didError: ((Error) -> Void)?
    var didUpdate: ((TopicDetailViewControllerViewModel) -> Void)?
    var didSelectAnswer: ((Topic, Answer) -> Void)?
    
    // MARK: - Properties
    let cellViewModelsTypes: [CellRepresentable.Type] = [TopicHeaderTableViewCellViewModel.self]
    lazy var topicHeaderTableViewCellViewModel: TopicHeaderTableViewCellViewModel = {
        return TopicHeaderTableViewCellViewModel(topic: self.topic)
    }()
    var answerTableViewCellViewModel: 
    var isUpdating: Bool = false {
        didSet {
            self.didUpdate?(self)
        }
    }
    
    // MARK: - Actions
    func reloadData() {
        
    }
    
}
