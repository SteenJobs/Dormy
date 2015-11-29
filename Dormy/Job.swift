//
//  Job.swift
//  Dormy
//
//  Created by Josh Siegel on 11/25/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import Foundation
import Parse

enum JobStatus: String {
    case InProgress = "In Progress"
    case Completed = "Completed"
    case Waiting = "Waiting"
}



class Job: PFObject, PFSubclassing {
    
    @NSManaged var dormer: PFUser?
    @NSManaged var requestedDate: String?
    @NSManaged var requestedTime: String?
    @NSManaged var instructions: String?
    @NSManaged var status: String?
    @NSManaged var package: PFObject?
    @NSManaged var cleaner: PFUser?
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        return "Job"
    }
    
    func validate() -> Bool {
        let requiredFields = [self.requestedDate, self.requestedTime]
        if self.dormer == nil || self.package == nil {
            return false
        }
        for field in requiredFields {
            if field == nil || field!.isEmpty {
                return false
            }
        }
        return true
    }
    
}
