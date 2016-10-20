//
//  TCFullAppsViewController.swift
//  tc
//
//  Created by Sasori on 2016/10/20.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCFullAppsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var apps:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(TCAppsViewController.loadData), name: NSNotification.Name(TCAppsContext.CanLoadAppsNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TCAppsViewController.handleData(_:)), name: NSNotification.Name(TCAppsContext.DidLoadAppsNotification), object: nil)

        self.loadData()
    }
    
    func loadData() {
        let payload = TCSocketPayload()
        payload.cmdType = 2112
        
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    func handleData(_ sender:Notification) {
        let data = sender.object as! String
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
        if tcVersion == .full {
            TCContext.sharedContext().socketManager.sendPayload(payload)
        } else {
            TCAppsContext.sharedContext().socketManager.sendPayload(payload)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
