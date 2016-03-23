//
//  Validations.swift
//  Dormy
//
//  Created by Josh Siegel on 3/22/16.
//  Copyright © 2016 Dormy. All rights reserved.
//

import Foundation
import Stripe

class Validations {
    
    static func validate(textField: UITextField, required: Bool=true) -> Bool {
        if textField.text!.isEmpty {
            if required {
                return false
            } else {
                return true
            }
        }
        
        switch textField.tag {
        case FieldType.FullName.rawValue:
            return self.validateFullName(textField)
        case FieldType.Email.rawValue:
            return self.validateEmailAddress(textField)
        case FieldType.Phone.rawValue:
            return self.validatePhoneNumber(textField)
        case FieldType.Password.rawValue:
            return self.validatePassword(textField)
        case FieldType.PasswordConfirmation.rawValue:
            return self.validateConfirmPassword(textField)
        case FieldType.College.rawValue:
            return self.validateCollege(textField)
        case FieldType.CardNumber.rawValue:
            let validated = STPCardValidator.validationStateForNumber(textField.text!, validatingCardBrand: true) == STPCardValidationState.Valid
            if validated {
                RegistrationInfo.sharedInstance.cardBrand = STPCardValidator.brandForNumber(textField.text!)
                return true
            } else {
                return false
            }
        case FieldType.Expiration.rawValue:
            let date = Expiration.cardExpiryWithString(textField.text!)
            let validated = STPCardValidator.validationStateForExpirationYear(date.year!, inMonth: date.month!) == STPCardValidationState.Valid
            return validated
        case FieldType.CCV.rawValue:
            if let brand = RegistrationInfo.sharedInstance.cardBrand {
                let validated = STPCardValidator.validationStateForCVC(textField.text!, cardBrand: brand) == STPCardValidationState.Valid
                return validated
            } else {
                return false
            }
        case FieldType.Zip.rawValue:
            return self.validateZip(textField)
        default:
            return true
        }
    }
    
    
    private static func validateFullName(textField: UITextField) -> Bool {
        let nameArray: [String] = textField.text!.characters.split { $0 == " " }.map { String($0) }
        return nameArray.count >= 2
    }
    
    private static func validateEmailAddress(textField: UITextField) -> Bool {
        let email = textField.text
        let isEdu = email!.hasSuffix(".edu")
        
        return isEdu
    }
    
    private static func validateCollege(textField: UITextField) -> Bool {
        var isOnlyWhitespace: Bool?
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
        if textField.text!.stringByTrimmingCharactersInSet(whitespaceSet) != "" {
            isOnlyWhitespace = false
        } else {
            isOnlyWhitespace = true
        }
        let didChoose = textField.text != "--" && !isOnlyWhitespace!
        return didChoose
    }
    
    private static func validatePhoneNumber(textField: UITextField) -> Bool {
        let regex = "^\\d{10}$"
        let regex2 = "^\\d{3}-\\d{3}-\\d{4}$"
        if textField.text?.rangeOfString(regex, options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) != nil || textField.text?.rangeOfString(regex2, options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) != nil {
            return true
        } else {
            return false
        }
    }
    
    private static func validatePassword(textField: UITextField) -> Bool {
        if let password = textField.text {
            return !password.isEmpty
        } else {
            return false
        }
    }
    
    private static func validateConfirmPassword(textField: UITextField) -> Bool {
        return (RegistrationInfo.sharedInstance.password == textField.text)
    }
    
    private static func validateZip(textField: UITextField) -> Bool {
        let letters = NSCharacterSet.letterCharacterSet()
        let phrase = textField.text!
        let range = phrase.rangeOfCharacterFromSet(letters)
        
        // range will be nil if no letters is found
        if range != nil {
            print("letters found")
            return false
        } else {
            print("letters not found")
            if textField.text!.characters.count != 5 {
                return false
            } else {
                return true
            }
        }
    }
    
}