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

class SignUpViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, STPPaymentCardTextFieldDelegate {

    @IBOutlet var textField1: RegistrationFields!
    @IBOutlet var textField2: RegistrationFields!
    @IBOutlet var textField3: RegistrationFields!
    @IBOutlet var textField4: RegistrationFields!
    var stripeField: STPPaymentCardTextField?
    @IBOutlet var completeButton: UIButton!
    @IBOutlet var TFHeight: NSLayoutConstraint!
    
    var pickerView: UIPickerView?
    var index: Int = 0
    var numberOfTextFields: Int?
    var textFields: [RegistrationFields]?
    // Change placeholders to type attribute so still works even if remove placeholders
    var placeHolderDict = [["E-mail Address", "Phone Number", "Password", "Confirm Password"], ["Full Name", "Choose Your College", "Dorm Building", "Room Number"], ["Card Number", "Expiration Date", "CCV", "Zip Code"]]
    var navBarTitle = ["SIGN UP", "CREATE PROFILE", "CREATE PROFILE"]
    var buttons = ["signup-next", "signup-next", "signup-done"]
    
    // Placeholder for Parse data - set with single value of "--"
    var colleges = ["--"] //["YU", "Columbia", "NYU", "BU"]
    
    let validator = Validator()
    
    @IBAction func completeButtonTapped(sender: AnyObject) {
        switch self.index {
        case 0:
            RegistrationInfo.sharedInstance.email = textField1.text
            RegistrationInfo.sharedInstance.phone = textField2.text
            RegistrationInfo.sharedInstance.password = textField3.text
            RegistrationInfo.sharedInstance.confirmPassword = textField4.text
        case 1:
            RegistrationInfo.sharedInstance.fullName = textField1.text
            RegistrationInfo.sharedInstance.college = textField2.text
            RegistrationInfo.sharedInstance.dormBuilding = textField3.text
            RegistrationInfo.sharedInstance.roomNumber = textField4.text
        case 2:
            RegistrationInfo.sharedInstance.cardNumber = textField1.text
            RegistrationInfo.sharedInstance.expirationDate = textField2.text
            RegistrationInfo.sharedInstance.CCV = textField3.text
            RegistrationInfo.sharedInstance.zip = textField4.text
        default:
            print("index out of range")
        }
        
        if !self.validateSubmission() {
            //self.showAlertView("Error", message: "Please fix any errors before continuing.")
            //return
        }
        
        if self.completeButton.tag == 0 {
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController
            let currentVC = self.navigationController!.visibleViewController as! SignUpViewController
            let currentIndex = currentVC.index
            //let nextVC = segue.destinationViewController as! SignUpViewController
            nextVC.index = currentIndex + 1
            self.navigationController!.pushViewController(nextVC, animated: true)
        } else {
            //TODO: Save user to parse
            self.signUp()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.getCollegeOptions()
        
        self.completeButton.setBackgroundImage(UIImage(named: buttons[self.index]), forState: .Normal)
        if buttons[self.index] == "signup-done" {
            self.completeButton.tag = 1
        } else {
            self.completeButton.tag = 0
        }
        
        pickerView = UIPickerView()
        pickerView?.dataSource = self
        pickerView?.delegate = self
        
        numberOfTextFields = placeHolderDict[index].count
        textFields = [self.textField1, self.textField2, self.textField3, self.textField4]
        
        
        let slice = textFields![self.numberOfTextFields!..<textFields!.count]
        for textField in slice {
            textField.hidden = true
        }
        
        let placeHolders = self.placeHolderDict[self.index]
        let z = zip(textFields!, placeHolders)
        for (textField, placeHolder) in z {
            textField.delegate = self
            textField.placeholder = placeHolder
            textField.type = placeHolder
            textField.clearButtonMode = UITextFieldViewMode.WhileEditing
            textField.addTarget(self, action: Selector("checkTextField:"), forControlEvents: UIControlEvents.EditingChanged)

            switch placeHolder {
            case "E-mail Address":
                textField.keyboardType = UIKeyboardType.EmailAddress
            case "Phone Number":
                textField.keyboardType = UIKeyboardType.PhonePad
                //validator.registerField(textField, rules: [RequiredRule(), PhoneNumberRule()])
            case "Card Number":
                textField.keyboardType = UIKeyboardType.NumberPad
            case "Expiration Date":
                textField.keyboardType = UIKeyboardType.NumberPad
            case "CCV":
                textField.keyboardType = UIKeyboardType.NumberPad
                textField.secureTextEntry = true
            case "Zip Code":
                textField.keyboardType = UIKeyboardType.NumberPad
            case "Password":
                textField.secureTextEntry = true
            case "Confirm Password":
                textField.secureTextEntry = true
            case "Choose Your College":
                textField.inputView = pickerView
            default:
                textField.keyboardType = UIKeyboardType.Default
                textField.secureTextEntry = false
            }
        }
        
    
        
        let x = NSString(string: "HELLO").sizeWithAttributes([NSFontAttributeName: UIFont(name: "Lucida Grande", size: 30.0)!])
        let adjustedSize = CGSizeMake(ceil(x.width), ceil(x.height))
        TFHeight.constant = adjustedSize.height + 15.0
        
        
        // Do any additional setup after loading the view.
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
        self.navigationItem.title = navBarTitle[self.index]
        let backButton = UIBarButtonItem(title: " ", style: .Plain, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: Selector("closeSignUpView"))
        self.navigationItem.backBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = doneButton
        self.completeButton.setBackgroundImage(UIImage(named: buttons[self.index]), forState: .Normal)
    }

    
    // TextField Delegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        var registrationField: RegistrationFields?
        for field in self.textFields! {
            if field == textField {
                registrationField = field
            }
        }
        if let field = registrationField {
            if field.error == true {
                field.validate()
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let filter = self.textFields?.filter({(tf: RegistrationFields) -> Bool in return tf.type == "Choose Your College"})
        if filter?.count > 0 {
            let collegeTF = filter!.first!
            if textField == collegeTF {
                collegeTF.text = self.colleges[0]
            }
        }
    }
    
    var cardBrand: STPCardBrand?
    func checkTextField(sender: UITextField) {
        let textField = sender
    
        if self.index == 2 {
            switch textField.placeholder! {
            case "Card Number":
                let validation = STPCardValidator.validationStateForNumber(textField.text!, validatingCardBrand: true)
                let isValidated = self.validateCardField(validation, textField: textFields![0])
                if isValidated {
                    cardBrand = STPCardValidator.brandForNumber(textField.text!)
                }
            case "Expiration Date":
                let date = Expiration.cardExpiryWithString(textField.text!)
                let validation = STPCardValidator.validationStateForExpirationYear(date.year!, inMonth: date.month!)
                self.validateCardField(validation, textField: textFields![1])
            case "CCV":
                if let brand = self.cardBrand {
                    let validation = STPCardValidator.validationStateForCVC(textField.text!, cardBrand: brand)
                    self.validateCardField(validation, textField: textFields![2])
                } else {
                    self.validateCardField(STPCardValidationState.Invalid, textField: textFields![2])
                }
            default:
                print("Not a CC Field")
            }
        }

    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.inputView != nil && textField.inputView!.isMemberOfClass(UIPickerView) {
            return false
        }
        if textField.placeholder == "Expiration Date" {
            let date = Expiration.cardExpiryWithString(textField.text! + string)
            let year = date.year!
            if string != "" {
                if year.characters.count < 3 {
                    textField.text = date.formattedStringWithTrail()
                    let validation = STPCardValidator.validationStateForExpirationYear(date.year!, inMonth: date.month!)
                    self.validateCardField(validation, textField: textFields![1])
                }
                return false
            }
        }
        
        return true
    }
    

    func validateCardField(state: STPCardValidationState, textField: RegistrationFields) -> Bool {
        if textField.text!.isEmpty {
            textField.layer.borderColor = UIColor.blackColor().CGColor
            textField.layer.borderWidth = 0.0
            return false
        }
        if state == STPCardValidationState.Valid {
            textField.markCardField(true)
            return true
        } else {
            textField.markCardField(false)
            return false
        }
    }
    
    // Picker data source
    
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
        let filter = self.textFields?.filter({(tf: RegistrationFields) -> Bool in return tf.type == "Choose Your College"})
        if filter?.count > 0 {
            let collegeTF = filter!.first!
            collegeTF.text = self.colleges[row]
            //collegeTF.resignFirstResponder()
        }
    }
    
    
    // Misc Functions

    func validateSubmission() -> Bool {
        let currentTextFields = self.textFields![0..<self.numberOfTextFields!]
        
        var validations: [Bool] = []
        for textField in currentTextFields {
            validations.append(textField.validate())
        }
        if validations.contains(false) {
            return false
        } else {
            return true
        }
    }
    
    func closeSignUpView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // User Sign Up
    
    //??? Move to RegistrationInfo Class?

    func signUp() {
        var user = PFUser()
        let userInfo = RegistrationInfo.sharedInstance
        user.username = userInfo.email
        user.password = userInfo.password
        user.email = userInfo.email
        user["phone"] = userInfo.phone
        user["full_name"] = userInfo.fullName
        user["college"] = userInfo.college
        user["dorm_building"] = userInfo.dormBuilding
        user["room_number"] = userInfo.roomNumber
        
        user.signUpInBackgroundWithBlock() { (succeeded: Bool, error: NSError?) -> Void in
            if let error = error {
                if let errorString = error.userInfo["error"] as? String {
                    self.showAlertView("Error", message: errorString)
                }
            } else {
                //TODO: Notify user that email verification has been sent
                self.showAlertView("Thank you for registering with Dormy!", message: "A verification email will be sent to the address you provided. Once you've verified your account you will be able to start booking jobs.")
                //TODO: Present user with login screen
                // Remove values from RegistrationInfo instance
                RegistrationInfo.sharedInstance.resetRegistrationInfo()
            }
        }
    }
    
    func getCollegeOptions() {
        let query = PFQuery(className: "College")
        query.findObjectsInBackgroundWithBlock() { (colleges: [PFObject]?, error: NSError?) -> Void in
            if let error = error {
                if let errorString = error.userInfo["error"] as? String {
                    self.showAlertView("Error", message: errorString)
                }
            } else {
                if let colleges = colleges {
                    let orderedColleges = colleges.sort({ (college1, college2) in
                        let order1 = college1["order"] as! Int
                        let order2 = college2["order"] as! Int
                        return order1 < order2
                    })
                    self.colleges = ["--"]
                    for college in orderedColleges {
                        self.colleges.append(college["name"] as! String)
                    }
                }
            }
        }
    }
}
