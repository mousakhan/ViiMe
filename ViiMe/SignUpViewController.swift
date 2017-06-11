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

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
        ageTextField.delegate = self
     
    }
    
    func containsSwearWord(text: String, swearWords: [String]) -> Bool {
        return swearWords
            .reduce(false) { $0 || text.contains($1.lowercased()) }
    }
    

    
    
    
    // MARK: TextField Delegate
    func datePickerChanged(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    

    
    @IBAction func signUp(_ sender: Any) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        
        
        if validateName() && validateEmail() {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    let banner = NotificationBanner(title: error.localizedDescription, subtitle: "Please try again", style: .danger)
                    banner.show()
                    return
                } else {
                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                        
                    }
                }
            }
        }
    }
    
    
    func validateName() -> Bool {
        if nameTextField.text == nil || nameTextField.text!.characters.count == 0 {
            let banner = NotificationBanner(title:"Please enter your name.", subtitle: "Please try again", style: .danger)
            banner.show()
            return false
        } else if numbersInString(textField: nameTextField) {
            let banner = NotificationBanner(title:"Please enter a valid name with no special characters.", subtitle: "Please try again", style: .danger)
            banner.show()
            return false
        }
        
        return true
    }
    
    func numbersInString(textField: UITextField) -> Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        if textField.text!.rangeOfCharacter(from: characterset.inverted) != nil {
            return true
        }
        return false
    }
    
    func validateEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if emailTextField.text == nil || emailTextField.text!.characters.count == 0 {
            let banner = NotificationBanner(title:"Please enter an email address.", subtitle: "Please try again", style: .danger)
            banner.dismiss()
            banner.show()
            return false
        } else if !emailTest.evaluate(with: emailTextField.text!) {
            
            let banner = NotificationBanner(title:"Please enter a valid email address.", subtitle: "Please try again", style: .danger)
            banner.dismiss()
            banner.show()
            
            return false
        }
        
        return true
    }
    
}
