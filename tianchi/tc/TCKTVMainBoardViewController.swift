//
//  TCKTVMainBoardViewController.swift
//  tc
//
//  Created by Sasori on 16/6/14.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

typealias navToNextBlock = ()->()

class TCKTVMainBoardViewController: UIViewController {

    var didNavToNext:navToNextBlock? = nil
    var didNavBack:navToNextBlock? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if self.didNavBack != nil {
            self.didNavBack!()
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if self.didNavToNext != nil && self.navigationController?.viewControllers.count > 1 {
            self.didNavToNext!()
        }
    }
    
    @IBAction func songNameAction(sender: AnyObject) {
        let songNameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ktv_song_name")
        self.navigationController?.pushViewController(songNameVC, animated: false)
    }
    
    @IBAction func singerAction(sender: AnyObject) {
        let songNameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ktv_singer")
        self.navigationController?.pushViewController(songNameVC, animated: false)
    }
    
    @IBAction func languageAction(sender: AnyObject) {
        let songNameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ktv_language")
        self.navigationController?.pushViewController(songNameVC, animated: false)
    }
    
    @IBAction func categoryAction(sender: AnyObject) {
        let songNameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ktv_category")
        self.navigationController?.pushViewController(songNameVC, animated: false)
    }
    
    @IBAction func songlistAction(sender: AnyObject) {
        let songNameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ktv_ranking_songs") as! TCKTVSongsViewController
        songNameVC.ranking = true
        self.navigationController?.pushViewController(songNameVC, animated: false)
    }
    
    @IBAction func cloudAction(sender: AnyObject) {
        let songNameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ktv_songs_from_cloud") as! TCKTVSongsViewController
        songNameVC.cloud = true
        self.navigationController?.pushViewController(songNameVC, animated: false)
    }
    
    @IBAction func downloadAction(sender: AnyObject) {
        let songNameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ktv_songs_from_download") as! TCKTVSongsViewController
        songNameVC.download = true
        self.navigationController?.pushViewController(songNameVC, animated: false)
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
