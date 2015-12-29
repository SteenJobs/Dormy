//
//  RegistrationFields.swift
//  Dormy
//
//  Created by Josh Siegel on 11/19/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit
import Stripe

class RegistrationFields: UITextField {
    
    var type: String?
    var error: Bool?
    
    func validate() -> Bool {
        if self.text!.isEmpty {
            return self.markField(false)
        }
        if let type = self.type {
            switch type {
            case "E-mail Address":
                return self.markField(self.validateEmailAddress())
            case "Phone Number":
                return self.markField(self.validatePhoneNumber())
            case "Password":
                return self.markField(self.validatePassword())
            case "Confirm Password":
                return self.markField(self.validateConfirmPassword())
            case "Choose Your College":
                return self.markField(self.validateCollege())
            default:
                return true
            }
        } else {
            return true
        }
    }
    
    func markCardField(validated: Bool) {
        self.layer.borderWidth = 2.0
        if !validated {
            self.layer.borderColor = UIColor.redColor().CGColor
        } else {
            self.layer.borderColor = UIColor.greenColor().CGColor
        }
    }
    
    func markField(validated: Bool) -> Bool {
        if !validated {
            self.layer.borderWidth = 2.0
            self.layer.borderColor = UIColor.redColor().CGColor
            self.error = true
            return false
        } else {
            if self.error == true {
                self.layer.borderColor = UIColor.greenColor().CGColor
                self.error = false
                return true
            } else {
                self.layer.borderWidth = 0.0
                self.layer.borderColor = UIColor.blackColor().CGColor
                return true
            }
        }
    }
    
    
    func validateRequiredField() -> Bool {
        var isValidated: Bool = true

        if self.text!.isEmpty {
            isValidated = false
            markField(true)
        } else {
            isValidated = true
            markField(false)
        }

        
        return isValidated
    }
    
    func validateEmailAddress() -> Bool {
        let email = self.text
        let isEdu = email!.hasSuffix(".edu")
        
        return isEdu
    }
    
    func validateCollege() -> Bool {
        let didChoose = (self.text != "--")
        return didChoose
    }
    
    func validatePhoneNumber() -> Bool {
        let regex = "^\\d{10}$"
        let regex2 = "^\\d{3}-\\d{3}-\\d{4}$"
        if self.text?.rangeOfString(regex, options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) != nil || self.text?.rangeOfString(regex2, options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) != nil {
            return true
        } else {
            return false
        }
    }
    
    func validatePassword() -> Bool {
        if let password = self.text {
            return !password.isEmpty
        } else {
            return false
        }
    }
    
    func validateConfirmPassword() -> Bool {
        return (RegistrationInfo.sharedInstance.password == self.text)
    }
    
    
}
