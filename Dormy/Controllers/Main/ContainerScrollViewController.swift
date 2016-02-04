//
//  ContainerScrollViewController.swift
//  Dormy
//
//  Created by Josh Siegel on 1/15/16.
//  Copyright © 2016 Dormy. All rights reserved.
//

import UIKit

class ContainerScrollViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var pageOneVC: ReviewViewControllerP1?
    var pageTwoVC: ReviewViewControllerP2?
    var pageThreeVC: ReviewViewControllerP2?
    
    var job: Job?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.delegate = self
        
        pageOneVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ReviewViewControllerP1") as? ReviewViewControllerP1
        pageTwoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ReviewViewControllerP2") as? ReviewViewControllerP2
        pageThreeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ReviewViewControllerP2") as? ReviewViewControllerP2
        
        let viewControllers = [pageOneVC!, pageTwoVC!, pageThreeVC!]
        
        let bounds = UIScreen.mainScreen().bounds
        let width = bounds.size.width
        let height = self.scrollView.frame.size.height

        scrollView!.contentSize = CGSizeMake(CGFloat(viewControllers.count) * width, height)
        
        var idx: Int = 0
        for viewController in viewControllers {
            // index is the index within the array
            // participant is the real object contained in the array
            addChildViewController(viewController);
            let originX:CGFloat = CGFloat(idx) * width;
            viewController.view.frame = CGRectMake(originX, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
            self.scrollView!.addSubview(viewController.view)
            viewController.didMoveToParentViewController(self)
            idx++
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let parentVC = self.parentViewController as! ReviewViewController
        self.job = parentVC.job
        
        self.loadReviewImages()
        self.setPageControlProperties(0)
        
        
        pageTwoVC!.imageLabel.text = "BEFORE"
        pageThreeVC!.imageLabel.text = "AFTER"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        scrollView.contentSize.height = self.scrollView.frame.size.height
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var width = scrollView.frame.size.width;
        var page = (scrollView.contentOffset.x)  / width;
        var pageNumber = round(page)
        
        
        switch pageNumber {
        case 0.0:
            setPageControlProperties(0)
        case 1.0:
            setPageControlProperties(1)
        case 2.0:
            setPageControlProperties(2)
        default:
            print("Page not in range")
        }
    
    }

    func setPageControlProperties(index: Int) {
        self.pageControl?.pageIndicatorTintColor = UIColor(rgba: "#0B376D")
        self.pageControl?.currentPageIndicatorTintColor = UIColor.whiteColor()
        self.pageControl?.currentPage = index
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func loadReviewImages() {
        let before_photo = self.job?.before_photo
        let after_photo = self.job?.after_photo
        
        let beforeImageView = self.pageTwoVC?.dormImage
        let afterImageView = self.pageThreeVC?.dormImage
        
        let activityIndicator1 = MBProgressHUD(view: beforeImageView)
        activityIndicator1.mode = .AnnularDeterminate
        beforeImageView!.addSubview(activityIndicator1)
        activityIndicator1.show(true)
        
        let activityIndicator2 = MBProgressHUD(view: afterImageView)
        activityIndicator2.mode = .AnnularDeterminate
        afterImageView!.addSubview(activityIndicator2)
        activityIndicator2.show(true)
        
        before_photo?.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
            if let imageData = imageData {
                let beforeImage = UIImage(data: imageData)
                beforeImageView?.image = beforeImage
                activityIndicator1.hide(true)
            }
        }, progressBlock: { (percentDone: Int32) -> Void in
            activityIndicator1.progress = Float(percentDone/100)
        })
        
        after_photo?.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
            if let imageData = imageData {
                let afterImage = UIImage(data: imageData)
                afterImageView?.image = afterImage
                activityIndicator2.hide(true)
            }
        }, progressBlock: { (percentDone: Int32) -> Void in
            activityIndicator2.progress = Float(percentDone/100)
        })
        
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
