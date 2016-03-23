//
//  ParseRequests.swift
//  Dormy
//
//  Created by Josh Siegel on 3/22/16.
//  Copyright © 2016 Dormy. All rights reserved.
//

import Foundation
import Parse

class ParseRequest {
    
    class func getCollegeOptions(completionHandler: (data: [PFObject]?, error: NSError?) -> ()) {
        let query = PFQuery(className: "College")
        query.findObjectsInBackgroundWithBlock() { (colleges: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                completionHandler(data: nil, error: error)
            } else {
                if let colleges = colleges {
                    let orderedColleges = colleges.sort({ (college1, college2) in
                        let order1 = college1["order"] as! Int
                        let order2 = college2["order"] as! Int
                        return order1 < order2
                    })
                    completionHandler(data: orderedColleges, error: nil)
                }
            }
        }
    }
    
    class func loadJobs(completionHandler: (data: [PFObject]?, error: NSError?) -> ()) {
        let currentUser = PFUser.currentUser()!
        
        let query = PFQuery(className: "Job")
        query.includeKey("dormer")
        query.includeKey("package")
        query.includeKey("cleaner")
        query.includeKey("review")
        query.whereKey("dormer", equalTo: currentUser)
        query.findObjectsInBackgroundWithBlock() { (jobs: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                completionHandler(data: nil, error: error)
            } else {
                if let jobs = jobs {
                    completionHandler(data: jobs, error: nil)
                }
            }
        }
    }
    
    class func getPackageOptions(completionHandler: (data: [PFObject]?, error: NSError?) -> ()) {
        let query = PFQuery(className: "Package")
        query.findObjectsInBackgroundWithBlock() { (packages: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                completionHandler(data: nil, error: error)
            } else {
                if let packages = packages {
                    let orderedPackages = packages.sort({ (package1, package2) in
                        let order1 = package1["order"] as! Int
                        let order2 = package2["order"] as! Int
                        return order1 < order2
                    })
                    completionHandler(data: orderedPackages, error: nil)
                }
            }
        }
    }
    
    
}