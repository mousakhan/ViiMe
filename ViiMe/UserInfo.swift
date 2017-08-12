//
//  User.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-29.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import Foundation

struct UserInfo {
    var username : String
    var name : String
    var id: String
    var age : String
    var email : String
    var gender : String
    var profile : String
    var status : String? = ""
    var groups : Dictionary<String, Any>
    var friends : Array<String>
}
