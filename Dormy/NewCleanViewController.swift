//
//  NewCleanViewController.swift
//  Dormy
//
//  Created by Josh Siegel on 11/25/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit
import Parse

class NewCleanViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var specialInstructions: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var packageTF: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    var downPicker: DownPicker?
    var packages: [PFObject]?
    var packageDict = [String: PFObject]()
    var activeField: UITextField?
    var activeTV: UITextView?
    
    @IBAction func requestJob(sender: AnyObject) {
        let textFields: [UITextField] = [self.dateField, self.timeField, self.packageTF]
        
        let currentUser = PFUser.currentUser()
        
        let job = Job()
        job.dormer = currentUser
        job.requestedDate = dateField.text
        job.requestedTime = timeField.text
        job.status = JobStatus.Waiting.rawValue
        job.package = self.packageDict[packageTF.text!]
        job.instructions = specialInstructions.text
        
        let isValidated = job.validate()
        if isValidated {
            job.saveInBackgroundWithBlock() { success, error in
                if let error = error {
                    if let errorString = error.userInfo["error"] as? String {
                        self.showAlertView("Error", message: errorString)
                    }
                } else {
                    let relation = currentUser!.relationForKey("jobs")
                    relation.addObject(job)
                    currentUser!.saveInBackground()
                    let alert = UIAlertController(title: "Success!", message: "Your request has been successfully recorded.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
            }
        } else {
            self.showAlertView("Error", message: "Please make sure all required fields are filled out.")
            for textField in textFields {
                if textField.text!.isEmpty {
                    textField.layer.borderWidth = 2.0
                    textField.layer.borderColor = UIColor.redColor().CGColor
                }
            }
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    

        self.navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navBar.shadowImage = UIImage()
        self.navBar.translucent = true
        self.navBar.barTintColor = UIColor(rgba: "#0b376d")
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: Selector("closeNewCleanView"))
        let navItem = UINavigationItem()
        navItem.rightBarButtonItem = doneButton
        self.navBar.items = [navItem]
        
        // Do any additional setup after loading the view.
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.addTarget(self, action: Selector("dateTextField:"), forControlEvents: UIControlEvents.ValueChanged)
        self.dateField.inputAccessoryView = self.getKeyboardAccessoryWithTitle("Done", selector: Selector("hideKeyboard"))
        self.dateField.inputView = datePicker
        
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = UIDatePickerMode.Time
        timePicker.addTarget(self, action: Selector("dateTextField:"), forControlEvents: UIControlEvents.ValueChanged)
        self.timeField.inputAccessoryView = self.getKeyboardAccessoryWithTitle("Done", selector: Selector("hideKeyboard"))
        self.timeField.inputView = timePicker
        
        self.dateField.delegate = self
        self.timeField.delegate = self
        self.packageTF.delegate = self
        self.specialInstructions.delegate = self
        
    }
    
    func closeNewCleanView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    //self.expirationDateText.inputAccessoryView = [self getKeyboardAccessoryWithTitle:@“Done" andSelector:@selector(hideKeyboard)];
    
    func getKeyboardAccessoryWithTitle(title: String, selector: Selector) -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50))
        toolbar.barStyle = UIBarStyle.Default
        let item1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let item2 = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Done, target: self, action: selector)
        toolbar.items = [item1, item2]
        toolbar.sizeToFit()
        return toolbar
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.bringSubviewToFront(self.navBar)
        self.registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getPackageOptions() { success in
            if success == true {
                var packageNames: [String] = []
                for package in self.packages! {
                    let display = package["name"] as! String + " - $\(package["price"] as! Int)"
                    self.packageDict[display] = package
                    packageNames.append(display)
                }
                self.downPicker = DownPicker(textField: self.packageTF, withData: packageNames)
                self.downPicker!.setPlaceholder("")
                self.downPicker!.addTarget(self, action: Selector("downPickerEditingBegan:"), forControlEvents: UIControlEvents.EditingDidBegin)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dateTextField(sender: UIDatePicker) {
        if sender == self.dateField.inputView {
            let picker = self.dateField.inputView as! UIDatePicker
            let date = NSDateFormatter.localizedStringFromDate(picker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
            self.dateField.text = date
        } else {
            let picker = self.timeField.inputView as! UIDatePicker
            let time = NSDateFormatter.localizedStringFromDate(picker.date, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
            self.timeField.text = time
        }
    }

    func registerForKeyboardNotifications() {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications() {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
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
        if let activeFieldPresent = activeField {
            var toolbar = CGFloat(0.0)
            if activeFieldPresent == self.packageTF {
                toolbar = self.packageTF.inputAccessoryView!.frame.size.height
                aRect.size.height -= toolbar
            }
            if (!CGRectContainsPoint(aRect, activeField!.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
        if let activeTextViewPresent = activeTV {
            if (!CGRectContainsPoint(aRect, activeTV!.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeTV!.frame, animated: true)
            }
        }
        self.scrollView.scrollEnabled = false
        
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

    func downPickerEditingBegan(sender: DownPicker) {
        let textField = self.packageTF
        activeField = textField
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        activeTV = textView
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        activeTV = nil
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
        if textField == self.dateField {
            if textField.text!.isEmpty {
                let picker = self.dateField.inputView as! UIDatePicker
                let currentDate = NSDateFormatter.localizedStringFromDate(picker.date, dateStyle: NSDateFormatterStyle.MediumStyle, timeStyle: NSDateFormatterStyle.NoStyle)
                textField.text = currentDate
            }
        }
        if textField == self.timeField {
            if textField.text!.isEmpty {
                let picker = self.timeField.inputView as! UIDatePicker
                let currentTime = NSDateFormatter.localizedStringFromDate(picker.date, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                textField.text = currentTime
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }

    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func getPackageOptions(completionHandler: (success: Bool) -> ()) {
        let query = PFQuery(className: "Package")
        query.findObjectsInBackgroundWithBlock() { (packages: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                completionHandler(success: false)
                if let errorString = error.userInfo["error"] as? String {
                    self.showAlertView("Error", message: errorString)
                }
            } else {
                if let packages = packages {
                    let orderedPackages = packages.sort({ (package1, package2) in
                        let order1 = package1["order"] as! Int
                        let order2 = package2["order"] as! Int
                        return order1 < order2
                    })
                    self.packages = orderedPackages
                    
                    completionHandler(success: true)
                }
            }
        }
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
