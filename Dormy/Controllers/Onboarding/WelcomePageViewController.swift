//
//  WelcomePageViewController.swift
//  Dormy
//
//  Created by Josh Siegel on 11/9/15.
//  Copyright © 2015 Dormy. All rights reserved.
//

import UIKit

class WelcomePageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var imageArray = ["book-logo", "clean-logo", "joy-logo"]
    var titleArray = ["BOOK", "CLEAN", "JOY"]
    var backgroundColors = ["#FFFFFF", "#0B376D", "#FFFFFF"]
    var textColors = ["#0B376D", "#FFFFFF", "#0B376D"]
    var subtitleArray = ["Tell us when and where\n" + "you want your dorm cleaning.", "A certified student cleaner comes\n" + "over and cleans your dorm.", "Sit back, relax, and enjoy your life\n" + "with a clean dorm!"]
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var pageControl: UIPageControl?
    var currentIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.clearColor()
        dataSource = self
        delegate = self
        
        self.setViewControllers([self.getFirstVC()], direction: .Forward, animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setPageControlProperties(index: Int) {
        if self.backgroundColors[index] == "#FFFFFF" {
            self.pageControl?.pageIndicatorTintColor = UIColor(rgba: "#0B376D")
        } else {
            self.pageControl?.pageIndicatorTintColor = UIColor(rgba: "#FFFFFF")
        }
        self.pageControl?.currentPageIndicatorTintColor = UIColor(rgba: "#929292")
        self.pageControl?.currentPage = index
    }
    
    // UIPVC Data Source
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if let viewController = pendingViewControllers.first {
            let index = (viewController as! WelcomeContentViewController).pageIndex
            setPageControlProperties(index)
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if !completed {
            if let viewController = previousViewControllers.first {
                let index = (viewController as! WelcomeContentViewController).pageIndex
                setPageControlProperties(index)
            }
        }
    }
    
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! WelcomeContentViewController).pageIndex
        index++
        if (index >= self.imageArray.count) {
            return nil
        }
        
        
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as! WelcomeContentViewController).pageIndex
        if (index <= 0) {
            return nil
        }
        index--
        
        
        
        return self.viewControllerAtIndex(index)
    }
    
    
    // Initialize default VC
    
    func getFirstVC() -> WelcomeContentViewController {
        setPageControlProperties(0)
        return self.viewControllerAtIndex(0)!
    }
    
    func viewControllerAtIndex(index: Int) -> WelcomeContentViewController? {
        if((self.imageArray.count == 0) || (index >= self.imageArray.count)) {
            return nil
        }
        let pageContentViewController = mainStoryboard.instantiateViewControllerWithIdentifier("WelcomeContentViewController") as! WelcomeContentViewController
        
        pageContentViewController.pageIndex = index
        pageContentViewController.currentTitle = self.titleArray[index]
        pageContentViewController.currentSubtitle = self.subtitleArray[index]
        pageContentViewController.currentImage = self.imageArray[index]
        pageContentViewController.currentBackgroundColor = self.backgroundColors[index]
        pageContentViewController.currentTextColor = self.textColors[index]
        return pageContentViewController
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
