//
//  Constants.swift
//  ViiMe
//
//  Created by Mousa Khan on 2017-08-15.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import Firebase

struct Constants
{
    struct refs
    {
        static let root = Database.database().reference()
        static let users = root.child("users")
        static let groups = root.child("groups")
        static let venues = root.child("venue")
        static let deals = root.child("deal")
    }
    
    static func getUserId() -> String {
        // Grab uid in defaults
        if let userId = UserDefaults.standard.object(forKey: "uid") as? String {
            return userId
        }
        return ""
    }
}
