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
import FBSDKLoginKit
import GoogleSignIn
import NotificationBannerSwift

class LoginViewController: UIViewController, GIDSignInUIDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    @IBOutlet weak var facebookSignInButton: FBSDKLoginButton!
    
    @IBOutlet weak var signInButton: UIButton!
    let email = ""
    let password = ""
    let numberOfBanners = NotificationBannerQueue.default.numberOfBanners
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpEmailTextfield()
        setUpPasswordTextfield()
        createFacebookButton()
        facebookSignInButton.layer.borderWidth = 1.0;
        facebookSignInButton.layer.borderColor = UIColor.black.cgColor;
        
      }
    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /**
     Ensures email are in a valid format and the username textfield is not empty.
     - Parameters: None
     - Returns: Nothing
     */
    func validateEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)

        if usernameTextField.text == nil || usernameTextField.text!.characters.count == 0 {
            self.showBannerWithText(text: "Please Enter Email Address")
            return false
        } else if !emailTest.evaluate(with: usernameTextField.text!) {

            self.showBannerWithText(text: "Please Enter Valid Email Address")
            
            return false
        }
        
        return true
    }
    
    
    func setUpEmailTextfield() {
        let leftImageView = UIImageView()
        leftImageView.image = UIImage(named: "email.png")
        
        let leftView = UIView()
        leftView.addSubview(leftImageView)
        
        
        leftView.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        leftImageView.frame = CGRect(x: 10, y: 2.5, width: 15, height: 15)
        
        usernameTextField.leftView = leftView
        usernameTextField.leftViewMode = UITextFieldViewMode.always
        
    }

    func setUpPasswordTextfield() {
        let leftImageView = UIImageView()
        leftImageView.image = UIImage(named: "password.png")
     
        
        let leftView = UIView()
        leftView.addSubview(leftImageView)
        
        leftView.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        leftImageView.frame = CGRect(x: 10, y: 2.5, width: 15, height: 15)
        
        passwordTextField.leftView = leftView
        passwordTextField.leftViewMode = UITextFieldViewMode.always
        
    }
    
    func createFacebookButton() {
        let layoutConstraintsArr = facebookSignInButton.constraints
        // Iterate over array and test constraints until we find the correct one:
        for lc in layoutConstraintsArr { // or attribute is NSLayoutAttributeHeight etc.
            if ( lc.constant == 28 ){
                // Then disable it...
                lc.isActive = false
                break
            }
        }
        let titleText = NSAttributedString(string: "Log In with Facebook")
        facebookSignInButton.setAttributedTitle(titleText, for: .normal)
    }
    
    @IBAction func forgotPasswordButtonClicked(_ sender: Any) {
     
        
    }
    
    func showBannerWithText(text:String) {
        let numberOfBanners = NotificationBannerQueue.default.numberOfBanners
        let banner = NotificationBanner(title: text, style: .success)
        if (numberOfBanners == 0) {
            banner.show()
        }
    }
    
    @IBAction func login(_ sender: Any) {
        let email = usernameTextField.text!
        let password = passwordTextField.text!
        if validateEmail() {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.showBannerWithText(text: error.localizedDescription)
                return
            } else {
                self.showBannerWithText(text: "Success")
            }
        }
        }
        
    }

}

