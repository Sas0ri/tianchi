//
//  TVKTVSongNameViewController.swift
//  tc
//
//  Created by Sasori on 16/6/14.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCKTVSongNameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, TCKTVSongCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var page:Int = 0
    var words:String = "1"
    var client = TCKTVSongClient()
    var songs:[TCKTVSong] = [TCKTVSong]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.segmentedControl.clipsToBounds = true
        self.segmentedControl.layer.cornerRadius = 4
        self.segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(14)], forState: .Selected)
        self.segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(14)], forState: .Normal)
        self.segmentedControl.setBackgroundImage(UIImage(color: UIColor(fromHexCode:"171717"), cornerRadius: 0), forState: .Normal, barMetrics: .Default)
        self.segmentedControl.setBackgroundImage(UIImage(color: UIColor(fromHexCode:"fb8808"), cornerRadius: 0), forState: .Selected, barMetrics: .Default)
        self.segmentedControl.selectedSegmentIndex = 0
        // Do any additional setup after loading the view.
        
        self.searchBar.setImage(UIImage(named: "ktv_search_icon"), forSearchBarIcon: .Search, state: .Normal)
        if let subViews = self.searchBar.subviews.last?.subviews {
            for v in  subViews {
                if v.isKindOfClass(UITextField) {
                    let tf = v as! UITextField
                    tf.backgroundColor = UIColor.clearColor()
                }
            }
        }
        self.loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func segChanged(sender: AnyObject) {
        self.page = 1
        self.words = "\(self.segmentedControl.selectedSegmentIndex)"
        self.loadData()
    }
    
    func loadData() {
        self.client.getSongsByName(self.searchBar.text, words: self.words, page: self.page) { (songs, flag) in
            if flag {
                self.songs = songs!
                self.collectionView.reloadData()
            } else {
                self.view.showTextAndHide("加载失败")
            }
        }
    }
    
    // MARK: - CollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.songs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("song", forIndexPath: indexPath) as! TCKTVSongCell
        cell.delegate = self
        let song = self.songs[indexPath.row]
        cell.singerNameLabel.text = song.singer
        cell.songNameLabel.text = song.songName
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        let payload = TCSocketPayload()
        let song = self.songs[indexPath.row]
        payload.cmdType = "1003"
        payload.cmdContent = "\(song.songNum)"
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.page = 1
        self.loadData()
    }
    
    // MARK: - Cell delegate
    func onFirstAction(cell: UICollectionViewCell) {
        
    }
    
    func onSecondAction(cell: UICollectionViewCell) {
        let indexPath = self.collectionView.indexPathForCell(cell)
        let payload = TCSocketPayload()
        let song = self.songs[indexPath!.row]
        payload.cmdType = "1004"
        payload.cmdContent = "\(song.songNum)"
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
