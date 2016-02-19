//
//  MainNavController.swift
//  Dormy
//
//  Created by Josh Siegel on 11/24/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit

class MainNavController: UINavigationController {

    deinit {
        print("MNC is deallocated")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
