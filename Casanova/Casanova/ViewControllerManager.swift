//
//  ViewControllerManager.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 11/21/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import Foundation

class ViewControllerManager: NSObject {
    static let shared = ViewControllerManager()
    var currentVC: UIViewController!
    var navigationController: UINavigationController!
    var queue: [Int] = []
    
    func work() {
        let needsToWork = queue.count > 0 && navigationController != nil
        if needsToWork {
            let answerId = queue.removeFirst()
            presentAnswerDetailViewController(with: answerId)
            work() // keep working
        }
    }
    
    func presentAnswerDetailViewController(with answerId: Int) {
        AnswerManager.shared.fetchAnswer(withId: answerId, withCompletion: { (error, answer) in
            if error == nil {
                let answerDetailVC = AnswerDetailViewController(withAnswer: answer!)
                if self.navigationController != nil {
                    self.navigationController.pushViewController(answerDetailVC, animated: true)
                }
            }
        })
    }
}
