//
//  Expiration.swift
//  Dormy
//
//  Created by Josh Siegel on 11/21/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import Foundation

class Expiration {
    
    var month: String?
    var year: String?
    var date: String?
    
    init() {
        self.month = ""
        self.year = ""
    }
    
    class func cardExpiryWithString(string: String?) -> Expiration {
        var expiration: String?
        if let string = string {
            expiration = string
        } else {
            expiration = ""
        }
        return Expiration.init().initWithString(expiration)
    }
    
    func initWithString(string: String?) -> Expiration {
        if string == nil {
            return self.initWithMonth("", year: "")
        }
        
        let regex = try? NSRegularExpression(pattern: "^(\\d{1,2})?[\\s/]*(\\d{1,4})?", options: NSRegularExpressionOptions(rawValue: 0))
        let match: NSTextCheckingResult? = regex!.firstMatchInString(string!, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, NSString(string: string!).length))
        
        var monthStr: NSString?
        var yearStr: NSString?
        
        if (match != nil) {
            var monthRange = match!.rangeAtIndex(1)
            if monthRange.length > 0 {
                monthStr = NSString(string: string!).substringWithRange(monthRange)
            } else {
                monthStr = ""
            }
            
            var yearRange = match!.rangeAtIndex(2)
            if yearRange.length > 0 {
                yearStr = NSString(string: string!).substringWithRange(yearRange)
            } else {
                yearStr = ""
            }
        }
        
        return self.initWithMonth(String(monthStr!), year: String(yearStr!))
    }
    
    func initWithMonth(monthStr: String, year yearStr: String) -> Expiration {
        self.month = monthStr
        self.year = yearStr
        
        var NSMonth = NSString(string: self.month!)
        var NSYear = NSString(string: self.year!)
        
        if NSMonth.length == 1 {
            if !(NSMonth.isEqualToString("0") || NSMonth.isEqualToString("1")) {
                NSMonth = NSString(format: "0%@", NSMonth)
                self.month = String(NSMonth)
            }
        }
        
        return self
        
    }
    
    func formattedString() -> String {
        if self.year?.characters.count > 0 {
            return String(format: "%@/%@", self.month!, self.year!)
        }
        
        return String(format: "%@", self.month!)
        
    }
    
    func formattedStringWithTrail() -> String {
        if self.month?.characters.count == 2 && self.year?.characters.count == 0 {
            return String(format: "%@/", self.formattedString())
        } else {
            return self.formattedString()
        }
    }
    
}