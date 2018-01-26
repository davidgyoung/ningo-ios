//
//  LoginViewController.swift
//  NingoSdkReferenceApp
//
//  Created by David G. Young on 1/23/18.
//

import UIKit
import NingoSdk

class LoginViewController : ViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        emailTextField.text = Settings().getSetting(key: Settings.ningoEmailKey) ?? ""
        passwordTextField.text = Settings().getSetting(key: Settings.ningoPasswordKey) ?? ""
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height/2
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height/2
            }
        }
    }
    
    
    @IBAction func signInTapped(_ sender: Any) {
        let authClient = AuthenticationClient()
        authClient.authenticate(email: emailTextField.text!, password: passwordTextField.text!) { (authToken, error) in
            if let error = error {
                NSLog("Error logging in: \(error)")
                
                // show error dialog
                DispatchQueue.main.async {
                    var message = "Inavlid email or password"
                    if error != "Code: 401" {
                        message = error
                    }
                    let alert = UIAlertController(title: "Sign in failed", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
            else {
                NSLog("Got an auth token: \(authToken!)")
                Settings().saveSetting(key: Settings.ningoReadwriteApiTokenKey, value: authToken!)
                Settings().saveSetting(key: Settings.ningoLoginTimeMillis, value: String(Int(Date().timeIntervalSince1970*1000)))
                // dismiss vc on ui thread
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
    }
}
