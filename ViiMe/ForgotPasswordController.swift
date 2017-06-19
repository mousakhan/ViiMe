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

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {


    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var cancelButton: UIButton!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let origImage = UIImage(named: "cancel.png")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        cancelButton.setImage(tintedImage, for: .normal)
        cancelButton.tintColor = UIColor.white
        
        
        emailTextField.delegate = self
        TextFieldHelper.addIconToTextField(imageName: "email.png", textfield: emailTextField)
    }
    
    
    @IBAction func resetPassword(_ sender: Any) {
        let email = emailTextField.text!
        
        if ValidationHelper.validateEmail(textfield: emailTextField) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                BannerHelper.showBanner(title: error.localizedDescription, type: .danger)
            } else {
                self.dismiss(animated: true, completion: nil)
                BannerHelper.showBanner(title: "Password Reset Email Sent", type: .success)
            }
            }
        }
        
    }
    
    // UITextFieldDelegate Functions and functions relating to textfields
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        resetPassword(self)
        return false
    }
    
    // Specifically to remove keyboard when not interacting with textfield
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
}
