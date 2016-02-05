//
//  ReviewViewController.swift
//  Dormy
//
//  Created by Josh Siegel on 1/15/16.
//  Copyright © 2016 Dormy. All rights reserved.
//

import UIKit
import Parse

class ReviewViewController: UIViewController, UINavigationBarDelegate {
    
    var job: Job?
    var pageOneVC: ReviewViewControllerP1?
    var pageTwoVC: ReviewViewControllerP2?
    var pageThreeVC: ReviewViewControllerP2?
    
    @IBOutlet weak var cleanerLabel: UILabel!
    @IBOutlet weak var dateCleanedLabel: UILabel!
    @IBOutlet weak var packageLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBar.delegate = self
        
        self.navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navBar.shadowImage = UIImage()
        self.navBar.translucent = true
        self.navBar.barTintColor = UIColor(rgba: "#0b376d")
        let doneButton = UIBarButtonItem(title: "Submit", style: .Done, target: self, action: Selector("submitReview"))
        let navItem = UINavigationItem()
        navItem.rightBarButtonItem = doneButton
        navItem.rightBarButtonItem!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        self.navBar.items = [navItem]
        
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
    

    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    func submitReview() {
        let activityIndicator = MBProgressHUD(view: self.view)
        activityIndicator.labelText = "Submitting..."
        self.view.addSubview(activityIndicator)
        
        
        if let pageOne = self.pageOneVC {
            let currentRating = pageOne.starRatingView.rating
            if currentRating >= 1.0 && job != nil {
                
                activityIndicator.show(true)
                
                var review = PFObject(className: "Review")
                review["reviewing_user"] = PFUser.currentUser()
                review["reviewed_user"] = job!.cleaner
                review["review"] = pageOne.reviewTextView.text
                review["job"] = job!
                review["rating"] = currentRating
                review.saveInBackgroundWithBlock() { (success: Bool, error: NSError?) -> Void in
                    if success {
                        self.job!.review = review
                        self.job!.saveInBackgroundWithBlock() { (success: Bool, error: NSError?) -> Void in
                            if success {
                                activityIndicator.hide(true)
                                let alert = UIAlertController(title: "Success!", message: "Your review has been successfully recorded.", preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { void in
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                }))
                                self.presentViewController(alert, animated: true, completion: nil)
                            } else {
                                activityIndicator.hide(true)
                                review.deleteEventually()
                                if let error = error {
                                    self.showAlertView(error.localizedDescription, message: error.localizedFailureReason)
                                }
                            }
                        }
                    } else {
                        activityIndicator.hide(true)
                        if let error = error {
                            self.showAlertView(error.localizedDescription, message: error.localizedFailureReason)
                        }
                    }
                }
            }
        }
    }
    
    func showAlertView(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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
