//
//  LandingViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 9/8/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit
 

class LandingViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        label.font = UIFont.pfr(size: 17)
        label.numberOfLines = 0
        label.text = "登陆中，请稍后..."
        imageView.image = #imageLiteral(resourceName: "tft")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Animation
        imageView.startRotating()
        
        // Use local db login info to sign in
        if let loginInfo = Environment.shared.readLoginInfoFromDevice() {
            let userEmail = loginInfo[Environment.USER_EMAIL] as! String
            let password = loginInfo[Environment.USER_PASSWORD] as! String
            UserAPIService.shared.signIn(usernameOrEmail: userEmail, password: password, withCompletion: { (error, user) in
                if error == nil {
                    // Success
                    // Store current user
                    Environment.shared.currentUser = user
                    Utils.runOnMainThread {
                        let avator = UIImage(named: "TFTicons_avator_\((user?.id ?? 0) % 8)")
                        self.imageView.stopRotating()
                        self.imageView.image = avator
                        self.label.text = "\((user?.username)!)\n\n   欢迎回来！"
                        // Show home view controller
                        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.showHomeViewController), userInfo: nil, repeats: false)
                    }
                } else {
                    self.showSignInViewController()
                }
            })
        } else {
            showSignInViewController()
        }
    }
    
    func showSignInViewController() {
        let signInVC = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        let navigationController = UINavigationController(rootViewController: signInVC)
        ViewControllerManager.shared.navigationController = navigationController
        navigationController.view.backgroundColor = UIColor.bgdColor
        navigationController.modalTransitionStyle = .crossDissolve
        present(navigationController, animated: true, completion: nil)
    }
    
    func showHomeViewController() {
        let tc = storyboard?.instantiateViewController(withIdentifier: "MyTabBarController") as! MyTabBarController
        let navigationController = UINavigationController(rootViewController: tc)
        ViewControllerManager.shared.navigationController = navigationController
        navigationController.view.backgroundColor = UIColor.bgdColor
        navigationController.modalTransitionStyle = .crossDissolve
        present(navigationController, animated: true, completion: nil)
    }
    
}
