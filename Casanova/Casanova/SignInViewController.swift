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
    @IBAction func forgetPasswordButtonClicked(_ sender: UIButton) {
    }
    @IBOutlet weak var logInButton: UIButton!
    @IBAction func logInButtonClicked(_ sender: UIButton) {
        UserManager.shared.signIn(email: usernameTextField.text, password: passwordTextField.text, withCompletion: { error in
            if error == nil {
                // Success
                self.errorLabel.text = " "
                let tc = self.storyboard?.instantiateViewController(withIdentifier: "MyTabBarController") as! MyTabBarController
                self.navigationController?.setViewControllers([tc], animated: false)
            } else {
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
        usernameTextField.leftView = paddingView1
        usernameTextField.leftViewMode = .always
        usernameTextField.placeholder = "E-mail"
        usernameTextField.layer.cornerRadius = 22.5
        usernameTextField.layer.masksToBounds = true
        
        let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: passwordTextField.frame.height))
        passwordTextField.leftView = paddingView2
        passwordTextField.leftViewMode = .always
        passwordTextField.placeholder = "Password"
        passwordTextField.layer.cornerRadius = 22.5
        passwordTextField.layer.masksToBounds = true
        
        // Error label configs
        errorLabel.font = Fonts.SignupVC.Labels.errorLabelFont()
        errorLabel.textColor = Colors.LoginVC.Labels.errorLabelTextColor()
        errorLabel.text = " " // Set to " " instead of "" to hold the height constraint
        
        // Log in / Sign up buttons configs
        logInButton.layer.cornerRadius = 22.5
        logInButton.layer.masksToBounds = true
        logInButton.layer.borderColor = Colors.LoginVC.Buttons.loginButtonColor().cgColor
        logInButton.layer.borderWidth = 1.0
        logInButton.layer.backgroundColor = UIColor.clear.cgColor
        
        let loginTitle = NSMutableAttributedString(string: "Log in", attributes: [
            NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 17.0)!,
            NSForegroundColorAttributeName: Colors.LoginVC.Buttons.loginButtonColor(),
            NSKernAttributeName: -0.38
            ])
        loginTitle.addAttribute(NSKernAttributeName, value: -0.36, range: NSRange(location: 5, length: 1))
        
        logInButton.setAttributedTitle(loginTitle, for: .normal)
        
        signUpButton.layer.cornerRadius = 22.5
        signUpButton.layer.masksToBounds = true
        signUpButton.layer.borderColor = Colors.LoginVC.Buttons.signupButtonColor().cgColor
        signUpButton.layer.borderWidth = 1.0
        signUpButton.layer.backgroundColor = Colors.LoginVC.Buttons.signupButtonColor().cgColor
        
        let signupTitle = NSMutableAttributedString(string: "Sign up", attributes: [
            NSFontAttributeName: UIFont(name: "Montserrat-Regular", size: 17.0)!,
            NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 1.0),
            NSKernAttributeName: -0.38
            ])
        signupTitle.addAttribute(NSKernAttributeName, value: -0.36, range: NSRange(location: 6, length: 1))
        
        signUpButton.setAttributedTitle(signupTitle, for: .normal)
        
        // Record Constraint
        bottomConstraintConstant = bottomConstraint.constant
        
        // Configs
        navigationController?.setNavigationBarHidden(true, animated: false)
        
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
