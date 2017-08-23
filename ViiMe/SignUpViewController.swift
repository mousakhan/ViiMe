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

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Change color of icon button, could probably make this into it's own helper function
        let origImage = UIImage(named: "cancel.png")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(tintedImage, for: .normal)
        cancelButton.tintColor = UIColor.white
        
        TextFieldHelper.addIconToTextField(imageName: "username.png", textfield: self.usernameTextField)
        TextFieldHelper.addIconToTextField(imageName: "name.png", textfield: nameTextField)
        TextFieldHelper.addIconToTextField(imageName: "age.png", textfield: ageTextField)
        TextFieldHelper.addIconToTextField(imageName: "email.png", textfield: emailTextField)
        TextFieldHelper.addIconToTextField(imageName: "password.png", textfield: passwordTextField)
        TextFieldHelper.addIconToTextField(imageName: "password.png", textfield: confirmPasswordTextField)
        
        nameTextField.delegate = self
        ageTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        usernameTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        
        // If click anywhere outside the texfields, hide keyboard
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard(sender:)))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
   
    }
    

    // MARK: UITextFieldDelegate Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if (textField == usernameTextField) {
            nameTextField.becomeFirstResponder()
        } else if (textField == nameTextField) {
            ageTextField.becomeFirstResponder()
        } else if (textField == ageTextField) {
            emailTextField.becomeFirstResponder()
        } else if (textField == emailTextField) {
            passwordTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            confirmPasswordTextField.becomeFirstResponder()
        } else if (textField == confirmPasswordTextField) {
            signUp(self)
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField === self.ageTextField) {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            textField.inputView = datePicker
            
            // Set max date`
            var components = DateComponents()
            components.year = -16
            let maxDate = Calendar.current.date(byAdding: components, to: Date())
            datePicker.maximumDate = maxDate
            
            
            datePicker.addTarget(self, action: #selector(datePickerChanged(sender:)), for: .valueChanged)
        }
    }
    
    // MARK: IBActions
    @IBAction func signUp(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let confirmation = confirmPasswordTextField.text!
        
        if (password != confirmation) {
            BannerHelper.showBanner(title: "Passwords do not match. Please re-enter.", type: .danger)
            return
        }
        
        if (self.usernameTextField.text == "") {
            BannerHelper.showBanner(title: "Please enter a username", type: .danger)
            return
        }
      
        let userValidation = ValidationHelper.validateUsername(textfield: self.usernameTextField)
        checkIfUserNameIsUnique(username: self.usernameTextField.text!) { (isUnique) in
            if (isUnique) {
                // Check to see if there are any username validation issues
                if (userValidation != "") {
                    // Present them if there are
                    BannerHelper.showBanner(title: userValidation, type: .danger)
                } else {
                    // No username validation issues, now check email address for any issues
                    if ValidationHelper.validateEmail(textfield: self.emailTextField) {
                        // Create user if everything is OK
                        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                            if let error = error {
                                // Show error if there is any
                                BannerHelper.showBanner(title: error.localizedDescription, type: .danger)
                                return
                            } else {
                                // Send the email verification
                                Auth.auth().currentUser?.sendEmailVerification { (error) in
                                    if error != nil {
                                        // Show error if there is any
                                        BannerHelper.showBanner(title: error!.localizedDescription, type: .danger)
                                    } else {
                                        // Show success message, and then write to the database
                                        BannerHelper.showBanner(title: "Email Verification Sent", type: .success)
                                        let id = user?.uid ?? ""
                                        Constants.refs.users.child(id).setValue(["username": self.usernameTextField.text?.lowercased(), "name": self.nameTextField.text!, "age": self.ageTextField.text!, "email": self.emailTextField.text!, "id": user?.uid])
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
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helper Functions
    func hideKeyboard(sender: AnyObject) {
        nameTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
    }
    
    func datePickerChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        ageTextField.text = formatter.string(from: sender.date)
    }
    
    // This function will go in the back-end, loop through every user and ensure that the name is unique
    func checkIfUserNameIsUnique(username: String, completionHandler: @escaping (_ isComplete: Bool) -> ()) {
        
        let query =  Constants.refs.users.queryOrdered(byChild: "username").queryEqual(toValue: username)
        
        query.observe(.value, with: { snapshot in
                // Username is unique, does not exist on back-end
                if snapshot.value is NSNull {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
                
            })
    }
    
     
}
