//
//  ReviewViewControllerP1.swift
//  Dormy
//
//  Created by Josh Siegel on 2/2/16.
//  Copyright © 2016 Dormy. All rights reserved.
//

import UIKit

class ReviewViewControllerP1: UIViewController {

    @IBOutlet weak var starRatingView: FloatRatingView!
    @IBOutlet weak var reviewTextView: UITextView!
    var delegate: ReviewViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
