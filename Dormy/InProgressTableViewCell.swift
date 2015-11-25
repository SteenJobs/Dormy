//
//  RequestTableViewCell.swift
//  Dormy
//
//  Created by Josh Siegel on 11/24/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit

class InProgressTableViewCell: UITableViewCell {

    @IBOutlet weak var cleanerLabel: UILabel!
    @IBOutlet weak var requestedDateLabel: UILabel!
    @IBOutlet weak var packageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
