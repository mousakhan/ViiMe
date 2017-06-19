//
//  TextFieldHelper.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-06-12.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit

class TextFieldHelper {
    static func addIconToTextField(imageName: String, textfield: UITextField) {
        let leftImageView = UIImageView()
        leftImageView.image = UIImage(named: imageName)
        leftImageView.image = leftImageView.image?.withRenderingMode(.alwaysTemplate)
        leftImageView.tintColor = UIColor.darkGray
        
        let leftView = UIView()
        leftView.addSubview(leftImageView)
        
        
        leftView.frame = CGRect(x: 0, y: 0, width: 30, height: 20)
        leftImageView.frame = CGRect(x: 10, y: 2.5, width: 15, height: 15)
        
        textfield.leftView = leftView
        textfield.leftViewMode = UITextFieldViewMode.always
    }
}
