//
//  ForgotPasswordViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-06-10.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import FirebaseAuth
import NotificationBannerSwift

class ForgotPasswordViewController: UIViewController {


    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func resetPassword(_ sender: Any) {
        let email = emailTextField.text!
        
        if validateEmail() {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                let banner = NotificationBanner(title:error.localizedDescription, subtitle: "Please try again", style: .danger)
                banner.show()
            } else {
                self.dismiss(animated: true, completion: nil)
                let banner = NotificationBanner(title:"Password Reset Email Sent", subtitle: "Please check your inbox", style: .success)
                banner.show()
            }
            }
        }
        
    }
    
    func validateEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if emailTextField.text == nil || emailTextField.text!.characters.count == 0 {
            let banner = NotificationBanner(title:"Please enter an email address.", subtitle: "Please try again", style: .danger)
            banner.show()
            return false
        } else if !emailTest.evaluate(with: emailTextField.text!) {
            
            let banner = NotificationBanner(title:"Please enter a valid email address.", subtitle: "Please try again", style: .danger)
            banner.show()
            
            return false
        }
        
        return true
    }
    
}
