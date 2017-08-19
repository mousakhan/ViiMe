//
//  User.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-29.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import Firebase

struct UserInfo {
    var username : String
    var name : String
    var id: String
    var age : String
    var email : String
    var gender : String
    var profile : String
    var status : String
    var groups : [Group]
    var groupIds : Dictionary<String, Bool>
    var friends : [UserInfo]
    var friendIds : Dictionary<String, Bool>
    var personalDealIds : Dictionary<String, Bool>
    var personalDeals : [Deal]
    var notifications: Dictionary<String, Bool>
    
    init(snapshot: DataSnapshot) {
         let value = snapshot.value as? NSDictionary
         username = value?["username"] as? String ?? ""
         name = value?["name"] as? String ?? ""
         id = value?["id"] as? String ?? ""
         age = value?["age"] as? String ?? ""
         gender = value?["gender"] as? String ?? ""
         email = value?["email"] as? String ?? ""
         profile = value?["profile"] as? String ?? ""
         status = ""
         groupIds = value?["groups"] as? Dictionary<String, Bool> ?? [:]
         groups = []
         friendIds = value?["friends"] as? Dictionary<String, Bool> ?? [:]
         friends = []
         personalDealIds = value?["personal-deals"] as? Dictionary<String, Bool> ?? [:]
         personalDeals = []
         notifications = value?["notifications"] as? Dictionary<String, Bool> ?? [:]
    }
    
}
