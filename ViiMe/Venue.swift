//
//  Venue.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-12.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import Firebase

struct Venue {
    var name : String
    var id : String
    var price : String
    var code : String
    var cuisine : String
    var type : String
    var address : String
    var description : String
    var distance : String
    var logo : String
    var website : String
    var number : String
    var dealIds: Dictionary<String, Bool>
    var deals : [Deal]
    
    init(snapshot: DataSnapshot) {
        let value = snapshot.value as? NSDictionary
        name = value?["name"] as? String ?? ""
        id = value?["id"] as? String ?? ""
        price = value?["price"] as? String ?? ""
        code = value?["code"] as? String ?? ""
        cuisine = value?["cuisine"] as? String ?? ""
        type = value?["type"] as? String ?? ""
        address = value?["address"] as? String ?? ""
        description = value?["description"] as? String ?? ""
        distance = ""
        website = value?["website"] as? String ?? " "
        number = value?["number"] as? String ?? " "
        logo = value?["logo"] as? String ?? ""
        dealIds = value?["deals"] as? Dictionary<String, Bool> ?? [:]
        deals = []
    }
    
}


