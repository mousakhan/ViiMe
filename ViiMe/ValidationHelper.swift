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
            BannerHelper.showBanner(title: "Please enter an email address", type: .danger)
            return false
        } else if !emailTest.evaluate(with: textfield.text!) {
            BannerHelper.showBanner(title: "Please enter a valid email address", type: .danger)
            return false
        }
        
        return true
    }
    
}
