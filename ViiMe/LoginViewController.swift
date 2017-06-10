//
//  LoginViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-06-09.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import Firebase
import FacebookLogin

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    let email = ""
    let password = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = LoginButton(readPermissions: [ .publicProfile ])
        loginButton.center = view.center
        
        
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: usernameTextField.frame.size.height - width, width:  usernameTextField.frame.size.width, height: usernameTextField.frame.size.height)
        border.borderWidth = width
        usernameTextField.layer.addSublayer(border)
        usernameTextField.layer.masksToBounds = true
        
        
        view.addSubview(loginButton)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Checks if username is proper
    func validateEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

        if usernameTextField.text == nil || usernameTextField.text!.characters.count == 0 {
            errorLabel.text =  "Please enter an email address."
            return false
        } else if !emailTest.evaluate(with: usernameTextField.text!) {
            errorLabel.text =  "Please enter a valid email address."
            return false
        }
        
        return true
    }
    
    
    @IBAction func login(_ sender: Any) {
        let email = usernameTextField.text!
        let password = passwordTextField.text!
        
        if validateEmail() {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                print(user?.email! ?? "didnt work")
                if let error = error {
                    self.errorLabel.text = error.localizedDescription
                    return
                } else {
                    Auth.auth().currentUser?.sendEmailVerification { (error) in

                    }
                }
            }
        }
    }

}

