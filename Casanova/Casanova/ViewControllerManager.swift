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
    var deepLinkManager: DeepLinkManager!
    var performedActions = [DeepLinkAction]()
    
    func performActions() {
        if navigationController == nil || deepLinkManager == nil { return }
        
        // loop actions
        for action in deepLinkManager.actions {
            if performedActions.contains(action) { continue }
            
            if action.actionType == .answer {
                // open single answer page
                presentAnswerDetailViewController(with: action.actionId)
                performedActions.append(action)
            }
        }
    }
    
    func presentAnswerDetailViewController(with answerId: Int) {
        let activityIndicatorVC = ActivityIndicatorViewController(activityTitle: "正在跳转至答案... \n请耐心等待...")
        activityIndicatorVC.modalTransitionStyle = .crossDissolve
        activityIndicatorVC.modalPresentationStyle = .overCurrentContext
        self.navigationController.present(activityIndicatorVC, animated: true, completion: nil)
        AnswerAPIService.shared.fetchAnswer(withId: answerId, withCompletion: { (error, answer) in
            activityIndicatorVC.dismiss(animated: false, completion: {
                if error == nil {
                    let answerDetailVC = AnswerDetailViewController(withAnswer: answer!)
                    if self.navigationController != nil {
                        self.navigationController.pushViewController(answerDetailVC, animated: true)
                    }
                } else {
                    let alertController = AlertManager.alertController(title: "错误", msg: "答案可能已被删除", style: .alert, actionT1: "哦", style1: .default, handler1: nil, actionT2: "What the heck?", style2: .default
                        , handler2: nil, viewForPopover: self.navigationController.view)
                    self.navigationController.present(alertController, animated: true, completion: nil)
                }
            })
        })
    }
}
