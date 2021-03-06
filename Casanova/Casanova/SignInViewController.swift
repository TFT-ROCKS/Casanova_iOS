//
//  SignInViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/13/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBAction func forgetPasswordButtonClicked(_ sender: UIButton) {
    }
    @IBAction func skipButtonClicked(_ sender: UIButton) {
        usernameTextField.text = "游客123"
        passwordTextField.text = "guest123"
        logInButtonClicked(sender)
    }
    @IBOutlet weak var logInButton: UIButton!
    @IBAction func logInButtonClicked(_ sender: UIButton) {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicatorView.frame = logInButton.bounds
        indicatorView.tag = 5
        logInButton.addSubview(indicatorView)
        logInButton.setAttributedTitle(AttrString.titleAttrString("", textColor: UIColor.brandColor), for: .normal)
        indicatorView.startAnimating()
        UserAPIService.shared.signIn(usernameOrEmail: usernameTextField.text!, password: passwordTextField.text!, withCompletion: { (error, user) in
            if error == nil {
                // Success
                // Store current user
                Environment.shared.saveLoginInfoToDevice(userEmail: self.usernameTextField.text!, password: self.passwordTextField.text!)
                self.errorLabel.text = " "
                // Show landing view
                self.dismiss(animated: true, completion: nil)
            } else {
                self.logInButton.viewWithTag(5)?.removeFromSuperview()
                self.logInButton.setAttributedTitle(AttrString.titleAttrString("登陆", textColor: UIColor.brandColor), for: .normal)
                self.errorLabel.text = error?.msg
            }
        })
    }
    @IBOutlet weak var signUpButton: UIButton!
    @IBAction func signUpButtonClicked(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var bottomConstraintConstant: CGFloat!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Padding textfield
        let paddingView1 = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: usernameTextField.frame.height))
        usernameTextField.font = UIFont.sfps(size: 17)
        usernameTextField.textColor = UIColor.nonBodyTextColor
        usernameTextField.leftView = paddingView1
        usernameTextField.leftViewMode = .always
        usernameTextField.placeholder = "邮箱"
        usernameTextField.layer.cornerRadius = 22.5
        usernameTextField.layer.masksToBounds = true
        
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: passwordTextField.frame.height))
        passwordTextField.font = UIFont.sfps(size: 17)
        passwordTextField.textColor = UIColor.nonBodyTextColor
        passwordTextField.leftView = paddingView2
        passwordTextField.leftViewMode = .always
        passwordTextField.placeholder = "密码"
        passwordTextField.layer.cornerRadius = 22.5
        passwordTextField.layer.masksToBounds = true
        
        // Error label configs
        errorLabel.font = UIFont.pfr(size: 12)
        errorLabel.textColor = UIColor.errorTextColor
        errorLabel.text = " "
        
        // Log in / Sign up buttons configs
        logInButton.layer.cornerRadius = 22.5
        logInButton.layer.masksToBounds = true
        logInButton.layer.borderColor = UIColor.brandColor.cgColor
        logInButton.layer.borderWidth = 1.0
        logInButton.layer.backgroundColor = UIColor.clear.cgColor
        
        logInButton.setAttributedTitle(AttrString.titleAttrString("登陆", textColor: UIColor.brandColor), for: .normal)
        
        signUpButton.layer.cornerRadius = 22.5
        signUpButton.layer.masksToBounds = true
        signUpButton.layer.borderColor = UIColor.brandColor.cgColor
        signUpButton.layer.borderWidth = 1.0
        signUpButton.layer.backgroundColor = UIColor.brandColor.cgColor
        
        signUpButton.setAttributedTitle(AttrString.titleAttrString("注册", textColor: UIColor.white), for: .normal)
        
        // Record Constraint
        bottomConstraintConstant = bottomConstraint.constant
        
        // Configs
        navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // Deal with keyboard notification
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve: UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.height {
                bottomConstraint.constant = bottomConstraintConstant
            } else {
                bottomConstraint.constant = endFrame?.size.height ?? bottomConstraintConstant
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        errorLabel.text = " "
        self.view.endEditing(true)
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        
        // Add Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Remove Notifications
        NotificationCenter.default.removeObserver(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: SignUpViewControllerDelegate
extension SignInViewController: SignUpViewControllerDelegate {
    func fillEmailTextField(with text: String) {
        usernameTextField.text = text
    }
    
    func fillPasswordTextField(with pass: String) {
        passwordTextField.text = pass
    }
}
