//
//  RegistrationFields.swift
//  Dormy
//
//  Created by Josh Siegel on 11/19/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit
import Stripe


enum FieldType: Int {
    case FullName = 0
    case Email
    case Phone
    case Password
    case PasswordConfirmation
    case College
    case DormBuilding
    case RoomNumber
    case CardNumber
    case Expiration
    case CCV
    case Zip
    
    var description: String {
        switch self {
        case .FullName:
            return "Full Name"
        case .Email:
            return "E-mail Address (.edu)"
        case .Phone:
            return "Phone Number"
        case .Password:
            return "Password"
        case .PasswordConfirmation:
            return "Confirm Password"
        case .College:
            return "Choose Your College"
        case .DormBuilding:
            return "Dorm Building"
        case .RoomNumber:
            return "Room Number"
        case .CardNumber:
            return "Card Number"
        case .Expiration:
            return "Expiration Date"
        case .CCV:
            return "CCV"
        case .Zip:
            return "Zip Code"
        }
    }
}

class RegistrationConfig {
    
    var index: Int
    var numberOfTextFields: Int {
        return placeHolderDict[index].count
    }

    private var placeHolderDict: [[FieldType]] = [[FieldType.Email, FieldType.Phone, FieldType.Password, FieldType.PasswordConfirmation], [FieldType.FullName, FieldType.College, FieldType.DormBuilding, FieldType.RoomNumber], [FieldType.CardNumber, FieldType.Expiration, FieldType.CCV, FieldType.Zip]]
    private var navBarTitles = ["SIGN UP", "CREATE PROFILE", "CREATE PROFILE"]
    private var buttons = ["signup-next", "signup-next", "signup-done"]
    
    init(index: Int) {
        self.index = index
    }
    
    func isFinalButton() -> Bool {
        return self.index == self.buttons.count - 1
    }
    
    func fieldTypes() -> [FieldType] {
        return self.placeHolderDict[index]
    }
    
    func navBarTitle() -> String {
        return self.navBarTitles[index]
    }
    
    func button() -> String {
        return self.buttons[index]
    }
 
}
