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
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        let authClient = AuthenticationClient()
        authClient.authenticate(email: emailTextField.text!, password: passwordTextField.text!) { (authToken, error) in
            if let error = error {
                NSLog("Error logging in: \(error)")
                
                // show error dialog
                
                
            }
            else {
                NSLog("Got an auth token: \(authToken!)")
                Settings().saveSetting(key: Settings.ningoReadwriteApiTokenKey, value: authToken!)
                Settings().saveSetting(key: Settings.ningoLoginTimeMillis, value: String(Int(Date().timeIntervalSince1970*1000)))
                
                
                // dismiss vc on ui thread
                
                
                
                
            }
        }
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
    }
}
