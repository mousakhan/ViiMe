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
    
    static func validateUsername(textfield: UITextField) -> String {
        
        let text = textfield.text!
    
        if (text.characters.count == 0) {
            return "Please enter a username"
        }
        
        if (text.lowercased() != text) {
            return "The username must be in all lowercase"
        }
        
        // Make sure the first is not ., _, -
        let firstChar = text.characters.first!
        if (firstChar == "." || firstChar == "_" || firstChar == "-") {
            return "The username cannot start with - _ ."
        }
        // Check if it begins with a letter, if not, return false
        if (CharacterSet.decimalDigits.contains(text.unicodeScalars.first!)) {
            return "The username cannot start with a number"
        }
        
        // Must be 3-15 characters
        if text.characters.count < 3 || text.characters.count > 15 {
            return "The username must be between 3-15 characters"
        }
        
        // No whitspace
        let whitespace = NSCharacterSet.whitespaces
        let range = text.rangeOfCharacter(from: whitespace)
        if range != nil {
             return "The username cannot contain any whitespaces"
        }
        
        // Make sure the last letter is not ., _, -
        let lastChar = text.characters.last!
        if (lastChar == "." || lastChar == "_" || lastChar == "-") {
            return "The username cannot end with - _ ."
        }
        

        
        // Make sure there is no emoji
        if (text.containsEmoji) {
            return "Please no emojis in the user"
        }
        
        // Make sure there are no special characters besides the ones wanted
        let tmp = text.lowercased()
        let charset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvxyz-._0123456789")
        if tmp.rangeOfCharacter(from: charset) == nil {
            return "The username may only contain letters, numbers, and - _ ."
        }
        
        
        return ""
    }
    
}
