//
//  UIView+Border.swift
//  ViiMe
//
//  Created by Mousa Khan on 2017-08-07.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit

extension UIView {
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
}
