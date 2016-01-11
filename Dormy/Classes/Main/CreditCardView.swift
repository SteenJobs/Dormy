//
//  CreditCardView.swift
//  Dormy
//
//  Created by Josh Siegel on 12/30/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit

class CreditCardView: UIView {
    var foldView: UITextField?
    var headerView: UITextField?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = 1 / -900
        self.layer.sublayerTransform = perspectiveTransform
    }
    
    func valueChanges(check: UIButton) {
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.2, options: .AllowAnimatedContent, animations: {
            let angle = !check.selected ? -90 : 0
            self.foldView!.layer.transform = CATransform3DMakeRotation(self.toRadian(angle), 1.0, 0, 0)
            self.layoutStack()
            self.frame.size.height = CGRectGetMaxY(self.foldView!.frame) + 10
            }, completion: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutStack()
    }
    
    func foldFrame(withTop top: CGFloat) -> CGRect {
        return CGRectMake(headerView!.frame.origin.x, top, headerView!.bounds.size.width, 80)
    }
    
    func layoutStack() {
        foldView!.layer.anchorPoint = CGPointMake(0.5, 0.0)
        foldView!.layer.doubleSided = false
        let margin: CGFloat = 10
        foldView!.frame = foldFrame(withTop: CGRectGetMaxY(headerView!.frame) - foldView!.layer.borderWidth)
    }
    
    func toRadian(value: Int) -> CGFloat {
        return CGFloat(Double(value) / 180.0 * M_PI)
    }

}
