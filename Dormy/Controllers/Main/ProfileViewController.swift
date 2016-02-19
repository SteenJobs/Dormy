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
import MBProgressHUD

extension Int {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
}

class ProfileViewController: UIViewController, UINavigationBarDelegate, UITextFieldDelegate, STPPaymentCardTextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var collegeTF: UITextField!
    @IBOutlet weak var dormBuildingTF: UITextField!
    @IBOutlet weak var roomNumberTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var creditCardTF: UITextField!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var TFHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var changeButton: UIButton!

    var newCardTF: STPPaymentCardTextField?
    var check: UIImageView?
    var newCardValid: Bool = false
    var activityIndicator: MBProgressHUD?
    
    var colleges = ["--"] //["YU", "Columbia", "NYU", "BU"]
    var PFColleges: [PFObject]? = []
    var pickerView: UIPickerView?
    
    weak var activeField: UITextField?
    var stripeCustomer: Customer?
    
    deinit {
        print("profileVC was deallocated")
    }

    @IBAction func logoutButtonTapped(sender: UIButton) {
        PFUser.logOut()
        
        
        
        let pageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("WelcomePageViewController") as! WelcomePageViewController
        let root = UIApplication.sharedApplication().keyWindow?.rootViewController as! RootViewController
        root.pageVC = pageVC
        pageVC.pageControl = root.pageControl
        root.addChildViewController(pageVC)
        root.pageControl.hidden = false
        root.view.addSubview(pageVC.view)
        root.pageVC!.didMoveToParentViewController(self)
        
        root.transitionFromViewController(root.mainVC!, toViewController: root.pageVC!, duration: 1.0, options: UIViewAnimationOptions.TransitionNone, animations: nil, completion: { bool in
            self.dismissViewControllerAnimated(true, completion: {
                root.mainVC!.removeFromParentViewController()
                root.mainVC = nil
            })
        })
        
    }
    
    @IBAction func changeButtonTapped(sender: UIButton) {
        sender.selected = !sender.selected
        self.valueChanges(sender)
    }
    
    func valueChanges(check: UIButton) {
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: .AllowAnimatedContent, animations: {
            let angle = !check.selected ? -90 : 0
            self.newCardTF!.layer.transform = CATransform3DMakeRotation(self.toRadian(angle), 1.0, 0, 0)
            self.layoutStack()
            }, completion: nil)
    }
    
    func toRadian(value: Int) -> CGFloat {
        return CGFloat(Double(value) / 180.0 * M_PI)
    }
    
    func foldFrame(withTop top: CGFloat) -> CGRect {
        return CGRectMake(creditCardTF!.frame.origin.x, top, creditCardTF!.bounds.size.width, creditCardTF!.bounds.size.height)
    }
    
    func layoutStack() {
        newCardTF!.layer.anchorPoint = CGPointMake(0.5, 0.0)
        newCardTF!.layer.doubleSided = false
        let margin: CGFloat = 10
        newCardTF!.frame = foldFrame(withTop: CGRectGetMaxY(creditCardTF!.frame) - newCardTF!.layer.borderWidth)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCollegeOptions()
        
        pickerView = UIPickerView()
        pickerView?.dataSource = self
        pickerView?.delegate = self
        self.collegeTF.inputAccessoryView = self.getKeyboardAccessoryWithTitle("Done", selector: Selector("hideKeyboard"))
        self.collegeTF.inputView = pickerView
        
        
        
        self.newCardTF = STPPaymentCardTextField(frame: foldFrame(withTop: CGRectGetMaxY(creditCardTF!.frame)))
        self.contentView.addSubview(newCardTF!)
        self.newCardTF?.layer.backgroundColor = self.phoneTF.backgroundColor?.CGColor
        self.newCardTF?.textColor = UIColor.whiteColor()
        
        
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = 1 / -900
        self.contentView.layer.sublayerTransform = perspectiveTransform
        
        self.collegeTF.delegate = self
        self.nameTF.delegate = self
        self.dormBuildingTF.delegate = self
        self.roomNumberTF.delegate = self
        self.emailTF.delegate = self
        self.phoneTF.delegate = self
        self.creditCardTF.delegate = self
        self.creditCardTF.enabled = false
        self.newCardTF!.delegate = self
        
        self.changeButton.layer.cornerRadius = 5
        self.changeButton.layer.borderColor = self.creditCardTF.layer.borderColor
        
        let x = NSString(string: "HELLO").sizeWithAttributes([NSFontAttributeName: UIFont(name: "Lucida Grande", size: 30.0)!])
        let adjustedSize = CGSizeMake(ceil(x.width), ceil(x.height))
        TFHeight.constant = adjustedSize.height + 15.0
        
        self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.Interactive
        
        self.navBar.barTintColor = UIColor(rgba: "#0B376D")
        self.navItem.title = "PROFILE"
        self.navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navBar.delegate = self
        self.navBar.translucent = false
        
        let saveButton = UIBarButtonItem(title: "Save", style: .Done, target: self, action: Selector("saveProfileInfo"))
        self.navItem.leftBarButtonItem = saveButton
        self.navItem.leftBarButtonItem!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: Selector("closeProfileView"))
        self.navItem.rightBarButtonItem = doneButton
        self.navItem.rightBarButtonItem!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        self.navItem.rightBarButtonItem!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Highlighted)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.populateTextFields()
        
        self.checkEmail()
        
        self.registerForKeyboardNotifications()

    }
    
    func getKeyboardAccessoryWithTitle(title: String, selector: Selector) -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 50))
        toolbar.barStyle = UIBarStyle.Default
        let item1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let item2 = UIBarButtonItem(title: title, style: UIBarButtonItemStyle.Done, target: self, action: selector)
        toolbar.items = [item1, item2]
        toolbar.sizeToFit()
        return toolbar
    }
    
    func getCollegeOptions() {
        let query = PFQuery(className: "College")
        query.findObjectsInBackgroundWithBlock() { (colleges: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                self.showAlertView(error.localizedDescription, message: error.localizedFailureReason)
            } else {
                if let colleges = colleges {
                    let orderedColleges = colleges.sort({ (college1, college2) in
                        let order1 = college1["order"] as! Int
                        let order2 = college2["order"] as! Int
                        return order1 < order2
                    })
                    self.colleges = ["--"]
                    self.PFColleges = orderedColleges
                    let college = PFUser.currentUser()?["college"] as? PFObject
                    let collegeID = college?.objectId
                    
                    let userCollege = orderedColleges.filter({  (college: PFObject) -> Bool in return college.objectId == collegeID }).first
                    self.collegeTF.text = userCollege?["name"] as? String
                    
                    for college in orderedColleges {
                        self.colleges.append(college["name"] as! String)
                    }
                }
            }
        }
    }
    
    func checkEmail() {
        let user = PFUser.currentUser()
        if !user!.dataAvailable {
            user!.fetchInBackgroundWithBlock() { success, error in
                if let error = error {
                    print(error.localizedDescription)
                    print(error.localizedFailureReason)
                }
                if let success = success {
                    let updatedUser = success as! PFUser
                    if updatedUser["emailVerified"]?.boolValue != true {
                        self.emailTF.backgroundColor = self.nameTF.backgroundColor
                        self.emailTF.textColor = UIColor.whiteColor()
                        self.emailTF.enabled = true
                    } else {
                        self.emailTF.backgroundColor = UIColor.whiteColor()
                        self.emailTF.enabled = false
                    }
                }
            }
        } else {
            if user!["emailVerified"]?.boolValue != true {
                self.emailTF.backgroundColor = self.nameTF.backgroundColor
                self.emailTF.textColor = UIColor.whiteColor()
                self.emailTF.enabled = true
            } else {
                self.emailTF.backgroundColor = UIColor.whiteColor()
                self.emailTF.enabled = false
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.valueChanges(self.changeButton)
        self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: self.creditCardTF.frame.maxY + 400)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutStack()

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
    
    func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
        if textField.valid {
            self.newCardValid = true
            textField.textColor = UIColor(rgba: "#01c601")
        } else {
            self.newCardValid = false
        }
    }
    
    func populateTextFields() {
        activityIndicator = MBProgressHUD(view: self.view)
        activityIndicator!.labelText = "Loading"
        self.view.addSubview(activityIndicator!)
        activityIndicator!.show(true)
        
        let user = PFUser.currentUser()!
        self.emailTF.text = user.email
        self.nameTF.text = user["full_name"] as? String
        self.dormBuildingTF.text = user["dorm_building"] as? String
        self.roomNumberTF.text = user["room_number"] as? String
        self.phoneTF.text = user["phone"] as? String
        Customer.getStripeCustomerInfo() { customer, error in
            if let customer = customer {
                self.stripeCustomer = customer
                if self.stripeCustomer?.cardBrand != nil && self.stripeCustomer?.last4 != nil {
                    self.creditCardTF.text = "\(self.stripeCustomer!.cardBrand!) *****\(self.stripeCustomer!.last4!)"
                }
            }
            if let error = error {
                print(error.localizedDescription)
                print(error.localizedFailureReason)
            }
            self.activityIndicator!.hide(true)
        }
    }
    
    func saveProfileInfo() {
        self.activityIndicator!.labelText = "Saving..."
        self.activityIndicator!.show(true)
        if self.newCardTF!.cardNumber != nil {
            // process card info along with profile info
            saveCC() { success, error in
                if let error = error {
                    self.activityIndicator!.hide(true)
                    self.showAlertView(error.localizedDescription, message: error.localizedFailureReason)
                }
                if success {
                    self.saveUserInfo() { success, error in
                        self.activityIndicator!.hide(true)
                        if let error = error {
                            self.showAlertView(error.localizedDescription, message: error.localizedFailureReason)
                        }
                        if success {
                            let alert = UIAlertController(title: "Success", message: "Your profile has been saved.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { void in
                                self.dismissViewControllerAnimated(true, completion: nil)
                            }))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        } else {
            saveUserInfo() { success, error in
                self.activityIndicator!.hide(true)
                if success {
                    let alert = UIAlertController(title: "Success", message: "Your profile has been saved.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                if let error = error {
                    self.showAlertView(error.localizedDescription, message: error.localizedFailureReason)
                }
            }
        }
    }
    
    func saveCC(completionHandler: (success: Bool, error: NSError?) -> ()) {
        let card = self.newCardTF!.card
        
        STPAPIClient.sharedClient().createTokenWithCard(card!) { token, error in
            if let error = error {
                self.showAlertView(error.localizedDescription, message: error.localizedFailureReason)
            } else {
                self.createCustomer(token!) { success, error in
                    completionHandler(success: success, error: error)
                }
            }
        }
    }
    
    func saveUserInfo(completionHandler: (success: Bool, error: NSError?) -> ()) {
        let textFields = [self.phoneTF, self.nameTF, self.dormBuildingTF, self.roomNumberTF, self.emailTF, self.collegeTF]
        var validations: [Bool] = []
        for field in textFields {
            validations.append(validateRequiredField(field))
            if field == self.phoneTF {
                validations.append(validatePhoneNumber(field))
            }
            if field == self.emailTF {
                validations.append(validateEmailAddress(field))
            }
        }
        
        let filter = self.PFColleges?.filter({(college: PFObject) -> Bool in return college["name"] as? String == self.collegeTF.text!})
        
        if validations.contains(false) || filter?.count == 0 {
            self.activityIndicator?.hide(true)
            self.showAlertView("Error", message: "Please make sure all required fields are filled out properly.")
            return
        }
        
        let user = PFUser.currentUser()!
        user.email = self.emailTF.text!
        user["phone"] = self.phoneTF.text!
        user["college"] = filter?.first
        user["full_name"] = self.nameTF.text!
        user["dorm_building"] = self.dormBuildingTF.text!
        user["room_number"] = self.roomNumberTF.text!
        user.saveInBackgroundWithBlock() { success, error in
            completionHandler(success: success, error: error)
        }
    }
    
    func createCustomer(token: STPToken, completionHandler: (success: Bool, error: NSError?) -> ()) {
        PFCloud.callFunctionInBackground("create_customer", withParameters: ["username": PFUser.currentUser()!.username!,"token": token.tokenId]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if let response = response {
                completionHandler(success: true, error: nil)
            }
            if let error = error {
                completionHandler(success: false, error: error)
            }
            print(response)
            print(error)
        }
    }
    
    func markField(textField: UITextField, validated: Bool) {
        if !validated {
            textField.layer.borderWidth = 2.0
            textField.layer.borderColor = UIColor.redColor().CGColor
        }
    }
    
    
    func validateRequiredField(textField: UITextField) -> Bool {
        var isValidated: Bool?
        
        if textField.text!.isEmpty {
            isValidated = false
            markField(textField, validated: false)
        } else {
            isValidated = true
            markField(textField, validated: true)
        }
        
        return isValidated!
    }
    
    func validateEmailAddress(textField: UITextField) -> Bool {
        let email = textField.text!
        let isEdu = email.hasSuffix(".edu")
        
        if isEdu {
            return true
        } else {
            markField(textField, validated: false)
            return false
        }
    }
    
    func validatePhoneNumber(textField: UITextField) -> Bool {
        let regex = "^\\d{10}$"
        let regex2 = "^\\d{3}-\\d{3}-\\d{4}$"
        if textField.text?.rangeOfString(regex, options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) != nil || textField.text?.rangeOfString(regex2, options: NSStringCompareOptions.RegularExpressionSearch, range: nil, locale: nil) != nil {
            return true
        } else {
            markField(textField, validated: false)
            return false
        }
    }
    
    func showAlertView(error: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // PickerView delegate and datasource methods
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.colleges.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.colleges[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.collegeTF.text = self.colleges[row]
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
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


}
