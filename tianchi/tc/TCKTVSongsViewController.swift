//
//  TCKTVSongsViewController.swift
//  tc
//
//  Created by Sasori on 16/6/20.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCKTVSongsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate,TCKTVSongCellDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var singer:String?
    var language:TCKTVLanguage?
    var category:String?
    var ranking:Bool = false
    var cloud:Bool = false
    var download:Bool = false
    var ordered:Bool = false
    
    var page:Int = 1
    var client = TCKTVSongClient()
    var songs:[Int: [TCKTVSong]] = [Int: [TCKTVSong]]()
    var clouds:[Int: [TCKTVCloud]] = [Int: [TCKTVCloud]]()
    var ordereds:[TCKTVPoint] = [TCKTVPoint]()
    var totalPage:String = "0"
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var pageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var fontSize:CGFloat = 14.0
        if UI_USER_INTERFACE_IDIOM() == .Phone {
            fontSize = 10.0
        }
        self.segmentedControl.clipsToBounds = true
        self.segmentedControl.layer.cornerRadius = 4
        self.segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(fontSize)], forState: .Selected)
        self.segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(fontSize)], forState: .Normal)
        self.segmentedControl.setBackgroundImage(UIImage(color: UIColor(fromHexCode:"171717"), cornerRadius: 0), forState: .Normal, barMetrics: .Default)
        self.segmentedControl.setBackgroundImage(UIImage(color: UIColor(fromHexCode:"fb8808"), cornerRadius: 0), forState: .Selected, barMetrics: .Default)
        self.segmentedControl.selectedSegmentIndex = 0
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
        if self.download || self.cloud {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TCKTVSongsViewController.reloadData(_:)), name: TCKTVDownloadLoadedNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TCKTVSongsViewController.reloadData(_:)), name: TCKTVDownloadUpdatedNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TCKTVSongsViewController.reloadData(_:)), name: TCKTVDownloadRemovedNotification, object: nil)
        }
        if self.ordered {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TCKTVSongsViewController.reloadData(_:)), name: TCKTVOrderedUpdatedNotification, object: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.ordered {
            self.page = 1
            self.loadData()
        }
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
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    // MARK: - UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.page = 1
        self.totalPage = "0"
        self.updatePage(shouldSelect: false)
        self.clearData()
        self.loadData()
    }
    
    func loadData() {
        let limit = self.getLimit()
        let page = self.page
        let nextPage = self.page + 1
        if self.singer != nil {
            self.client.getSongsBySinger(nil, singer: self.singer!, words: self.segmentedControl.selectedSegmentIndex, page: self.page, limit: limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.totalPage = totalPage
                    self.songs[page] = songs!
                    self.collectionView.reloadData()
                    if self.page == 1 {
                        self.updatePage(shouldSelect: false)
                    }
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }

        if self.language != nil {
            self.client.getSongsByLanguage(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, language: self.language!.rawValue, page: self.page, limit:limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.totalPage = totalPage
                    self.songs[page] = songs!
                    self.collectionView.reloadData()
                    if self.page == 1 {
                        self.updatePage(shouldSelect: false)
                    }
                } else {
                    self.view.showTextAndHide("加载失败")
                }
                self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
            })
        }
        
        if self.category != nil {
            self.client.getSongsByCategory(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, type: self.category!, page: self.page, limit:limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.totalPage = totalPage
                    self.songs[page] = songs!
                    self.collectionView.reloadData()
                    if self.page == 1 {
                        self.updatePage(shouldSelect: false)
                    }
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }
        if self.ranking {
            self.client.getRankingSongs(nil, page: self.page, limit: limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.totalPage = totalPage
                    self.songs[page] = songs!
                    self.collectionView.reloadData()
                    if self.page == 1 {
                        self.updatePage(shouldSelect: false)
                    }
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }
        if self.download {
            self.totalPage = "\(TCContext.sharedContext().downloads.count%limit == 0 ? TCContext.sharedContext().downloads.count/limit : TCContext.sharedContext().downloads.count/limit + 1)"
            if self.page > Int(self.totalPage) {
                self.page = Int(self.totalPage)!
            }
            self.updatePage(shouldSelect: true)
            self.collectionView.reloadData()
        }
        if self.cloud {
            self.client.getCloudSongs(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, page: self.page, limit: limit, complete: { (clouds, totalPage, flag) in
                if flag {
                    self.totalPage = totalPage
                    self.clouds[page] = clouds!
                    self.collectionView.reloadData()
                    if self.page == 1 {
                        self.updatePage(shouldSelect: false)
                    }
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }
        if self.ordered {
            self.client.getOrderedSongs({ (ordereds, flag) in
                if flag {
                    self.ordereds = ordereds!
                    self.collectionView.reloadData()
                    self.totalPage = "\(self.ordereds.count%limit == 0 ? self.ordereds.count/limit : self.ordereds.count/limit + 1)"
                    if self.page > Int(self.totalPage) {
                        self.page = Int(self.totalPage)!
                    }
                    self.updatePage(shouldSelect: true)
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }
        if self.page == 1 {
            self.updatePage(shouldSelect: false)
        }
        //预加载
        if self.singer != nil {
            self.client.getSongsBySinger(nil, singer: self.singer!, words: self.segmentedControl.selectedSegmentIndex, page: nextPage, limit: limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.songs[nextPage] = songs!
                }
            })
        }
        
        if self.language != nil {
            self.client.getSongsByLanguage(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, language: self.language!.rawValue, page: nextPage, limit:limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.songs[nextPage] = songs!
                }
            })
        }
        
        if self.category != nil {
            self.client.getSongsByCategory(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, type: self.category!, page: nextPage, limit:limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.songs[nextPage] = songs!
                }
            })
        }
        if self.ranking {
            self.client.getRankingSongs(nil, page: nextPage, limit: limit, complete: { (songs, totalPage, flag) in
                if flag {
                    self.songs[nextPage] = songs!
                }
            })
        }
       
        if self.cloud {
            self.client.getCloudSongs(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, page: nextPage, limit: limit, complete: { (clouds, totalPage, flag) in
                if flag {
                    self.clouds[nextPage] = clouds!
                }
            })
        }
    }
    
    func hasOrdered(songNum:Int) -> Bool {
        for order in self.ordereds {
            if songNum == order.songNum {
                return true
            }
        }
        return false
    }
    
    @IBAction func prePage(sender: AnyObject) {
        if self.page == 1 {
            return
        }
        self.page = self.page - 1
        self.updatePage(shouldSelect: true)
        if self.ordered || self.download {
            self.collectionView.reloadData()
            self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
            return
        }
        self.loadData()
    }
    
    @IBAction func nextPage(sender: AnyObject) {
        if Int(self.totalPage) < self.page + 1 {
            return
        }
        self.page = self.page + 1
        self.updatePage(shouldSelect: true)
        if self.ordered || self.download {
            self.collectionView.reloadData()
            self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
            return
        }
        self.loadData()
    }
    
    // MARK: - CollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return Int(self.totalPage)!
        }
        let limit = self.getLimit()

        if self.cloud {
            if let clouds = self.clouds[self.page] {
                return clouds.count
            }
            return 0
        }
        if self.download {
            let count = self.page * limit
            if TCContext.sharedContext().downloads.count >= count {
                return limit
            }
            return TCContext.sharedContext().downloads.count%limit
        }
        if self.ordered {
            let count = self.page * limit
            if self.ordereds.count >= count {
                return limit
            }
            return self.ordereds.count%limit
        }
        if let songs = self.songs[self.page] {
            return songs.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.collectionView {
            self.page = indexPath.row + 1
            if self.cloud {
                if self.clouds[self.page] == nil {
                    self.loadData()
                }
                return
            }
            if self.download {
                return
            }
            if self.ordered {
                return
            }
            if self.songs[self.page] == nil {
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
        let page = collectionView.tag + 1
        if self.cloud {
            let clouds = self.clouds[page]
            let cloud = clouds![indexPath.row]
            cell.singerNameLabel.text = cloud.singer
            cell.songNameLabel.text = cloud.songName
            let statusLabel = cell.viewWithTag(1) as! UILabel
            var waiting = false
            for song in TCContext.sharedContext().downloads {
                if song.songNum == cloud.songNum {
                    waiting = true
                    break
                }
            }
            let downloading = TCContext.sharedContext().downloads.first?.songNum == cloud.songNum
            if downloading {
                statusLabel.text = "下载中"
            } else if waiting {
                statusLabel.text = "等待下载"
            } else {
                statusLabel.text = "未下载"
            }
        } else if self.download {
            let limit = self.getLimit()
            let index = (self.page - 1) * limit + indexPath.row
            let download = TCContext.sharedContext().downloads[index]
            cell.singerNameLabel.text = download.singer
            cell.songNameLabel.text = download.songName
            let statusLabel = cell.viewWithTag(1) as! UILabel
            let downloading = TCContext.sharedContext().downloads.first
            statusLabel.text = downloading?.songNum == download.songNum ? "下载中" : "等待下载"
        } else if self.ordered {
            let limit = self.getLimit()
            let index = (self.page - 1) * limit + indexPath.row
            let ordered = self.ordereds[index]
            cell.singerNameLabel.text = ordered.singer
            cell.songNameLabel.text = ordered.songName
            let btn1 = cell.contentView.viewWithTag(1)
            let btn2 = cell.contentView.viewWithTag(2)
            let label = cell.contentView.viewWithTag(3)
            btn1?.hidden = index == 0
            btn2?.hidden = btn1!.hidden
            label?.hidden = !btn1!.hidden
        } else {
            let songs = self.songs[page]
            let song = songs![indexPath.row]
            cell.singerNameLabel.text = song.singer
            cell.songNameLabel.text = song.songName
            cell.songNameLabel.textColor = TCContext.sharedContext().orderedSongsViewController!.hasOrdered(song.songNum) ? UIColor.redColor() : UIColor.whiteColor()
            cell.singerNameLabel.textColor = TCContext.sharedContext().orderedSongsViewController!.hasOrdered(song.songNum) ? UIColor.redColor() : UIColor.whiteColor()
        }
        cell.delegate = self
        return cell
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

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        if collectionView == self.collectionView {
            return
        }
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TCKTVSongCell
        let collectionView = cell.superview as! UICollectionView
        let page = collectionView.tag + 1
        let payload = TCSocketPayload()
        if self.cloud {
            let clouds = self.clouds[page]
            let cloud = clouds![indexPath.row]
            payload.cmdType = 1005
            payload.cmdContent = cloud.songNum
        } else if self.download {
            
        } else if self.ordered {
    
        } else {
            let songs = self.songs[page]
            let song = songs![indexPath.row]
            payload.cmdType = 1003
            payload.cmdContent = song.songNum
            cell.songNameLabel.textColor = UIColor.redColor()
            cell.singerNameLabel.textColor = UIColor.redColor()
        }
        if payload.cmdType != 0 {
            TCContext.sharedContext().socketManager.sendPayload(payload)
            if payload.cmdType == 1005 {
                TCContext.sharedContext().performSelector(#selector(TCContext.getDownload), withObject: nil, afterDelay: 0.5)
            }
        }
        if self.searchBar.text?.characters.count > 0 {
            self.searchBar.resignFirstResponder()
            self.searchBar.text = nil
            self.loadData()
        }
    }
    

    // MARK: - Cell delegate
    func onFirstAction(cell: UICollectionViewCell) {
        let collectionView = cell.superview as! UICollectionView
        let page = collectionView.tag + 1
        let payload = TCSocketPayload()
        let indexPath = collectionView.indexPathForCell(cell)
        let limit = self.getLimit()
        let index = (self.page - 1) * limit + indexPath!.row

        if self.ordered {

            let ordered = self.ordereds[index]
            payload.cmdType = 1002
            payload.cmdContent = ordered.songNum
            self.ordereds.removeAtIndex(index)
            self.collectionView.reloadData()
            let totalPage = self.ordereds.count%limit == 0 ? self.ordereds.count/limit : self.ordereds.count/limit + 1
            if self.page > totalPage {
                self.page = totalPage
            }
            self.totalPage = "\(totalPage)"
            self.updatePage(shouldSelect: false)
        } else {
            let songs = self.songs[page]
            let song = songs![index]
            payload.cmdType = 1003
            payload.cmdContent = song.songNum
        }
        if payload.cmdType == 0 {
            return
        }
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    func onSecondAction(cell: UICollectionViewCell) {
        let collectionView = cell.superview as! UICollectionView
        let page = collectionView.tag + 1

        let payload = TCSocketPayload()
        let indexPath = collectionView.indexPathForCell(cell)
        let limit = self.getLimit()
        let index = (self.page - 1) * limit + indexPath!.row

        if self.cloud {
           
        } else if self.download {
        } else if self.ordered {
            let ordered = self.ordereds.removeAtIndex(index)
            self.ordereds.insert(ordered, atIndex: 1)
            self.collectionView.reloadData()
            payload.cmdType = 1001
            payload.cmdContent = ordered.songNum
        } else {
            let songs = self.songs[page]
            let song = songs![index]
            payload.cmdType = 1004
            payload.cmdContent = song.songNum
        }
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    func reloadData(sender:NSNotification) {
        self.loadData()
        self.collectionView.reloadData()
    }
    
    func getLimit() -> Int {
        var limit = 9
        if UI_USER_INTERFACE_IDIOM() == .Phone {
            limit = 6
        }
        return limit
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
        self.clouds.removeAll()
        self.collectionView.reloadData()
    }
    
    deinit {
        if self.download {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(TCKTVCloudSearchViewController) {
            let vc = segue.destinationViewController as! TCKTVCloudSearchViewController
            vc.singer = self.singer
            vc.language = self.language
            vc.category = self.category
            vc.searchText = self.searchBar.text
            vc.words = self.segmentedControl.selectedSegmentIndex
        }
    }
    

}
