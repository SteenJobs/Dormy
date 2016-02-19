//
//  RequestsViewController.swift
//  Dormy
//
//  Created by Josh Siegel on 11/24/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit

class RequestsViewController: UIViewController {

    @IBOutlet weak var getCleanButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let navBar = self.navigationController!.navigationBar
        let settingsButton = UIBarButtonItem(image: UIImage(named: "gear-icon"), style: .Plain, target: self, action: Selector("goToProfile"))
        
        self.navigationItem.rightBarButtonItem = settingsButton
        
        navBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar.shadowImage = UIImage()
        navBar.tintColor = UIColor.whiteColor()
        navBar.translucent = true
        navBar.barTintColor = UIColor(rgba: "#0f386b")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToProfile() {
        let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        self.presentViewController(profileVC, animated: true, completion: nil)
    }



}
