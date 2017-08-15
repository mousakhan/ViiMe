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
import SCLAlertView
import ChameleonFramework

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate{
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var facebookSignInButton: FBSDKLoginButton!
    @IBOutlet weak var signInButton: UIButton!
    var ref: DatabaseReference!
    var token = Messaging.messaging().fcmToken
    
    // View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        TextFieldHelper.addIconToTextField(imageName: "email.png", textfield: usernameTextField)
        TextFieldHelper.addIconToTextField(imageName: "password.png", textfield: passwordTextField)
        createFacebookButton()
        
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // User is logged in
        if ((FBSDKAccessToken.current()) != nil) {
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                self.token = Messaging.messaging().fcmToken
                if (self.token != nil) {
                    self.ref.child("users/\(user!.uid)/notifications").setValue([self.token!: true])
                }
                
                // User is logged in, do work such as go to next view controller.
                self.performSegue(withIdentifier: "VenuesView", sender: nil)
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref = Database.database().reference()
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil && user!.isEmailVerified {
                self.token = Messaging.messaging().fcmToken
                if (self.token != nil) {
                    self.ref.child("users/\(user!.uid)/notifications").setValue([self.token!: true])
                }
                self.performSegue(withIdentifier: "VenuesView", sender: nil)
            } else {
                // No User is signed in. Show user the login screen
            }
        }
    }
    
    
    //MARK: IBActions
    @IBAction func login(_ sender: Any) {
        let email = usernameTextField.text!
        let password = passwordTextField.text!
        if ValidationHelper.validateEmail(textfield: usernameTextField) {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    BannerHelper.showBanner(title: error.localizedDescription, type: .danger)
                    return
                } else {
                    if !(user?.isEmailVerified)! {
                        let alertVC = UIAlertController(title: "Error", message: "Sorry. Your email address has not yet been verified. Do you want us to send another verification email to \(email)?", preferredStyle: .alert)
                        let alertActionOkay = UIAlertAction(title: "Okay", style: .default) {
                            (_) in
                            user?.sendEmailVerification(completion: nil)
                        }
                        let alertActionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                        
                        alertVC.addAction(alertActionOkay)
                        alertVC.addAction(alertActionCancel)
                        self.present(alertVC, animated: true, completion: nil)
                    } else {
                        if (self.token != nil) {
                            self.ref.child("users/\(user!.uid)/notifications").setValue([self.token!: true])
                        }
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VenuesNavigation") as! UINavigationController
                        self.present(nextViewController, animated:true, completion:nil)
                    }
                }
            }
        }
        
    }
    
    //MARK: UITextFieldDelegate Functions
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
    

    //MARK: FB Delegate Functions
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        
        if result.isCancelled {
            return
        }
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print(error!)
                BannerHelper.showBanner(title: error!.localizedDescription, type: .danger)
                return
            }
      
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular),
                kTextFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                kButtonFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                showCloseButton: false,
                showCircularIcon: false
            )
            
            
            let alertView = SCLAlertView(appearance: appearance)
            
            
            self.ref.child("users").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                
                // Check if the user already exists in our database.
                if !(snapshot.hasChild("\(user!.uid)")){
                    let usernameTextField = alertView.addTextField("Enter a username")
                    alertView.addButton("Create Account") {
                        let userValidation = ValidationHelper.validateUsername(textfield: usernameTextField)
                        if (userValidation != "") {
                            BannerHelper.showBanner(title: userValidation, type: .danger)
                        } else {
                            self.ref.child("users/\(user!.uid)").setValue(["username": "\(usernameTextField.text!)", "name": user!.displayName ?? "", "age": "", "email": user!.email ?? "", "id": user!.uid, "profile": user!.photoURL?.absoluteString ?? "" ])
                            
                            if (self.token != nil) {
                                self.ref.child("users/\(user!.uid)/notifications").setValue([self.token!: true])
                            }
                            self.performSegue(withIdentifier: "VenuesView", sender: nil)
                        }
                    }
                    
                    alertView.addButton("Cancel", backgroundColor: FlatRed())   {
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                        } catch let signOutError as NSError {
                            print ("Error signing out: %@", signOutError)
                        }
                        
                        let loginManager = FBSDKLoginManager()
                        loginManager.logOut()
                    }
                    
                    DispatchQueue.main.async {
                        alertView.showInfo("Username", subTitle: "Please enter a username to be used in the application. The username cannot start or end with -, _, . or a number, can contain no white spaces, emojis, or special characters and must be 3-15 characters long")
                    }
                    
                    
                } else {
                    self.performSegue(withIdentifier: "VenuesView", sender: nil)
                }

            })

            
            
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    // MARK: Helper Functions
    func createFacebookButton() {
        //NOTE: This is hack-ish, might change in the future, so should be careful.
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
        facebookSignInButton.delegate = self
    }
    
}




