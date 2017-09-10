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
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Animation
        imageView.startRotating()
        
        // Use local db login info to sign in
        if let loginInfo = Environment.shared.readLoginInfoFromDevice() {
            let username = loginInfo["username"] as! String
            let password = loginInfo["password"] as! String
            UserManager.shared.signIn(usernameOrEmail: username, password: password, withCompletion: { (error, user) in
                if error == nil {
                    // Success
                    // Store current user
                    Environment.shared.currentUser = user
                    let tc = self.storyboard?.instantiateViewController(withIdentifier: "MyTabBarController") as! MyTabBarController
                    let navigationController = UINavigationController(rootViewController: tc)
                    navigationController.modalTransitionStyle = .crossDissolve
                    self.present(navigationController, animated: true, completion: nil)
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
        navigationController.modalTransitionStyle = .crossDissolve
        present(navigationController, animated: true, completion: nil)
    }

}
