//
//  BannerHelper.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-06-12.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class BannerHelper {

    static func showBanner(title: String, type: BannerStyle) {
        
        let numberOfBanners = NotificationBannerQueue.default.numberOfBanners
        
        if (numberOfBanners == 0) {
            var icon = UIImage()
            
            if (type == .danger) {
                icon = UIImage(named:"error.png")!
            } else if (type == .success) {
                icon = UIImage(named:"checkmark.png")!
            }
            
            
            icon = icon.withRenderingMode(.alwaysTemplate)
            let leftView = UIImageView(image: icon)
            leftView.tintColor = UIColor.white
            let banner = NotificationBanner(title: title, leftView: leftView, style: type)
            banner.show() 
        }
    }

    
    
}
