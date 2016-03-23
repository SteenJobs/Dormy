//
//  RegistrationInfo.swift
//  Dormy
//
//  Created by Josh Siegel on 11/18/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import Foundation
import Parse
import Stripe

class RegistrationInfo {
    static let sharedInstance = RegistrationInfo()
    
    var email: String?
    var phone: String?
    var password: String?
    var confirmPassword: String?
    var fullName: String?
    var college: PFObject?
    var dormBuilding: String?
    var roomNumber: String?
    var cardNumber: String?
    var cardBrand: STPCardBrand?
    var expirationDate: Expiration?
    var CCV: String?
    var zip: String?
    
    
    
    func signUp(completionHandler: (saved: Bool, error: NSError?) -> ()) {
        var user = PFUser()
        let userInfo = self
        user.username = userInfo.email
        user.password = userInfo.password
        user.email = userInfo.email
        user["phone"] = userInfo.phone
        user["full_name"] = userInfo.fullName
        user["college"] = userInfo.college
        user["dorm_building"] = userInfo.dormBuilding
        user["room_number"] = userInfo.roomNumber
        
        user.signUpInBackgroundWithBlock() { (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                completionHandler(saved: false, error: error)
            } else {
                completionHandler(saved: true, error: nil)
                self.resetRegistrationInfo()
            }
        }
    }

    
    func getExistingTextFields(index: Int) -> [String?] {
        switch index {
        case 0:
            self.password = nil
            self.confirmPassword = nil
            return [email, phone, password, confirmPassword]
        case 1:
            var collegeName: String?
            if let name = college?["name"] as? String {
                collegeName = name
            }
            return [fullName, collegeName, dormBuilding, roomNumber]
        case 2:
            if let number = self.cardNumber {
                let length = number.startIndex.distanceTo(number.endIndex)
                if length >= 4 {
                    let firstFour = number.substringWithRange(Range<String.Index>(start: number.startIndex, end: number.startIndex.advancedBy(4)))
                    self.cardNumber = firstFour
                } else {
                    self.cardNumber = nil
                }
            }
            self.expirationDate = nil
            self.CCV = nil
            return [cardNumber, expirationDate?.formattedString(), CCV, zip]
        default:
            return []
        }
    }
    
    private func resetRegistrationInfo() {
        self.email = nil
        self.phone = nil
        self.password = nil
        self.confirmPassword = nil
        self.fullName = nil
        self.college = nil
        self.dormBuilding = nil
        self.roomNumber = nil
        self.cardNumber = nil
        self.CCV = nil
        self.zip = nil
    }
}