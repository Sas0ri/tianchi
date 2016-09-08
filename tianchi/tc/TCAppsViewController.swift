//
//  TCAppsViewController.swift
//  tc
//
//  Created by Sasori on 16/9/1.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCAppsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var voiceUpButton: UIButton!
    @IBOutlet weak var voiceDownButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak static var currentAppsViewController:TCAppsViewController?
    var apps:[String] = [String]()
    
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
        TCAppsContext.sharedContext().connect()
        TCAppsViewController.currentAppsViewController = self
        self.loadData()
    }
    
    func loadData() {
        let payload = TCSocketPayload()
        payload.cmdType = 2112
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }

    func handleData(data:String) {
        self.apps = data.componentsSeparatedByString(",")
        self.collectionView.reloadData()
    }
    
    // MARK: - CollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.apps.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("app", forIndexPath: indexPath) as! TCKTVSingerCell
        let app = self.apps[indexPath.item]
        cell.singerNameLabel.text = app
        return cell
    }
    
    // MARK: - CollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        let app = self.apps[indexPath.item]
        let payload = TCSocketPayload()
        payload.cmdType = 2104
        payload.cmdContent = JSON(app)
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - Panel
    @IBAction func mutaAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2103
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func upAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2105
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func leftAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2107
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func downAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2106
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func rightAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2108
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func okAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2109
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func menuAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2110
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func returnAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2111
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func volumnUpAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2114
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func volumnDownAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2115
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    deinit {
        TCAppsContext.sharedContext().disconnect()
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
