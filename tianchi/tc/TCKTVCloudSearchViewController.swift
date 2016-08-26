//
//  TCKTVCloudSearchViewController.swift
//  tc
//
//  Created by Sasori on 16/8/13.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCKTVCloudSearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate,TCKTVSongCellDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var singer:String?
    var language:TCKTVLanguage?
    var category:String?
    var searchText:String?
    var words:Int = 0
    
    var page:Int = 1
    var client = TCKTVSongClient()
    var nextPageClient = TCKTVSongClient()

    var clouds:[Int:[TCKTVCloud]] = [Int:[TCKTVCloud]]()
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
        self.segmentedControl.selectedSegmentIndex = words
        self.searchBar.setImage(UIImage(named: "ktv_search_icon"), forSearchBarIcon: .Search, state: .Normal)
        self.searchBar.text = self.searchText
        if let subViews = self.searchBar.subviews.last?.subviews {
            for v in  subViews {
                if v.isKindOfClass(UITextField) {
                    let tf = v as! UITextField
                    tf.backgroundColor = UIColor.clearColor()
                }
            }
        }
        self.loadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TCKTVSongsViewController.reloadData(_:)), name: TCKTVDownloadLoadedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TCKTVSongsViewController.reloadData(_:)), name: TCKTVDownloadUpdatedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TCKTVSongsViewController.reloadData(_:)), name: TCKTVDownloadRemovedNotification, object: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segChanged(sender: AnyObject) {
        self.page = 1
        self.totalPage = "0"
        self.updatePage(shouldSelect: false)
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

        self.client.searchCloudSongs(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, page: self.page, limit: limit, language: self.language?.rawValue, singer: self.singer, type: self.category, getTotalPage: getTotalPage) {
            (clouds, totalPage, flag) in
            if flag {
                self.clouds[page] = clouds!
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
        self.nextPageClient.searchCloudSongs(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, page: nextPage, limit: limit, language: self.language?.rawValue, singer: self.singer, type: self.category, getTotalPage: false) {
            (clouds, totalPage, flag) in
            
            if flag {
                self.clouds[nextPage] = clouds!
            }
        }
        
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
    
    // MARK: - CollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return Int(self.totalPage)!
        }
        if let clouds = self.clouds[self.page] {
            return clouds.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.collectionView {
            if self.collectionView.dragging {
                self.page = indexPath.row + 1
            }
            if self.clouds[self.page] == nil || self.clouds[self.page]?.count == 0 {
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
        let page = collectionView.tag + 1
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("song", forIndexPath: indexPath) as! TCKTVSongCell
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
        let payload = TCSocketPayload()
        
        let clouds = self.clouds[page]
        let cloud = clouds![indexPath.row]
        payload.cmdType = 1005
        payload.cmdContent = cloud.songNum
        TCContext.sharedContext().socketManager.sendPayload(payload)

        let download = TCKTVDownload()
        download.songNum = cloud.songNum
        download.songName = cloud.songName
        download.singer = cloud.singer
        TCContext.sharedContext().downloads.append(download)
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TCKTVSongCell
        let statusLabel = cell.viewWithTag(1) as! UILabel
        statusLabel.text = TCContext.sharedContext().downloads.count == 1 ? "下载中" : "等待下载"
    }
    
    func updatePage(shouldSelect shouldSelect:Bool)  {
        self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
        let indexPath = NSIndexPath(forItem: self.page - 1, inSection: 0)
        if shouldSelect && self.collectionView.numberOfItemsInSection(0) > 0 {
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
        }
    }

    // MARK: - Cell delegate
    func onFirstAction(cell: UICollectionViewCell) {
        
    }
    
    func onSecondAction(cell: UICollectionViewCell) {
        
    }
    
    func reloadData(sender:NSNotification) {
        self.collectionView.reloadData()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
