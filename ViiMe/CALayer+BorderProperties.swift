//
//  CALayer+BorderProperties.swift
//  ViiMe
//
//  Created by Mousa Khan on 2017-08-09.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit

extension CALayer {
    var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.cgColor
        }
        
        get {
            return UIColor(cgColor: self.borderColor!)
        }
    }
}
