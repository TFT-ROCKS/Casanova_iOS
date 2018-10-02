//
//  SignUpViewController.swift
//  Casanova
//
//  Created by Xiaoyu Guo on 8/13/17.
//  Copyright © 2017 Xiaoyu Guo. All rights reserved.
//

import UIKit

protocol SignUpViewControllerDelegate: class {
    func fillEmailTextField(with text: String)
    func fillPasswordTextField(with pass: String)
}

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBAction func signUpButtonClicked(_ sender: UIButton) {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicatorView.frame = signUpButton.bounds
        indicatorView.tag = 5
        signUpButton.addSubview(indicatorView)
        signUpButton.setAttributedTitle(AttrString.titleAttrString("", textColor: UIColor.brandColor), for: .normal)
        indicatorView.startAnimating()
        UserAPIService.shared.signUp(username: usernameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, firstname: firstnameTextField.text!, lastname: lastnameTextField.text!, withCompletion: { error in
            if let error = error {
                self.signUpButton.viewWithTag(5)?.removeFromSuperview()
                self.signUpButton.setAttributedTitle(AttrString.titleAttrString("注册", textColor: UIColor.white), for: .normal)
                self.errorLabel.text = error.msg
            } else {
                // Success
                self.signUpButton.viewWithTag(5)?.removeFromSuperview()
                self.errorLabel.text = " "
                self.delegate.fillEmailTextField(with: self.usernameTextField.text!)
                self.delegate.fillPasswordTextField(with: self.passwordTextField.text!)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var bottomConstraintConstant: CGFloat!
    
    var delegate: SignUpViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Padding textfield
        let paddingView1 = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: usernameTextField.frame.height))
        usernameTextField.font = UIFont.sfps(size: 17)
        usernameTextField.textColor = UIColor.nonBodyTextColor
        usernameTextField.leftView = paddingView1
        usernameTextField.leftViewMode = .always
        usernameTextField.placeholder = "用户名"
        usernameTextField.layer.cornerRadius = 22.5
        usernameTextField.layer.masksToBounds = true
        
        let paddingView4 = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: firstnameTextField.frame.height))
        firstnameTextField.font = UIFont.sfps(size: 17)
        firstnameTextField.textColor = UIColor.nonBodyTextColor
        firstnameTextField.leftView = paddingView4
        firstnameTextField.leftViewMode = .always
        firstnameTextField.placeholder = "名"
        firstnameTextField.layer.cornerRadius = 22.5
        firstnameTextField.layer.masksToBounds = true
        
        let paddingView5 = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: lastnameTextField.frame.height))
        lastnameTextField.font = UIFont.sfps(size: 17)
        lastnameTextField.textColor = UIColor.nonBodyTextColor
        lastnameTextField.leftView = paddingView5
        lastnameTextField.leftViewMode = .always
        lastnameTextField.placeholder = "姓"
        lastnameTextField.layer.cornerRadius = 22.5
        lastnameTextField.layer.masksToBounds = true
        
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: emailTextField.frame.height))
        emailTextField.font = UIFont.sfps(size: 17)
        emailTextField.textColor = UIColor.nonBodyTextColor
        emailTextField.leftView = paddingView2
        emailTextField.leftViewMode = .always
        emailTextField.placeholder = "邮箱"
        emailTextField.layer.cornerRadius = 22.5
        emailTextField.layer.masksToBounds = true
        
        let paddingView3 = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: passwordTextField.frame.height))
        passwordTextField.font = UIFont.sfps(size: 17)
        passwordTextField.textColor = UIColor.nonBodyTextColor
        passwordTextField.leftView = paddingView3
        passwordTextField.leftViewMode = .always
        passwordTextField.placeholder = "密码"
        passwordTextField.layer.cornerRadius = 22.5
        passwordTextField.layer.masksToBounds = true
        
        // Error label configs
        errorLabel.font = UIFont.pfr(size: 12)
        errorLabel.textColor = UIColor.errorTextColor
        errorLabel.text = " "
        
        // Sign up button configs
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
        
        self.view.endEditing(true)
        
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
