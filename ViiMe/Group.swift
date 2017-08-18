//
//  Group.swift
//  ViiMe
//
//  Created by Mousa Khan on 2017-08-09.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit
import Firebase

struct Group {
    var ownerId: String
    var owner: UserInfo? = nil
    var id: String
    var dealId: String
    var deal: Deal? = nil
    var created : Int
    var venueId: String
    var venue: Venue? = nil
    var userIds : Dictionary<String, Bool>
    var users : [UserInfo]
    var redeemed : Bool
    
    init(snapshot: DataSnapshot) {
        let value = snapshot.value as? NSDictionary
        ownerId = value?["owner"] as? String ?? ""
        id = value?["id"] as? String ?? ""
        dealId = value?["deal-id"] as? String ?? ""
        created = value?["created"] as? Int ?? 0
        venueId = value?["venue-id"] as? String ?? ""
        userIds = value?["users"] as? Dictionary<String, Bool> ?? [:]
        users = []
        if (value?["redemptions"] != nil) {
            redeemed = true
        } else {
            redeemed = false
        }
    }
    
}
