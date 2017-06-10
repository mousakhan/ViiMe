//
//  ForgotPasswordViewController.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-06-10.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {


    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorTextLabel: UILabel!
    @IBAction func resetPassword(_ sender: Any) {
        let email = emailTextField.text!
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                self.errorTextLabel.text = error.localizedDescription
            } else {
                
            }
        }
        
    }
}
