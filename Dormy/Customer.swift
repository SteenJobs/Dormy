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
    
    class func getStripeCustomerInfo(completionHandler: (customer: Customer?) -> ()) {
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
                completionHandler(customer: customer)
            }
        }
    }
    
}