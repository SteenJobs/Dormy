//
//  LogInViewController.swift
//  Dormy
//
//  Created by Josh Siegel on 12/29/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import FBSDKCoreKit
import MBProgressHUD

class LogInViewController: UIViewController, UINavigationBarDelegate {

    @IBOutlet weak var TFHeight: NSLayoutConstraint!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    var parentDelegate: UIViewController!
    
    @IBAction func facebookLoginTapped(sender: AnyObject) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile"]) {
            (user: PFUser?, error: NSError?) -> Void in
            if let error = error {
                print(error)
            }
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                } else {
                    print("User logged in through Facebook!")
                }
                self.presentMainView()
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
    
    @IBAction func loginTapped(sender: AnyObject) {
        let activityIndicator = MBProgressHUD(view: self.view)
        activityIndicator.labelText = "Signing In..."
        self.view.addSubview(activityIndicator)
        activityIndicator.show(true)
        
        let username = self.emailTF.text!.lowercaseString
        let password = self.passwordTF.text!
        PFUser.logInWithUsernameInBackground(username, password: password) {
            (user: PFUser?, error: NSError?) -> Void in
            activityIndicator.hide(true)
            if user != nil {
                self.presentMainView()
            } else {
                if let error = error {
                    print(error)
                    let alert = UIAlertController(title: error.localizedDescription, message: error.localizedFailureReason, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func presentMainView() {
        let requestsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainNavController") as! MainNavController
        
        let root = self.parentDelegate as! RootViewController
        root.mainVC = requestsVC
        root.addChildViewController(requestsVC)
        root.view.addSubview(requestsVC.view)
        root.pageControl.hidden = true
        root.mainVC!.didMoveToParentViewController(root)
        self.dismissViewControllerAnimated(true, completion: nil)
        root.pageVC!.removeFromParentViewController()
        root.pageVC = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBar.delegate = self
        
        let x = NSString(string: "HELLO").sizeWithAttributes([NSFontAttributeName: UIFont(name: "Lucida Grande", size: 30.0)!])
        let adjustedSize = CGSizeMake(ceil(x.width), ceil(x.height))
        TFHeight.constant = adjustedSize.height + 15.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navBar.barTintColor = UIColor(rgba: "#0B376D")
        self.navItem.title = "SIGN IN"
        self.navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: Selector("closeSignUpView"))
        self.navItem.rightBarButtonItem = doneButton
        self.navItem.rightBarButtonItem!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Normal)
        self.navItem.rightBarButtonItem!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: .Highlighted)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    func closeSignUpView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


}
