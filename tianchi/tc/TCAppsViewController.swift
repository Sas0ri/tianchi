//
//  TCAppsViewController.swift
//  tc
//
//  Created by Sasori on 16/9/1.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCAppsViewController: UIViewController {

    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var voiceUpButton: UIButton!
    @IBOutlet weak var voiceDownButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var fontSize:CGFloat = 14
        if UI_USER_INTERFACE_IDIOM() == .Phone {
            fontSize = 8
        }
        self.muteButton.titleLabel?.font = UIFont.systemFontOfSize(fontSize)
        self.menuButton.titleLabel?.font = UIFont.systemFontOfSize(fontSize)
        self.backButton.titleLabel?.font = UIFont.systemFontOfSize(fontSize)
        self.voiceUpButton.titleLabel?.font = UIFont.systemFontOfSize(fontSize)
        self.voiceDownButton.titleLabel?.font = UIFont.systemFontOfSize(fontSize)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
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
