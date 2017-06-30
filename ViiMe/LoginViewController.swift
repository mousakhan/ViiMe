//
//  LoginViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-06-09.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FacebookLogin
import FBSDKLoginKit
import NotificationBannerSwift

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate{
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var facebookSignInButton: FBSDKLoginButton!
    @IBOutlet weak var signInButton: UIButton!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookSignInButton.delegate = self
        ref = Database.database().reference()
        
        TextFieldHelper.addIconToTextField(imageName: "email.png", textfield: usernameTextField)
        TextFieldHelper.addIconToTextField(imageName: "password.png", textfield: passwordTextField)
        createFacebookButton()
        
        if ((FBSDKAccessToken.current()) != nil) {
            // User is logged in, do work such as go to next view controller.
        }
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // IBActions
    @IBAction func login(_ sender: Any) {
        let email = usernameTextField.text!
        let password = passwordTextField.text!
        
//        if ValidationHelper.validateEmail(textfield: usernameTextField) {
//        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
//            
//            if let error = error {
//                BannerHelper.showBanner(title: error.localizedDescription, type: .danger)
//                return
//            } else {
//                if !(user?.isEmailVerified)! {
//                    let alertVC = UIAlertController(title: "Error", message: "Sorry. Your email address has not yet been verified. Do you want us to send another verification email to \(email)?", preferredStyle: .alert)
//                    let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
//                        (_) in
//                        user?.sendEmailVerification(completion: nil)
//                    }
//                    let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//                    
//                    alertVC.addAction(alertActionOkay)
//                    alertVC.addAction(alertActionCancel)
//                    self.present(alertVC, animated: true, completion: nil)
//                } else {
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VenuesNavigation") as! UINavigationController
                    self.present(nextViewController, animated:true, completion:nil)
//                }
//            }
//        }
//        }
        
    }
    
    // UITextFieldDelegate Functions and functions relating to textfields
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if (textField == usernameTextField) {
            passwordTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            passwordTextField.resignFirstResponder()
            login(self)
        }
        // Do not add a line break
        return false
    }
    
    // Specifically to remove keyboard when not interacting with textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Helper Functions
    func createFacebookButton() {
        //NOTE: This is hack-ish, might change in the future, so should be careful
        //Remove constraint that restricts height of facebook button.
        let layoutConstraintsArr = facebookSignInButton.constraints
        for lc in layoutConstraintsArr { // or attribute is NSLayoutAttributeHeight etc.
            if ( lc.constant == 28 ){
                // Then disable it...
                lc.isActive = false
                break
            }
        }
        
        let titleText = NSAttributedString(string: "Log In with Facebook")
        facebookSignInButton.setAttributedTitle(titleText, for: .normal)
        facebookSignInButton.layer.borderWidth = 1.0;
        facebookSignInButton.layer.borderColor = UIColor.black.cgColor;
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        // ...
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                BannerHelper.showBanner(title: error!.localizedDescription, type: .danger)
                return
            }
            
            self.ref.child("users").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                
                if !(snapshot.hasChild("\(user!.uid)")){
                    self.ref.child("users/\(user!.uid)").setValue(["name": user!.displayName, "age": "", "email": user!.email, "id": user!.uid])
                }
            })
            
        
            
        }
    }

    
            // User is signed in
            // ...
        
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    

}
    



