//
//  RegistrationInfo.swift
//  Dormy
//
//  Created by Josh Siegel on 11/18/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import Foundation

class RegistrationInfo {
    static let sharedInstance = RegistrationInfo()
    
    var email: String?
    var phone: String?
    var password: String?
    var confirmPassword: String?
    var fullName: String?
    var college: String?
    var dormBuilding: String?
    var roomNumber: String?
    var cardNumber: String?
    var expirationDate: Expiration?
    var CCV: String?
    var zip: String?
    
    func getExistingTextFields(index: Int) -> [String?] {
        switch index {
        case 0:
            self.password = nil
            self.confirmPassword = nil
            return [email, phone, password, confirmPassword]
        case 1:
            return [fullName, college, dormBuilding, roomNumber]
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
    
    func resetRegistrationInfo() {
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