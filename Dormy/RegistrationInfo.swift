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
            self.CCV = nil
            return [cardNumber, CCV, zip]
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