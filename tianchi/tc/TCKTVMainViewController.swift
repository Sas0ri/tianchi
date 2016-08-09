//
//  TCKTVMainViewController.swift
//  tc
//
//  Created by Sasori on 16/6/13.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCKTVMainViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var navBackground: UIImageView!
    
    var mainVC:UINavigationController!
    var orderedVC:UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ktv_main") as!TCKTVMainBoardViewController

        let navVC = UINavigationController(rootViewController: mainVC)
        self.addChildViewController(navVC)
        navVC.didMoveToParentViewController(self)
        self.containerView.addSubview(navVC.view)
        navVC.view.frame = self.containerView.bounds
        mainVC.didNavToNext = {
            self.navBackground.hidden = true
        }
        mainVC.didNavBack = {
            self.navBackground.hidden = false
        }

        self.mainVC = navVC
        
        let orderedVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ktv_songs_from_ordered") as! TCKTVSongsViewController
        orderedVC.ordered = true
        self.addChildViewController(orderedVC)
        orderedVC.didMoveToParentViewController(self)
        orderedVC.view.frame = self.containerView.bounds
        orderedVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.orderedVC = orderedVC
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(sender: AnyObject) {
        if self.mainVC.viewControllers.count > 1 {
            self.mainVC.popViewControllerAnimated(false)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Bottom Controller

    @IBAction func mainAction(sender: AnyObject) {
        self.containerView.addSubview(self.mainVC.view)
        self.orderedVC.view.removeFromSuperview()
        self.navBackground.hidden = self.mainVC.viewControllers.count > 1
    }
    
    @IBAction func orderedAction(sender: AnyObject) {
        self.mainVC.view.removeFromSuperview()
        self.containerView.addSubview(self.orderedVC.view)
        self.containerView.addConstraint(NSLayoutConstraint(item: self.orderedVC.view, attribute: .Leading, relatedBy: .Equal, toItem: containerView, attribute: .Leading, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.orderedVC.view, attribute: .Trailing, relatedBy: .Equal, toItem: containerView, attribute: .Trailing, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.orderedVC.view, attribute: .Top, relatedBy: .Equal, toItem: containerView, attribute: .Top, multiplier: 1, constant: 0))
        self.containerView.addConstraint(NSLayoutConstraint(item: self.orderedVC.view, attribute: .Bottom, relatedBy: .Equal, toItem: containerView, attribute: .Bottom, multiplier: 1, constant: 0))
        self.containerView.layoutIfNeeded()
        self.navBackground.hidden = true
    }
    
    @IBAction func muteAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 1203
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func volumnUpAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 1201
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func volumnDownAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 1202
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func pauseAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 1103
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func originAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 1104
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func switchAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 1102
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func replayAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 1101
        TCContext.sharedContext().socketManager.sendPayload(payload)
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
