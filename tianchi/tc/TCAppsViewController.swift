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
        if UI_USER_INTERFACE_IDIOM() == .phone {
            fontSize = 8
        }
        self.muteButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        self.menuButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        self.backButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        self.voiceUpButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        self.voiceDownButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        TCAppsContext.sharedContext().connect()
        TCAppsViewController.currentAppsViewController = self
        self.loadData()
    }
    
    func loadData() {
        let payload = TCSocketPayload()
        payload.cmdType = 2112
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }

    func handleData(_ data:String) {
        self.apps = data.components(separatedBy: ",")
        self.apps = self.apps.filter({ (app) -> Bool in
            return app.characters.count > 0
        })
        self.collectionView.reloadData()
    }
    
    // MARK: - CollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.apps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "app", for: indexPath) as! TCKTVSingerCell
        let app = self.apps[(indexPath as NSIndexPath).item]
        cell.singerNameLabel.text = app
        if let image = UIImage(named: app) {
            cell.singerImageView.image = image
        } else {
            cell.singerImageView.image = UIImage(named: "apps_default")
        }
        
        return cell
    }
    
    // MARK: - CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let app = self.apps[(indexPath as NSIndexPath).item]
        let payload = TCSocketPayload()
        payload.cmdType = 2104
        payload.cmdContent = JSON(app as AnyObject)
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Panel
    @IBAction func mutaAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2103
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func upAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2105
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func leftAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2107
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func downAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2106
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func rightAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2108
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func okAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2109
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func menuAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2110
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func returnAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2111
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func volumnUpAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2114
        TCAppsContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func volumnDownAction(_ sender: AnyObject) {
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
