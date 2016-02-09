//
//  ReviewViewController.swift
//  Dormy
//
//  Created by Josh Siegel on 1/15/16.
//  Copyright © 2016 Dormy. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class ReviewViewController: UIViewController, UITextViewDelegate, UINavigationBarDelegate {
    
    var job: Job?
    var pageOneVC: ReviewViewControllerP1?
    var pageTwoVC: ReviewViewControllerP2?
    var pageThreeVC: ReviewViewControllerP2?
    
    @IBOutlet weak var cleanerLabel: UILabel!
    @IBOutlet weak var dateCleanedLabel: UILabel!
    @IBOutlet weak var packageLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var scrollView: UIScrollView!
    var activeTV: UITextView?
    
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
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideKeyboard")
        
        // prevents the scroll view from swallowing up the touch event of child buttons
        tapGesture.cancelsTouchesInView = false
        
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.pageOneVC?.reviewTextView.delegate = self
        
        self.registerForKeyboardNotifications()
        
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    
    func registerForKeyboardNotifications() {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func hideKeyboard() {
        self.pageOneVC?.reviewTextView.resignFirstResponder()
    }
    
    func keyboardWasShown(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.scrollEnabled = true
        var info : NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        var contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height + 15, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeTextViewPresent = activeTV {
            let relativeOrigin = pageOneVC!.view.convertPoint(activeTV!.frame.origin, toView: self.view)
            if (!CGRectContainsPoint(aRect, relativeOrigin)) {
                let relativeFrame = pageOneVC!.view.convertRect(activeTV!.frame, toView: self.view)
                self.scrollView.scrollRectToVisible(relativeFrame, animated: true)
            }
        }
        //self.scrollView.scrollEnabled = false
    }
    
    
    func keyboardWillBeHidden(notification: NSNotification) {
        //Once keyboard disappears, restore original positions
        var info : NSDictionary = notification.userInfo!
        var keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        var contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        //self.view.endEditing(true)
        self.scrollView.scrollEnabled = false
        
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        activeTV = textView
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        activeTV = nil
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
