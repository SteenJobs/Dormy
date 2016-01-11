//
//  WelcomeContentViewController.swift
//  Dormy
//
//  Created by Josh Siegel on 11/9/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit

class WelcomeContentViewController: UIViewController {

    @IBOutlet var outerView: UIView!
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var pageSubtitle: UILabel!
    @IBOutlet weak var pageImage: UIImageView!
    
    var currentImage: String?
    var currentTitle: String?
    var currentSubtitle: String?
    var currentBackgroundColor: String?
    var currentTextColor: String?
    var pageIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pageTitle.text = self.currentTitle
        self.pageTitle.textColor = UIColor(rgba: self.currentTextColor!)
        self.pageSubtitle.text = self.currentSubtitle
        self.pageSubtitle.textColor = UIColor(rgba: self.currentTextColor!)
        self.pageImage.image = UIImage(named: self.currentImage!)
        self.view.backgroundColor = UIColor(rgba: self.currentBackgroundColor!)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
