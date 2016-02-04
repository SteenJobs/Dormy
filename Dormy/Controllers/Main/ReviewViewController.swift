//
//  ReviewViewController.swift
//  Dormy
//
//  Created by Josh Siegel on 1/15/16.
//  Copyright © 2016 Dormy. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {
    
    var job: Job?
    
    @IBOutlet weak var cleanerLabel: UILabel!
    @IBOutlet weak var dateCleanedLabel: UILabel!
    @IBOutlet weak var packageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if job == nil {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let job = job {
            let package = job.package!
            let cleaner = job.cleaner!
            
            self.packageLabel.adjustsFontSizeToFitWidth = true
            self.dateCleanedLabel.adjustsFontSizeToFitWidth = true
            self.cleanerLabel.adjustsFontSizeToFitWidth = true
            
            self.cleanerLabel.text = cleaner["full_name"] as! String
            self.dateCleanedLabel.text = job.completedDate!
            self.packageLabel.text = package["name"] as! String + " - $\(package["price"] as! Int)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
