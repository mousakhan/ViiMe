//
//  Deal.swift
//  ViiMe
//
//  Created by Mousa Khan on 17-07-30.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//


import UIKit
import Firebase

struct Deal {
    var title : String
    var shortDescription : String
    var longDescription : String
    var id : String
    var numberOfPeople : String
    var numberOfRedemptions : String
    var validFrom : String
    var validTo : String
    var recurringFrom : String
    var recurringTo : String
    
    init(snapshot: DataSnapshot) {
        let value = snapshot.value as? NSDictionary
        title = value?["title"] as? String ?? ""
        shortDescription = value?["short-description"] as? String ?? ""
        longDescription = value?["long-description"] as? String ?? ""
        numberOfPeople = value?["number-of-people"] as? String ?? ""
        numberOfRedemptions = value?["num-redemptions"] as? String ?? ""
        id = value?["id"] as? String ?? ""
        validFrom = value?["valid-from"] as? String ?? ""
        validTo = value?["valid-to"] as? String ?? ""
        recurringFrom = value?["recurring-from"] as? String ?? ""
        recurringTo = value?["recurring-to"] as? String ?? ""
    }
    
    
    func getDict() -> [String:String] {
        let dict = ["title": title,
                    "short-description": shortDescription,
                    "long-description": longDescription,
                    "id": id,
                    "number-of-people": numberOfPeople,
                    "num-redemptions": numberOfRedemptions,
                    "valid-from": validFrom,
                    "valid-to": validTo,
                    "recurring-from": recurringFrom,
                    "recurring-to": recurringTo
        ]
        
        return dict
    }
}
