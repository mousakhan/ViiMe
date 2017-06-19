//
//  ValidationHelper.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-06-12.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class ValidationHelper {
    /**
     Ensures email are in a valid format and the username textfield is not empty.
     - Parameters: None
     - Returns: Nothing
     */
    static func validateEmail(textfield: UITextField) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if textfield.text == nil || textfield.text!.characters.count == 0 {
            BannerHelper.showBanner(title: "Please Enter an Email Address", type: .danger)
            return false
        } else if !emailTest.evaluate(with: textfield.text!) {
            BannerHelper.showBanner(title: "Please Enter an Valid Email Address", type: .danger)
            return false
        }
        
        return true
    }
    
    static func validateName(textfield: UITextField) -> Bool {
        var isValidName = false
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        if textfield.text!.rangeOfCharacter(from: characterset.inverted) != nil {
            isValidName = true
        }
        
        if textfield.text == nil || textfield.text!.characters.count == 0 {
            let banner = NotificationBanner(title:"Please enter your name.", subtitle: "Please try again", style: .danger)
            banner.show()
            return false
        } else if isValidName {
            let banner = NotificationBanner(title:"Please enter a valid name with no special characters.", subtitle: "Please try again", style: .danger)
            banner.show()
            return false
        }
        
        return true
    }
    
    
}
