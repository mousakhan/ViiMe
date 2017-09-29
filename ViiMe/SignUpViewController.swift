//
//  SignUpViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-06-11.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import FirebaseAuth
import NotificationBannerSwift
import FirebaseDatabase
import ChameleonFramework

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var signupButton: UIButton!

    @IBOutlet weak var termsOfCondtionsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change color of icon button, could probably make this into it's own helper function
        let origImage = UIImage(named: "cancel.png")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(tintedImage, for: .normal)
        cancelButton.tintColor = UIColor.white
        
        TextFieldHelper.addIconToTextField(imageName: "username.png", textfield: self.usernameTextField)
        TextFieldHelper.addIconToTextField(imageName: "name.png", textfield: nameTextField)
        TextFieldHelper.addIconToTextField(imageName: "email.png", textfield: emailTextField)
        TextFieldHelper.addIconToTextField(imageName: "password.png", textfield: passwordTextField)
        TextFieldHelper.addIconToTextField(imageName: "password.png", textfield: confirmPasswordTextField)
        
        nameTextField.delegate = self

        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        
        // If click anywhere outside the texfields, hide keyboard
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard(sender:)))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
        
        let termsText = "By signing up, you agree to our terms of service and privacy policy"
        let termsGesture = UITapGestureRecognizer(target: self, action: #selector(openTerms(sender:)))
        termsOfCondtionsLabel.addGestureRecognizer(termsGesture)
        
        let attributedString = NSMutableAttributedString(string:termsText)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: FlatSkyBlue() , range: NSRange(location: 31, length: 36) )
        termsOfCondtionsLabel.attributedText = attributedString
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        enableSignUpButton()
        
   
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enableSignUpButton()
    }
    
    func keyboardWillShow(notification:NSNotification){
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    

    
    // MARK: UITextFieldDelegate Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if (textField == usernameTextField) {
            nameTextField.becomeFirstResponder()
        } else if (textField == nameTextField) {
            emailTextField.becomeFirstResponder()
        } else if (textField == emailTextField) {
            passwordTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            confirmPasswordTextField.becomeFirstResponder()
        } else if (textField == confirmPasswordTextField) {
            signUp(self)
            confirmPasswordTextField.resignFirstResponder()
        }
        
        return false
    }

    // MARK: IBActions
    @IBAction func signUp(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let confirmation = confirmPasswordTextField.text!
        signUpButtonLoading()
        
        if (password != confirmation) {
            BannerHelper.showBanner(title: "Passwords do not match. Please re-enter.", type: .danger)
            enableSignUpButton()
            return
        }
        
        if (self.usernameTextField.text == "") {
            BannerHelper.showBanner(title: "Please enter a username", type: .danger)
            enableSignUpButton()
            return
        }
      
        let userValidation = ValidationHelper.validateUsername(textfield: self.usernameTextField)
        checkIfUserNameIsUnique(username: self.usernameTextField.text!) { (isUnique) in
            if (isUnique) {
                // Check to see if there are any username validation issues
                if (userValidation != "") {
                    // Present them if there are
                    BannerHelper.showBanner(title: userValidation, type: .danger)
                    self.enableSignUpButton()
                } else {
                    // No username validation issues, now check email address for any issues
                    if ValidationHelper.validateEmail(textfield: self.emailTextField) {
                        // Create user if everything is OK
                        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                            if let error = error {
                                // Show error if there is any
                                BannerHelper.showBanner(title: error.localizedDescription, type: .danger)
                                self.enableSignUpButton()
                                return
                            } else {
                                // Send the email verification
                                Auth.auth().currentUser?.sendEmailVerification { (error) in
                                    if error != nil {
                                        // Show error if there is any
                                        BannerHelper.showBanner(title: error!.localizedDescription, type: .danger)
                                        self.enableSignUpButton()
                                    } else {
                                        // Show success message, and then write to the database
                                        BannerHelper.showBanner(title: "Email Verification Sent", type: .success)
                                        let id = user?.uid ?? ""
                                        Constants.refs.users.child(id).setValue(["username": self.usernameTextField.text?.lowercased(), "name": self.nameTextField.text!, "age": "", "email": self.emailTextField.text!, "id": user?.uid])
                                        self.dismiss(animated: true, completion: {})
                                    }
                                }
                            }
                        }
                    }
                    
                }
            } else {
                BannerHelper.showBanner(title: "The username is already in use. Please choose another", type: .danger)
            }
        }
    }
    
    func enableSignUpButton() {
        self.signupButton.isEnabled = true
        self.signupButton.setTitle("SIGN UP", for: .normal)
    }
    
    func signUpButtonLoading() {
        self.signupButton.isEnabled = false
        self.signupButton.setTitle("Signing up...", for: .normal)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helper Functions
    func hideKeyboard(sender: AnyObject) {
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
    }
    
    func openTerms(sender: UITapGestureRecognizer) {
        
        
        let url = URL(string: "http://www.viime.ca/privacy-policy")!
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    // This function will go in the back-end, loop through every user and ensure that the name is unique
    func checkIfUserNameIsUnique(username: String, completionHandler: @escaping (_ isComplete: Bool) -> ()) {
        
        let query =  Constants.refs.users.queryOrdered(byChild: "username").queryEqual(toValue: username)
        
        query.observeSingleEvent(of: .value, with: { snapshot in
                // Username is unique, does not exist on back-end
                if snapshot.value is NSNull {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
                
            })
    }
    
    
    
    
    // Remove observors
    deinit {
        Constants.refs.users.removeAllObservers()
    }

    
}
