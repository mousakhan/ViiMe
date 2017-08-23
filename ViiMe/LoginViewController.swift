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

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var facebookSignInButton: FBSDKLoginButton!
    @IBOutlet weak var signInButton: UIButton!
    
    var token = Messaging.messaging().fcmToken
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Set up
        TextFieldHelper.addIconToTextField(imageName: "email.png", textfield: usernameTextField)
        TextFieldHelper.addIconToTextField(imageName: "password.png", textfield: passwordTextField)
        createFacebookButton()
        
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        self.activityIndicator.center = self.view.center;
        self.view.addSubview(activityIndicator)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Check if user is logged in with Facebook
        if ((FBSDKAccessToken.current()) != nil) {
            // If so, log them into firebase with the credential
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                // Add their id to user defaults for future use
                let userId = UserDefaults.standard.object(forKey: "uid") as? String
                if (userId != "") {
                    if let id = Auth.auth().currentUser?.uid {
                        UserDefaults.standard.set(id, forKey: "uid")
                        UserDefaults.standard.synchronize()
                    }
                }
                
                // Add their FCM ID to the back-end for push notifications
                self.token = Messaging.messaging().fcmToken
                if (self.token != nil) {
                    Constants.refs.users.child("\(user!.uid)/notifications").setValue([self.token!: true])
                }
                // User is logged in, go to the venues page
                self.performSegue(withIdentifier: "HomeViewControllerSegue", sender: nil)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        Auth.auth().addStateDidChangeListener { auth, user in
            // Check if user is logged in, and if their email is actually verified
            if user != nil && user!.isEmailVerified {
                // Add their id to user defaults for future use
                let userId = UserDefaults.standard.object(forKey: "uid") as? String
                if (userId != "") {
                    if let id = Auth.auth().currentUser?.uid {
                        UserDefaults.standard.set(id, forKey: "uid")
                        UserDefaults.standard.synchronize()
                    }
                }
                // Add their FCM ID to the back-end for push notifications
                self.token = Messaging.messaging().fcmToken
                if (self.token != nil) {
                    Constants.refs.users.child("\(user!.uid)/notifications").setValue([self.token!: true])
                }
                self.performSegue(withIdentifier: "HomeViewControllerSegue", sender: nil)
            } else {
                // No User is signed in. Show user the login screen
            }
        }
    }
    
    
    //MARK: IBActions
    @IBAction func login(_ sender: Any) {
        let email = usernameTextField.text!
        let password = passwordTextField.text!
        
        activityIndicator.startAnimating()
        // Check if the email is valid
        if ValidationHelper.validateEmail(textfield: usernameTextField) {
            // Sign in
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                // Show error if there is one
                if let error = error {
                    BannerHelper.showBanner(title: error.localizedDescription, type: .danger)
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                    

                    return
                }
                // If they try to log in but their email is not verified, then show an alert asking them to verify
                // and re-send if necessary
                if !(user?.isEmailVerified)! {
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular),
                        kTextFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                        kButtonFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                        showCloseButton: false,
                        showCircularIcon: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    alertView.addButton("Resend", backgroundColor: FlatPurple(), action: {
                        user?.sendEmailVerification(completion: nil)
                    })
                    alertView.addButton("Cancel", backgroundColor: FlatRed(), action: {
                    })
                    alertView.showInfo("Error", subTitle: "Sorry. Your email address has not yet been verified. Do you want us to send another verification email to \(email)?")
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()

                    }
                } else {
                    // All is well, go to the next view controller and add their FCM token to the back-end
                    if (self.token != nil) {
                        Constants.refs.users.child("\(user!.uid)/notifications").setValue([self.token!: true])
                    }
                    
                    // Add their id to user defaults for future use
                    let userId = UserDefaults.standard.object(forKey: "uid") as? String
                    if (userId != "") {
                        if let id = Auth.auth().currentUser?.uid {
                            UserDefaults.standard.set(id, forKey: "uid")
                            UserDefaults.standard.synchronize()
                        }
                    }
                    self.activityIndicator.stopAnimating()
                    
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
        
        // If 'Done' button is clicked, then return
        if result.isCancelled {
            return
        }
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        
        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            
            // Show error if there is any and exit
            if error != nil {
                BannerHelper.showBanner(title: error!.localizedDescription, type: .danger)
                return
            }
            
            
            // Show alert for them to add a username. Essentially to add friends and search for them,
            // we're doing it by username. So if someone uses FB to sign in, we need them to create a username
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont.systemFont(ofSize: 20, weight: UIFontWeightRegular),
                kTextFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                kButtonFont: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular),
                showCloseButton: false,
                showCircularIcon: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            let usernameTextField = alertView.addTextField("Enter a username")
            
            
            Constants.refs.users.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                // Check if the user already exists in our database.
                if !(snapshot.hasChild("\(user!.uid)")){
                    // If not, then show alert
                    alertView.addButton("Create Account") {
                        // Check to see if there are any username validation issues
                        let userValidation = ValidationHelper.validateUsername(textfield: usernameTextField)
                        // If so, show them
                        if (userValidation != "") {
                            BannerHelper.showBanner(title: userValidation, type: .danger)
                        } else {
                            // If not, add the user to the database with the info
                            Constants.refs.users.child("\(user!.uid)").setValue(["username": "\(usernameTextField.text!)", "name": user!.displayName ?? "", "age": "", "email": user!.email ?? "", "id": user!.uid, "profile": user!.photoURL?.absoluteString ?? "" ])
                            
                            // Add their FCM token to the database as well for notifications
                            if (self.token != nil) {
                                Constants.refs.users.child("\(user!.uid)/notifications").setValue([self.token!: true])
                            }
                            // Segue
                            self.performSegue(withIdentifier: "HomeViewControllerSegue", sender: nil)
                        }
                    }
                    
                    alertView.addButton("Cancel", backgroundColor: FlatRed())   {
                        // If they cancel, then sign them out since they may still sign in without creating a username
                        
                        // Signing them out of Firebase
                        let firebaseAuth = Auth.auth()
                        do {
                            try firebaseAuth.signOut()
                        } catch let signOutError as NSError {
                            print ("Error signing out: %@", signOutError)
                        }
                        
                        // Sign them out of FB
                        let loginManager = FBSDKLoginManager()
                        loginManager.logOut()
                    }
                    
                    // Show alert
                    DispatchQueue.main.async {
                        alertView.showInfo("Username", subTitle: "Please enter a username to be used in the application. The username cannot start or end with -, _, . or a number, can contain no white spaces, emojis, or special characters and must be 3-15 characters long")
                    }
                    
                    
                } else {
                    
                    // Add their id to user defaults for future use
                    let userId = UserDefaults.standard.object(forKey: "uid") as? String
                    if (userId != "") {
                        if let id = Auth.auth().currentUser?.uid {
                            UserDefaults.standard.set(id, forKey: "uid")
                            UserDefaults.standard.synchronize()
                        }
                    }
                    // Add their FCM ID to the back-end for push notifications
                    self.token = Messaging.messaging().fcmToken
                    if (self.token != nil) {
                        Constants.refs.users.child("\(user!.uid)/notifications").setValue([self.token!: true])
                    }
                    
                    // If the user exists, then just segue!
                    self.performSegue(withIdentifier: "HomeViewControllerSegue", sender: nil)
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




