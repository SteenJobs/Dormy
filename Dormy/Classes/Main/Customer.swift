//
//  Customer.swift
//  Dormy
//
//  Created by Josh Siegel on 12/30/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import Foundation
import Parse
import Stripe

class Customer {
    
    var customerID: String!
    var defaultSource: String?
    var cardBrand: String?
    var last4: String?
    
    init(customerID: String!) {
        self.customerID = customerID
    }
    
    // Queries parse for customer object belonging to currentUser, and then requests that customer from Stripe
    class func getStripeCustomerInfo(completionHandler: (customer: Customer?, error: NSError?) -> ()) {
        PFCloud.callFunctionInBackground("get_customer", withParameters: nil) { (response: AnyObject?, error: NSError?) -> Void in
            if let dict = response as? NSDictionary {
                let customerID = dict["customer_id"] as! String
                let customer = Customer(customerID: customerID)
                
                if let defaultSource = dict["default_source"] as? String {
                    customer.defaultSource = defaultSource
                }
                if let brand = dict["brand"] as? String {
                    customer.cardBrand = brand
                }
                if let last4 = dict["last4"] as? String {
                    customer.last4 = last4
                }
                completionHandler(customer: customer, error: nil)
            }
            if let error = error {
                print(error)
                completionHandler(customer: nil, error: error)
            }
        }
    }
    
    func chargeCustomer(job: Job, completionHandler: (succeeded: Bool) -> ()) {
        PFCloud.callFunctionInBackground("charge_customer", withParameters: ["customerID": self.customerID, "source": self.defaultSource!, "packageID": job.package!.objectId!]) { (response: AnyObject?, error: NSError?) -> Void in
            if let error = error {
                print(error)
                completionHandler(succeeded: false)
            }
            if let dict = response as? NSDictionary {
                let status = dict["status"] as! String
                print(status)
                let chargeID = dict["charge"] as! String
                let charge = PFObject(className: "Charge")
                charge["charge_id"] = chargeID
                charge["user"] = PFUser.currentUser()!
                charge["job"] = job
                charge.saveInBackgroundWithBlock() { success, error in
                    if let error = error {
                        print(error)
                        completionHandler(succeeded: false)
                        return
                    }
                    job.charge = charge
                    job.saveInBackground()
                    completionHandler(succeeded: true)
                    return
                }
            } else {
                completionHandler(succeeded: false)
            }
        }
    }
    
    // Creates token from CC information, creates customer on Stripe using generated token, saves customer on Parse
    class func saveCC(registrationInfo: RegistrationInfo?=nil, card: STPCardParams?=nil, completionHandler: (success: Bool, error: NSError?) -> ()) {
        
        var userCC: STPCardParams?
        if card == nil {
            if let info = registrationInfo {
                userCC = STPCardParams()
                userCC!.number = info.cardNumber
                userCC!.expMonth = UInt(info.expirationDate!.month!)!
                userCC!.expYear = UInt(info.expirationDate!.year!)!
                userCC!.cvc = info.CCV
                userCC!.addressZip = info.zip
            }
        } else {
            userCC = card
        }
        
        STPAPIClient.sharedClient().createTokenWithCard(userCC!) { token, error in
            if let error = error {
                print("token could not be created")
                completionHandler(success: false, error: error)
            } else {
                if let token = token {
                    self.createCustomer(token) { success, error in
                        if let error = error {
                            print("Stripe customer could not be created")
                            completionHandler(success: false, error: error)
                        } else {
                            if success {
                                print("Stripe customer successfully created")
                                completionHandler(success: true, error: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private class func createCustomer(token: STPToken, completionHandler: (success: Bool, error: NSError?) -> ()) {
        var email = PFUser.currentUser()!.email!
        if (email.characters.count < 1) {
            email = PFUser.currentUser()!.username!
        }
        PFCloud.callFunctionInBackground("create_customer", withParameters: ["username": PFUser.currentUser()!.username!, "email": email, "token": token.tokenId]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                if let response = response {
                    completionHandler(success: true, error: nil)
                }
            }
        }
    }
    
}