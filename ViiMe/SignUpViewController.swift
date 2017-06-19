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
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var ref: DatabaseReference!
    
    
    
    @IBOutlet weak var cancelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origImage = UIImage(named: "cancel.png")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(tintedImage, for: .normal)
        cancelButton.tintColor = UIColor.white
        
        
        
        ref = Database.database().reference()
        nameTextField.delegate = self
        TextFieldHelper.addIconToTextField(imageName: "name.png", textfield: nameTextField)
        TextFieldHelper.addIconToTextField(imageName: "age.png", textfield: ageTextField)
        TextFieldHelper.addIconToTextField(imageName: "email.png", textfield: emailTextField)
        TextFieldHelper.addIconToTextField(imageName: "password.png", textfield: passwordTextField)
        ageTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(hideKeyboard(sender:)))
        
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
        
     
    }
    
 
    // MARK: TextField Delegate
    func hideKeyboard(sender: AnyObject) {
        nameTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    
    // MARK: TextField Delegate
    func datePickerChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        ageTextField.text = formatter.string(from: sender.date)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField === self.ageTextField) {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            textField.inputView = datePicker
            datePicker.addTarget(self, action: #selector(datePickerChanged(sender:)), for: .valueChanged)
        }
    }
    
    // UITextFieldDelegate Functions and functions relating to textfields
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if (textField == nameTextField) {
            ageTextField.becomeFirstResponder()
        } else if (textField == ageTextField) {
            ageTextField.becomeFirstResponder()
        } else if (textField == emailTextField) {
            emailTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            signUp(self)
        }
        // Do not add a line break
        return false
    }
    


    @IBAction func signUp(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if ValidationHelper.validateName(textfield: nameTextField) && ValidationHelper.validateEmail(textfield: emailTextField) {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    BannerHelper.showBanner(title: error.localizedDescription, type: .danger)
                    return
                } else {
                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                        if error != nil {
                            BannerHelper.showBanner(title: error!.localizedDescription, type: .danger)
                        } else {
                            BannerHelper.showBanner(title: "Email Verification Sent.", type: .success)
                            self.ref.child("users/(user.uid)").setValue(["name": self.nameTextField.text!, "age": self.ageTextField.text!, "email": self.emailTextField.text!, "id": user?.uid])
                            self.dismiss(animated: true, completion: {
                            })
                        }
                    }
                }
            }
        }
    }
    
    
}
