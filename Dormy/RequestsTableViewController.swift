//
//  RequestsTableViewController.swift
//  Dormy
//
//  Created by Josh Siegel on 11/24/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit

class RequestsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let nibName = UINib(nibName: "InProgressCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: "InProgressTableViewCell")
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        let nibName2 = UINib(nibName: "WaitingCell", bundle:nil)
        self.tableView.registerNib(nibName2, forCellReuseIdentifier: "WaitingTableViewCell")

        
        self.tableView.estimatedRowHeight = 156.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        if 2 == 2 {
            cell = tableView.dequeueReusableCellWithIdentifier("InProgressTableViewCell", forIndexPath: indexPath) as! InProgressTableViewCell
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("WaitingTableViewCell", forIndexPath: indexPath) as! WaitingTableViewCell
        }
        
        

        // Configure the cell...

        return cell
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
