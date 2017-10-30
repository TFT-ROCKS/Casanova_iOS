//
//  ShareSheetViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 10/29/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

enum ShareType {
    case answer
}

protocol ShareSheetViewControllerDelegate: class {
    func shareToWechat(with params: [String: Any], type: ShareType)
    func shareToMoment(with params: [String: Any], type: ShareType)
}

class ShareSheetViewController: UIViewController, UIGestureRecognizerDelegate {

    class func instantiate(with title: String, delegate: ShareSheetViewControllerDelegate, type: ShareType, params: [String: Any]) -> ShareSheetViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShareSheetViewController") as! ShareSheetViewController
        
        vc.delegate = delegate
        vc.type = type
        vc.titleString = title
        vc.params = params
        vc.modalPresentationStyle = .overCurrentContext
        
        return vc
    }
    
    weak var delegate: ShareSheetViewControllerDelegate!
    var titleString: String!
    var type: ShareType!
    var params: [String: Any]!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wechatButton: UIButton!
    @IBOutlet weak var momentButton: UIButton!
    @IBOutlet weak var actionSheetView: UIView!
    @IBAction func wechatButtonDidTapped(_ sender: UIButton) {
        slideOut()
        delegate.shareToWechat(with: params, type: type)
    }
    @IBAction func momentButtonDidTapped(_ sender: UIButton) {
        slideOut()
        delegate.shareToMoment(with: params, type: type)
    }
    @IBOutlet weak var cancelButton: UIButton!
    @IBAction func cancelButtonDidTapped(_ sender: UIButton) {
        slideOut()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Up
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.6)
        actionSheetView.layer.cornerRadius = 10
        actionSheetView.layer.masksToBounds = true
        wechatButton.setTitle("", for: .normal)
        wechatButton.setImage(#imageLiteral(resourceName: "wechat_share"), for: .normal)
        momentButton.setTitle("", for: .normal)
        momentButton.setImage(#imageLiteral(resourceName: "moment_share"), for: .normal)
        cancelButton.backgroundColor = UIColor.white
        cancelButton.layer.cornerRadius = 10
        cancelButton.layer.masksToBounds = true
        cancelButton.setTitleColor(UIColor.brandColor, for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.titleLabel?.font = UIFont.pfr(size: 20)
        titleLabel.text = titleString
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.pfl(size: 12)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        slideIn()
    }
    
    func slideOut() {
        UIView.beginAnimations("removeFromSuperviewWithAnimation", context: nil)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStop(#selector(animationDidStop(animationID:finished:context:)))

        actionSheetView.frame.origin = CGPoint(x: 0.0, y: view.bounds.size.height)
        cancelButton.frame.origin = CGPoint(x: 0.0, y: view.bounds.size.height)

        UIView.commitAnimations()
    }
    
    func slideIn() {
        actionSheetView.frame.origin = CGPoint(x: 0.0, y: view.bounds.size.height)
        cancelButton.frame.origin = CGPoint(x: 0.0, y: view.bounds.size.height)

        let animation = CATransition()
        animation.duration = 0.5
        animation.type = kCATransitionPush
        animation.subtype = kCATransitionFromTop
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)

        actionSheetView.layer.add(animation, forKey: "TransitionToActionSheet")
        cancelButton.layer.add(animation, forKey: "TransitionToCancelButton")
    }
    
    func animationDidStop(animationID: String, finished: NSNumber, context: UnsafeRawPointer) {
        if animationID == "removeFromSuperviewWithAnimation" {
            dismiss(animated: false, completion: nil)
        }
    }
    
    func handleTap(_ sender: UIView) {
        slideOut()
    }
}
