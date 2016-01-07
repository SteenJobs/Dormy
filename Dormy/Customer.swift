//
//  Customer.swift
//  Dormy
//
//  Created by Josh Siegel on 12/30/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import Foundation
import Parse

class Customer {
    
    var customerID: String!
    var defaultSource: String?
    var cardBrand: String?
    var last4: String?
    
    init(customerID: String!) {
        self.customerID = customerID
    }
    
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
    
    class func chargeCustomer(customer: Customer, job: Job, completionHandler: (succeeded: Bool) -> ()) {
        PFCloud.callFunctionInBackground("charge_customer", withParameters: ["customerID": customer.customerID, "source": customer.defaultSource!, "packageID": job.package!.objectId!]) { (response: AnyObject?, error: NSError?) -> Void in
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
    
}