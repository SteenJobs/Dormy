//
//  ProfileViewController.swift
//  Dormy
//
//  Created by Josh Siegel on 12/29/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit
import Parse
import Stripe

class ProfileViewController: UIViewController, UINavigationBarDelegate, UITextFieldDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var dormBuildingTF: UITextField!
    @IBOutlet weak var roomNumberTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var creditCardTF: UITextField!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var TFHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    weak var activeField: UITextField?
    var stripeCustomer: Customer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameTF.delegate = self
        self.dormBuildingTF.delegate = self
        self.roomNumberTF.delegate = self
        self.emailTF.delegate = self
        self.phoneTF.delegate = self
        self.creditCardTF.delegate = self
        
        //self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let x = NSString(string: "HELLO").sizeWithAttributes([NSFontAttributeName: UIFont(name: "Lucida Grande", size: 30.0)!])
        let adjustedSize = CGSizeMake(ceil(x.width), ceil(x.height))
        TFHeight.constant = adjustedSize.height + 15.0
        
        self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        
        //self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: 800)
        self.navBar.barTintColor = UIColor(rgba: "#0B376D")
        self.navItem.title = "PROFILE"
        self.navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navBar.delegate = self
        self.navBar.translucent = false
        
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: Selector("closeProfileView"))
        self.navItem.rightBarButtonItem = doneButton
        self.navItem.rightBarButtonItem!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        self.navItem.rightBarButtonItem!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Highlighted)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.populateUserTextFields()
        
        Customer.getStripeCustomerInfo() { customer in
            self.stripeCustomer = customer
            if self.stripeCustomer?.cardBrand != nil && self.stripeCustomer?.last4 != nil {
                self.creditCardTF.text = "\(self.stripeCustomer!.cardBrand!) *****\(self.stripeCustomer!.last4!)"
            }
        }
        
        self.registerForKeyboardNotifications()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: self.creditCardTF.frame.maxY + 100)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //self.scrollView.contentSize = CGSize(width: self.contentView.frame.size.width, height: 800)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeProfileView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    func keyboardDidShow(notification: NSNotification) {
        if let activeField = self.activeField, keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height + 15, right: 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.size.height
            if (!CGRectContainsPoint(aRect, activeField.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func populateUserTextFields() {
        let user = PFUser.currentUser()!
        self.emailTF.text = user.email
        self.nameTF.text = user["full_name"] as? String
        self.dormBuildingTF.text = user["dorm_building"] as? String
        self.roomNumberTF.text = user["room_number"] as? String
        self.phoneTF.text = user["phone"] as? String
    }
    
    
    
    // TextField delegate methods
    
    func registerForKeyboardNotifications() {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.activeField = nil
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.activeField = textField
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
