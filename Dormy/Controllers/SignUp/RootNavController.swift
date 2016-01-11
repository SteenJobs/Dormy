//
//  SignUpNavController.swift
//  Dormy
//
//  Created by Josh Siegel on 11/18/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit

class RootNavController: UINavigationController {
    
    var parentDelegate: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.navigationBar.translucent = false
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationBar.barTintColor = UIColor(rgba: "#0B376D")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    


}
