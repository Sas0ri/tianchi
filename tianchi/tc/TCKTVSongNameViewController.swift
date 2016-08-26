//
//  TVKTVSongNameViewController.swift
//  tc
//
//  Created by Sasori on 16/6/14.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCKTVSongNameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, TCKTVSongCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pageLabel: UILabel!
    
    var page:Int = 1
    var client = TCKTVSongClient()
    var nextPageClient = TCKTVSongClient()

    var songs:[Int: [TCKTVSong]] = [Int: [TCKTVSong]]()
    var totalPage:String = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentedControl.clipsToBounds = true
        self.segmentedControl.layer.cornerRadius = 4
        var fontSize:CGFloat = 14.0
        if UI_USER_INTERFACE_IDIOM() == .Phone {
            fontSize = 10.0
            let button = self.view.viewWithTag(5) as! UIButton
            button.titleLabel?.font = UIFont.systemFontOfSize(6)
        }

        self.segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(fontSize)], forState: .Selected)
        self.segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(fontSize)], forState: .Normal)
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
    
    @IBAction func segChanged(sender: AnyObject) {
        self.page = 1
        self.totalPage = "0"
        self.updatePage(shouldSelect: false)
        self.clearData()
        self.loadData()
    }
    
    @IBAction func prePage(sender: AnyObject) {
        if self.page == 1 {
            return
        }
        self.page = self.page - 1
        self.updatePage(shouldSelect: true)
        self.loadData()
    }
    
    @IBAction func nextPage(sender: AnyObject) {
        if Int(self.totalPage) < self.page + 1 {
            return
        }
        self.page = self.page + 1
        self.updatePage(shouldSelect: true)
        self.loadData()
    }
    
    func loadData() {
        var limit = 9
        if UI_USER_INTERFACE_IDIOM() == .Phone {
            limit = 6
        }
        let page = self.page
        let nextPage = self.page + 1
        let getTotalPage = Int(self.totalPage) == 0

        self.client.getSongsByName(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, page: self.page, limit:limit, getTotalPage: getTotalPage) { (songs, totalPage, flag) in
            if flag {
                self.songs[page] = songs!
                self.collectionView.reloadData()
                if getTotalPage {
                    self.totalPage = totalPage
                    self.updatePage(shouldSelect: false)
                }
            } else {
                self.view.showTextAndHide("加载失败")
            }
        }
        //预加载
        self.nextPageClient.getSongsByName(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, page: nextPage, limit:limit, getTotalPage: false) { (songs, totalPage, flag) in
            if flag {
                self.songs[nextPage] = songs!
            }
        }
    }
    
    // MARK: - CollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return Int(self.totalPage)!
        }
        if let songs = self.songs[self.page] {
            return songs.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.collectionView {
            self.page = indexPath.item + 1
            if self.songs[self.page] == nil || self.songs[self.page]?.count == 0 {
                self.loadData()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.page =  self.collectionView.indexPathsForVisibleItems().first!.row + 1
        self.updatePage(shouldSelect: false)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("container", forIndexPath: indexPath) as! TCKTVContainerCell
            cell.collectionView.tag = indexPath.row
            cell.collectionView.reloadData()
            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("song", forIndexPath: indexPath) as! TCKTVSongCell
        cell.delegate = self
        let page = collectionView.tag + 1
        let songs = self.songs[page]
        let song = songs![indexPath.row]
        cell.singerNameLabel.text = song.singer
        cell.songNameLabel.text = song.songName
        cell.singerNameLabel.textColor = TCContext.sharedContext().orderedSongsViewController!.hasOrdered(song.songNum) ? UIColor.redColor() : UIColor.whiteColor()
        cell.songNameLabel.textColor = TCContext.sharedContext().orderedSongsViewController!.hasOrdered(song.songNum) ? UIColor.redColor() : UIColor.whiteColor()

        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        if collectionView == self.collectionView {
            return
        }
        let page = collectionView.tag + 1
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TCKTVSongCell
        cell.songNameLabel.textColor = UIColor.redColor()
        cell.singerNameLabel.textColor = UIColor.redColor()
        let payload = TCSocketPayload()
        let songs = self.songs[page]
        let song = songs![indexPath.row]
        payload.cmdType = 1003
        payload.cmdContent = song.songNum
        
        TCContext.sharedContext().socketManager.sendPayload(payload)
        if self.searchBar.text?.characters.count > 0 {
            self.searchBar.resignFirstResponder()
            self.searchBar.text = nil
            self.loadData()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return collectionView.bounds.size
        }
        if UI_USER_INTERFACE_IDIOM() == .Pad {
            return CGSizeMake(256, 102)
        }
        return CGSizeMake(256/1024*self.view.bounds.width, collectionView.bounds.size.height/2 - 10)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if collectionView == self.collectionView {
            return 0
        }
        if UI_USER_INTERFACE_IDIOM() == .Pad {
            return 30
        }
        return 10
    }
    
    // MARK: - UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.page = 1
        self.totalPage = "0"
        self.updatePage(shouldSelect: false)
        self.clearData()
        self.loadData()
    }
    
    // MARK: - Cell delegate
    func onFirstAction(cell: UICollectionViewCell) {
        let songsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ktv_songs") as! TCKTVSongsViewController
        let collectionView = cell.superview as! UICollectionView
        let indexPath = collectionView.indexPathForCell(cell)
        let page = collectionView.tag + 1
        let songs = self.songs[page]
        let song = songs![indexPath!.row]
        songsVC.singer = song.singer
        self.navigationController?.pushViewController(songsVC, animated: false)
    }
    
    func onSecondAction(cell: UICollectionViewCell) {
        let collectionView = cell.superview as! UICollectionView
        let indexPath = collectionView.indexPathForCell(cell)
        let page = collectionView.tag + 1
        let songs = self.songs[page]
        let song = songs![indexPath!.row]
        let payload = TCSocketPayload()
        payload.cmdType = 1004
        payload.cmdContent = song.songNum
        
        let c = cell as! TCKTVSongCell
        c.songNameLabel.textColor = UIColor.redColor()
        c.singerNameLabel.textColor = UIColor.redColor()
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    func updatePage(shouldSelect shouldSelect:Bool)  {
        self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
        let indexPath = NSIndexPath(forItem: self.page - 1, inSection: 0)
        if shouldSelect && self.collectionView.numberOfItemsInSection(0) > 0 {
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
        }
    }
    
    func clearData() {
        self.songs.removeAll()
        self.collectionView.reloadData()
    }
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(TCKTVCloudSearchViewController) {
            let vc = segue.destinationViewController as! TCKTVCloudSearchViewController
            vc.words = self.segmentedControl.selectedSegmentIndex
            vc.searchText = self.searchBar.text
        }
    }
     
    
}
