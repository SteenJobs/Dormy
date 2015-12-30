//
//  RequestsTableViewController.swift
//  Dormy
//
//  Created by Josh Siegel on 11/24/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit
import Parse

class RequestsTableViewController: UITableViewController {

    var jobs: [Job] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up a refresh control, call reload to start things up
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "reload", forControlEvents: .ValueChanged)
        
        //self.loadJobs()
        
        let nibName = UINib(nibName: "InProgressCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "InProgressTableViewCell")
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        let nibName2 = UINib(nibName: "WaitingCell", bundle:nil)
        self.tableView.registerNib(nibName2, forCellReuseIdentifier: "WaitingTableViewCell")

        let nibName3 = UINib(nibName: "CompletedCell", bundle:nil)
        self.tableView.registerNib(nibName3, forCellReuseIdentifier: "CompletedTableViewCell")
        
        self.tableView.estimatedRowHeight = 156.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshControl?.tintColor = UIColor.whiteColor()
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl!.frame.size.height)
        
        self.refreshControl?.beginRefreshing()
        self.loadJobs() { void in
            self.refreshControl?.endRefreshing()
            print("Jobs loaded")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jobs.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let job = self.jobs[indexPath.row]
        
        switch job.status! {
        case JobStatus.Waiting.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("WaitingTableViewCell", forIndexPath: indexPath) as! WaitingTableViewCell
            cell.requestedDateLabel.text = job.requestedDate!
            let package = job.package!
            cell.packageLabel.text = package["name"] as! String + " - $\(package["price"] as! Int)"
            return cell
        case JobStatus.InProgress.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("InProgressTableViewCell", forIndexPath: indexPath) as! InProgressTableViewCell
            let cleaner = job.cleaner!
            let package = job.package!
            
            cell.cleanerLabel.text = cleaner["full_name"] as! String
            cell.requestedDateLabel.text = job.requestedDate!
            cell.packageLabel.text = package["name"] as! String + " - $\(package["price"] as! Int)"
            
            return cell
        case JobStatus.Completed.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("CompletedTableViewCell", forIndexPath: indexPath) as! CompletedTableViewCell
            let package = job.package!
            let cleaner = job.cleaner!
            
            cell.cleanerLabel.text = cleaner["full_name"] as! String
            cell.dateCleanedLabel.text = job.completedDate!
            cell.packageLabel.text = package["name"] as! String + " - $\(package["price"] as! Int)"
            
            
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }

    }
    
    func reload() {
        self.loadJobs() { void in
            self.refreshControl?.endRefreshing()
        }
    }
    
    func loadJobs(completionHandler: () -> ()) {
        let currentUser = PFUser.currentUser()!
        
        let query = PFQuery(className: "Job")
        query.includeKey("dormer")
        query.includeKey("package")
        query.includeKey("cleaner")
        query.whereKey("dormer", equalTo: currentUser)
        query.findObjectsInBackgroundWithBlock() { (jobs: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                self.showAlertView(error.localizedDescription, message: error.localizedFailureReason)
                completionHandler()
            } else {
                // remove and use 'include'
                if jobs != nil {
                    self.jobs = []
                    for job in jobs! {
                        let localJob = job as! Job
                        self.jobs.append(localJob)
                    }
                    self.tableView.reloadData()
                    completionHandler()
                }
                
                /*
                self.loadPackages(jobs!) { bool in
                    if bool {
                        self.tableView.reloadData()
                    }
                }
                */
            }
        }
    }
    
    
    /*
    func loadPackages(jobs: [PFObject], completionHandler: (finished: Bool) -> ()) {
        self.jobs = []
        for job in jobs {
            let localJob = job as! Job
            self.jobs.append(localJob)
            let query = PFQuery(className: "Package")
            query.whereKey("objectId", equalTo: localJob.package!.objectId!)
            query.findObjectsInBackgroundWithBlock() { (packages: [PFObject]?, error: NSError?) -> Void in
                if packages != nil {
                    let package = packages!.first!
                    localJob.package = package
                    if localJob == jobs.last {
                        completionHandler(finished: true)
                    }
                }
            }
        }
        
    }
    */
    
        
    func showAlertView(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
        
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
