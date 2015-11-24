//
//  SignUpViewController.swift
//  Dormy
//
//  Created by Josh Siegel on 11/18/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var textField1: UITextField!
    @IBOutlet var textField2: UITextField!
    @IBOutlet var textField3: UITextField!
    @IBOutlet var textField4: UITextField!
    @IBOutlet var completeButton: UIButton!
    @IBOutlet var TFHeight: NSLayoutConstraint!
    
    var index: Int = 0
    var numberOfTextFields: Int?
    var textFields: [UITextField]?
    var placeHolderDict = [["E-mail Address", "Phone Number", "Password", "Confirm Password"], ["Full Name", "Choose Your College", "Dorm Building", "Room Number"], ["Card Number", "CCV", "Zip Code"]]
    var navBarTitle = ["SIGN UP", "CREATE PROFILE", "CREATE PROFILE"]
    var buttons = ["signup-next", "signup-next", "signup-done"]
    
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
                RegistrationInfo.sharedInstance.CCV = textField2.text
                RegistrationInfo.sharedInstance.zip = textField3.text
            default:
                print("index out of range")
            }
        
        if self.completeButton.tag == 0 {
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SignUpViewController") as! SignUpViewController
            let currentVC = self.navigationController!.visibleViewController as! SignUpViewController
            let currentIndex = currentVC.index
            //let nextVC = segue.destinationViewController as! SignUpViewController
            nextVC.index = currentIndex + 1
            self.navigationController!.pushViewController(nextVC, animated: true)
        } else {
            // Save user to parse
            // Remove values from RegistrationInfo instance
            RegistrationInfo.sharedInstance.resetRegistrationInfo()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.completeButton.setBackgroundImage(UIImage(named: buttons[self.index]), forState: .Normal)
        if buttons[self.index] == "signup-done" {
            self.completeButton.tag = 1
        } else {
            self.completeButton.tag = 0
        }
        
        numberOfTextFields = placeHolderDict[index].count
        textFields = [self.textField1, self.textField2, self.textField3, self.textField4]
        let slice = textFields![self.numberOfTextFields!..<textFields!.count]
        for textField in slice {
            textField.hidden = true
        }
        
        let placeHolders = self.placeHolderDict[self.index]
        let z = zip(textFields!, placeHolders)
        for (textField, placeHolder) in z {
            textField.placeholder = placeHolder
            textField.clearButtonMode = UITextFieldViewMode.WhileEditing
            switch placeHolder {
            case "E-mail Address":
                textField.keyboardType = UIKeyboardType.EmailAddress
            case "Phone Number":
                textField.keyboardType = UIKeyboardType.PhonePad
            case "Card Number":
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

    func closeSignUpView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let currentValues = RegistrationInfo.sharedInstance.getExistingTextFields(self.index)
        let z = zip(textFields!, currentValues)
        for (textField, currentValue) in z {
            textField.text = currentValue
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
