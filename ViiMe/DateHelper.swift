//
//  DateHelper.swift
//  ViiMe
//
//  Created by Mousa Khan on 2017-08-13.
//  Copyright © 2017 Venture Lifestyles. All rights reserved.
//

import UIKit

class DateHelper {
    
    static func parseDate(date : String) -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd'T'HH:mm"
        let date = format.date(from: date)
        format.dateFormat = "EEEE, MMM d, yyyy"
        if (date != nil) {
            var returnDate = format.string(from: date!)
            format.dateFormat = "h:mm a"
            returnDate = returnDate + " at " + format.string(from: date!)
            return  returnDate
        }
        
        return ""
    }
    
  
    static func parseTime(time : String) -> String {
        let format = DateFormatter()
        format.dateFormat = "HH:mm"
        let time = format.date(from: time)
        format.dateFormat =  "h:mm a"
        if (time != nil) {
            return format.string(from: time!)
        }
        
        return ""
    }
    
    static func checkDateValidity(validFrom: String, validTo: String, recurringFrom: String, recurringTo: String) -> Bool {
        if (validFrom != "" && validTo != "") {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            let result = formatter.string(from: date)
            let currentDate = formatter.date(from: result)!
            let dealFirstDate = formatter.date(from: validFrom)!
            let dealLastDate = formatter.date(from: validTo)!
            if (recurringFrom != "" && recurringTo != "") {
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let result = formatter.string(from: date)
                let currentTime = formatter.date(from: result)!
                let dealFirstTime = formatter.date(from: recurringFrom)!
                let dealLastTime = formatter.date(from: recurringTo)!
                return currentDate > dealFirstDate && currentDate < dealLastDate && currentTime > dealFirstTime && currentTime < dealLastTime
            }
            return currentDate > dealFirstDate && currentDate < dealLastDate
        }
        return true
    }
}
