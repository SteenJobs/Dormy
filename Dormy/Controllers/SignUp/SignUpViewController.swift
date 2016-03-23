//
//  SignUpViewController.swift
//  Dormy
//
//  Created by Josh Siegel on 11/18/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit
import Parse
import Stripe

class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet var textField1: UITextField!
    @IBOutlet var textField2: UITextField!
    @IBOutlet var textField3: UITextField!
    @IBOutlet var textField4: UITextField!
    @IBOutlet var completeButton: UIButton!
    @IBOutlet var TFHeight: NSLayoutConstraint!
    
    var pickerView: UIPickerView?
    var index: Int = 0
    var numberOfTextFields: Int?
    var textFields: [UITextField]?
    var registrationConfig: RegistrationConfig?
    
    // Placeholder for Parse data - set with single value of "--"
    var colleges: [String] = [] //["YU", "Columbia", "NYU", "BU"]
    var PFColleges: [PFObject]? = []
    
    var submitAttemptFailed = false
    
    
    @IBAction func completeButtonTapped(sender: AnyObject) {
        self.preserveUserRegistrationInfo(self.index)
        hideKeyboard()
        
        if !self.validateSubmission() {
            self.showAlertView("Error", message: "Please fix any errors before continuing.")
            return
        } else {
            submitAttemptFailed = false
        }
        
        if self.completeButton.tag == 0 {
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController
            let currentVC = self.navigationController!.visibleViewController as! SignUpViewController
            let currentIndex = currentVC.index
            nextVC.index = currentIndex + 1
            self.navigationController!.pushViewController(nextVC, animated: true)
        } else {
            RegistrationInfo.sharedInstance.signUp() { saved, error in
                if saved {
                    Customer.saveCC(RegistrationInfo.sharedInstance) { success, error in
                        var title: String?
                        var message: String?
                        if let error = error {
                            title = error.localizedDescription
                            message = error.localizedFailureReason
                        } else {
                            title = "Thank you for registering with Dormy!"
                            message = "A verification email will be sent to the address you provided. Once you've verified your account you will be able to start booking jobs."
                        }
                        self.showSignUpAlertView(title!, message: message)
                    }
                } else {
                    if let error = error {
                        self.showAlertView(error.localizedDescription, message: error.localizedFailureReason)
                    }
                    print("User could not be saved")
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        registrationConfig = RegistrationConfig(index: self.index)
        
        self.getCollegeOptions()
        
        let button = registrationConfig!.button()
        
        self.completeButton.setBackgroundImage(UIImage(named: button), forState: .Normal)
        if registrationConfig!.isFinalButton() {
            self.completeButton.tag = 1
        } else {
            self.completeButton.tag = 0
        }
        
        
        numberOfTextFields = registrationConfig!.numberOfTextFields
        textFields = [self.textField1, self.textField2, self.textField3, self.textField4]

        let slice = textFields![self.numberOfTextFields!..<textFields!.count]
        for textField in slice {
            textField.hidden = true
        }
        
        let fieldTypes = registrationConfig!.fieldTypes()
        let z = zip(textFields!, fieldTypes)
        for (textField, fieldType) in z {
            textField.delegate = self
            textField.placeholder = fieldType.description
            textField.tag = fieldType.rawValue
            textField.clearButtonMode = UITextFieldViewMode.WhileEditing
            textField.addTarget(self, action: Selector("checkTextField:"), forControlEvents: UIControlEvents.EditingChanged)
            
            configureTextFieldAttributes(textField)
        }
        
        // Match TextField height to font size
        let x = NSString(string: "HELLO").sizeWithAttributes([NSFontAttributeName: UIFont(name: "Lucida Grande", size: 30.0)!])
        let adjustedSize = CGSizeMake(ceil(x.width), ceil(x.height))
        TFHeight.constant = adjustedSize.height + 15.0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let currentValues = RegistrationInfo.sharedInstance.getExistingTextFields(self.index)
        let z = zip(textFields!, currentValues)
        for (textField, currentValue) in z {
            textField.text = currentValue
            textField.layer.borderWidth = 0.0
            textField.layer.borderColor = UIColor.blackColor().CGColor
        }
        
        self.view.layer.borderColor = UIColor(rgba: "#979797").CGColor
        self.view.layer.borderWidth = 1.0
        self.navigationItem.title = registrationConfig!.navBarTitle()
        let backButton = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: Selector("closeSignUpView"))
        self.navigationItem.backBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = doneButton
        self.completeButton.setBackgroundImage(UIImage(named: registrationConfig!.button()), forState: .Normal)
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Highlighted)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
    }

    
    /* TextField Delegate */
    
    func textFieldDidEndEditing(textField: UITextField) {
        // Save password to check against password confirmation
        if textField.tag == FieldType.Password.rawValue {
            RegistrationInfo.sharedInstance.password = textField.text
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == FieldType.College.rawValue {
            textField.text = self.colleges[0]
        }
    }
    
    func checkTextField(sender: UITextField) {
        let textField = sender

        if self.index == 2 || self.submitAttemptFailed {
            let isValidated = Validations.validate(textField, required: true)
            self.markField(textField, validated: isValidated)
        }

    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.inputView != nil && textField.inputView!.isMemberOfClass(UIPickerView) {
            return false
        }
        if textField.tag == FieldType.Expiration.rawValue {
            let date = Expiration.cardExpiryWithString(textField.text! + string)
            let year = date.year!
            if string != "" {
                if year.characters.count < 3 {
                    textField.text = date.formattedStringWithTrail()
                }
                self.checkTextField(textField) // returning false, so call manually.
                return false // necessary because changing textField.text manually with formatted date.
            }
        }
        return true
    }
    
    /* Validations */
    
    func validateSubmission() -> Bool {
        let currentTextFields = self.textFields![0..<self.numberOfTextFields!]
        
        var validations: [Bool] = []
        for textField in currentTextFields {
            let isValidated = Validations.validate(textField, required: true)
            self.markField(textField, validated: isValidated)
            validations.append(isValidated)
        }
        if validations.contains(false) {
            self.submitAttemptFailed = true
            return false
        } else {
            return true
        }
    }
    
    func markField(textField: UITextField, validated: Bool) {
        textField.layer.borderWidth = 2.0
        if validated {
            textField.layer.borderColor = UIColor.greenColor().CGColor
        } else {
            textField.layer.borderColor = UIColor.redColor().CGColor
        }
    }

    
    /* Picker data source */
    
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
        let filter = self.textFields?.filter({(tf: UITextField) -> Bool in return tf.tag == FieldType.College.rawValue})
        if filter?.count > 0 {
            let collegeTF = filter!.first!
            collegeTF.text = self.colleges[row]
        }
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
    
    /* Save User methods */
    
    func findTextFieldByFieldType(type: FieldType) -> String? {
        return self.textFields?.filter({(tf: UITextField) -> Bool in return tf.tag == type.rawValue}).first?.text
    }
    
    func preserveUserRegistrationInfo(index: Int) {
        switch index {
        case 0:
            RegistrationInfo.sharedInstance.email = findTextFieldByFieldType(FieldType.Email)?.lowercaseString
            RegistrationInfo.sharedInstance.phone = findTextFieldByFieldType(FieldType.Phone)
            RegistrationInfo.sharedInstance.password = findTextFieldByFieldType(FieldType.Password)
            RegistrationInfo.sharedInstance.confirmPassword = findTextFieldByFieldType(FieldType.PasswordConfirmation)
        case 1:
            RegistrationInfo.sharedInstance.fullName = findTextFieldByFieldType(FieldType.FullName)
            RegistrationInfo.sharedInstance.college = self.PFColleges?.filter({(college: PFObject) -> Bool in return college["name"] as? String == findTextFieldByFieldType(FieldType.College)}).first
            RegistrationInfo.sharedInstance.dormBuilding = findTextFieldByFieldType(FieldType.DormBuilding)
            RegistrationInfo.sharedInstance.roomNumber = findTextFieldByFieldType(FieldType.RoomNumber)
        case 2:
            RegistrationInfo.sharedInstance.cardNumber = findTextFieldByFieldType(FieldType.CardNumber)
            RegistrationInfo.sharedInstance.expirationDate = Expiration.cardExpiryWithString(findTextFieldByFieldType(FieldType.Expiration))
            RegistrationInfo.sharedInstance.CCV = findTextFieldByFieldType(FieldType.CCV)
            RegistrationInfo.sharedInstance.zip = findTextFieldByFieldType(FieldType.Zip)
        default:
            print("index out of range")
        }
    }
    
    /* Misc Functions */
    
    func configureTextFieldAttributes(textField: UITextField) {
        switch textField.tag {
        case FieldType.Email.rawValue:
            textField.autocapitalizationType = .None
            textField.keyboardType = UIKeyboardType.EmailAddress
        case FieldType.Phone.rawValue:
            textField.keyboardType = UIKeyboardType.PhonePad
        case FieldType.CardNumber.rawValue:
            textField.keyboardType = UIKeyboardType.NumberPad
        case FieldType.Expiration.rawValue:
            textField.keyboardType = UIKeyboardType.NumberPad
        case FieldType.CCV.rawValue:
            textField.keyboardType = UIKeyboardType.NumberPad
            textField.secureTextEntry = true
        case FieldType.Zip.rawValue:
            textField.keyboardType = UIKeyboardType.NumberPad
        case FieldType.Password.rawValue:
            textField.secureTextEntry = true
        case FieldType.PasswordConfirmation.rawValue:
            textField.secureTextEntry = true
        case FieldType.College.rawValue:
            pickerView = UIPickerView()
            pickerView?.dataSource = self
            pickerView?.delegate = self
            textField.inputAccessoryView = self.getKeyboardAccessoryWithTitle("Done", selector: Selector("hideKeyboard"))
            textField.inputView = pickerView
        default:
            textField.keyboardType = UIKeyboardType.Default
            textField.secureTextEntry = false
        }
    }

    func closeSignUpView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func showAlertView(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

    func showSignUpAlertView(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: { void in
            let requestsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainNavController") as! MainNavController
            
            let nav = self.navigationController! as! RootNavController
            let root = nav.parentDelegate as! RootViewController
            root.mainVC = requestsVC
            root.addChildViewController(requestsVC)
            root.view.addSubview(requestsVC.view)
            root.pageControl.hidden = true
            root.mainVC!.didMoveToParentViewController(root)
            nav.dismissViewControllerAnimated(true, completion: nil)
            root.pageVC!.removeFromParentViewController()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func getCollegeOptions() {
        ParseRequest.getCollegeOptions() { data, error in
            if let error = error {
                self.showAlertView(error.localizedDescription, message: error.localizedFailureReason)
            } else {
                if let colleges = data {
                    self.PFColleges = colleges
                    for college in colleges {
                        self.colleges.append(college["name"] as! String)
                    }
                }
            }
        }
    }
    
}
