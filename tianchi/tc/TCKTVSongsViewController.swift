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
    var songs:[TCKTVSong] = [TCKTVSong]()
    var clouds:[TCKTVCloud] = [TCKTVCloud]()
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
            self.loadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segChanged(sender: AnyObject) {
        self.page = 1
        self.loadData()
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    // MARK: - UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.page = 1
        self.loadData()
    }
    
    func loadData() {
        let limit = self.getLimit()
        if self.singer != nil {
            self.client.getSongsBySinger(nil, singer: self.singer!, words: self.segmentedControl.selectedSegmentIndex, page: self.page, limit: limit, complete: { (songs, totalPage, flag) in
                if flag {
                    if songs!.count == 0 && self.page > 1 {
                        self.page = self.page - 1
                    } else {
                        self.totalPage = totalPage
                        self.songs = songs!
                        self.collectionView.reloadData()
                    }
                } else {
                    if self.page > 1 {
                        self.page = self.page - 1
                    }
                    self.view.showTextAndHide("加载失败")
                }
                self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
            })
        }

        if self.language != nil {
            self.client.getSongsByLanguage(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, language: self.language!.rawValue, page: self.page, limit:limit, complete: { (songs, totalPage, flag) in
                if flag {
                    if songs!.count == 0 && self.page > 1 {
                        self.page = self.page - 1
                    } else {
                        self.totalPage = totalPage
                        self.songs = songs!
                        self.collectionView.reloadData()
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
                    if songs!.count == 0 && self.page > 1 {
                        self.page = self.page - 1
                    } else {
                        self.totalPage = totalPage
                        self.songs = songs!
                        self.collectionView.reloadData()
                    }
                } else {
                    if self.page > 1 {
                        self.page = self.page - 1
                    }
                    self.view.showTextAndHide("加载失败")
                }
                self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
            })
        }
        if self.ranking {
            self.client.getRankingSongs(nil, page: self.page, limit: limit, complete: { (songs, totalPage, flag) in
                if flag {
                    if songs!.count == 0 && self.page > 1 {
                        self.page = self.page - 1
                    } else {
                        self.totalPage = totalPage
                        self.songs = songs!
                        self.collectionView.reloadData()
                    }
                } else {
                    if self.page > 1 {
                        self.page = self.page - 1
                    }
                    self.view.showTextAndHide("加载失败")
                }
                self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
            })
        }
        if self.download {
            self.totalPage = "\(TCContext.sharedContext().downloads.count%limit == 0 ? TCContext.sharedContext().downloads.count/limit : TCContext.sharedContext().downloads.count/limit + 1)"

            self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
            self.collectionView.reloadData()
        }
        if self.cloud {
           
            self.client.getCloudSongs(self.searchBar.text, words: self.segmentedControl.selectedSegmentIndex, page: self.page, limit: limit, complete: { (clouds, totalPage, flag) in
                if flag {
                    if clouds!.count == 0 && self.page > 1 {
                        self.page = self.page - 1
                    } else {
                        self.totalPage = totalPage
                        self.clouds = clouds!
                        self.collectionView.reloadData()
                    }
                } else {
                    if self.page > 1 {
                        self.page = self.page - 1
                    }
                    self.view.showTextAndHide("加载失败")
                }
                self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
            })
        }
        if self.ordered {
            
            self.client.getOrderedSongs({ (ordereds, flag) in
                if flag {
                    self.ordereds = ordereds!
                    self.collectionView.reloadData()
                    self.totalPage = "\(self.ordereds.count%limit == 0 ? self.ordereds.count/limit : self.ordereds.count/limit + 1)"
                    self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
                } else {
                    self.view.showTextAndHide("加载失败")
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
        let limit = self.getLimit()

        if self.cloud {
            return self.clouds.count
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
        return self.songs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("song", forIndexPath: indexPath) as! TCKTVSongCell
        if self.cloud {
            let cloud = self.clouds[indexPath.row]
            cell.singerNameLabel.text = cloud.singer
            cell.songNameLabel.text = cloud.songName
            let statusLabel = cell.viewWithTag(1) as! UILabel
            let download = TCContext.sharedContext().downloads.first
            statusLabel.text = download?.songNum == cloud.songNum ? "下载中" : "待下载"
        } else if self.download {
            let limit = self.getLimit()
            let index = (self.page - 1) * limit + indexPath.row
            let download = TCContext.sharedContext().downloads[index]
            cell.singerNameLabel.text = download.singer
            cell.songNameLabel.text = download.songName
        } else if self.ordered {
            let limit = self.getLimit()
            let index = (self.page - 1) * limit + indexPath.row
            let ordered = self.ordereds[index]
            cell.singerNameLabel.text = ordered.singer
            cell.songNameLabel.text = ordered.songName
        } else {
            let song = self.songs[indexPath.row]
            cell.singerNameLabel.text = song.singer
            cell.songNameLabel.text = song.songName
            cell.songNameLabel.textColor = TCContext.sharedContext().orderedSongsViewController!.hasOrdered(song.songNum) ? UIColor.redColor() : UIColor.whiteColor()
            cell.singerNameLabel.textColor = TCContext.sharedContext().orderedSongsViewController!.hasOrdered(song.songNum) ? UIColor.redColor() : UIColor.whiteColor()
        }
        cell.delegate = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if UI_USER_INTERFACE_IDIOM() == .Pad {
            return CGSizeMake(256, 102)
        }
        return CGSizeMake(256/1024*self.view.bounds.width, collectionView.bounds.size.height/2 - 10)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        if UI_USER_INTERFACE_IDIOM() == .Pad {
            return 30
        }
        return 10
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TCKTVSongCell
        cell.songNameLabel.textColor = UIColor.redColor()
        cell.singerNameLabel.textColor = UIColor.redColor()
        let payload = TCSocketPayload()
        if self.cloud {
            let cloud = self.clouds[indexPath.row]
            payload.cmdType = 1003
            payload.cmdContent = cloud.songNum
        } else if self.download {
            
        } else if self.ordered {
            let limit = self.getLimit()
            let index = (self.page - 1) * limit + indexPath.row
            let order = self.ordereds[index]
            payload.cmdType = 1001
            payload.cmdContent = order.songNum
        } else {
            let song = self.songs[indexPath.row]
            payload.cmdType = 1003
            payload.cmdContent = song.songNum
        }
        if payload.cmdType == 0 {
            return
        }
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    

    // MARK: - Cell delegate
    func onFirstAction(cell: UICollectionViewCell) {
        let payload = TCSocketPayload()
        let indexPath = self.collectionView.indexPathForCell(cell)
        if self.ordered {
            let limit = self.getLimit()
            let index = (self.page - 1) * limit + indexPath!.row

            let ordered = self.ordereds[index]
            payload.cmdType = 1002
            payload.cmdContent = ordered.songNum
            self.ordereds.removeAtIndex(indexPath!.row)
            self.collectionView.deleteItemsAtIndexPaths([indexPath!])
        } else {
            let song = self.songs[indexPath!.row]
            payload.cmdType = 1003
            payload.cmdContent = song.songNum
        }
        if payload.cmdType == 0 {
            return
        }
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    func onSecondAction(cell: UICollectionViewCell) {
        let payload = TCSocketPayload()
        let indexPath = self.collectionView.indexPathForCell(cell)
        if self.cloud {
           
        } else if self.download {
        } else if self.ordered {
            let limit = self.getLimit()
            let index = (self.page - 1) * limit + indexPath!.row
            let ordered = self.ordereds.removeAtIndex(index)
            self.ordereds.insert(ordered, atIndex: 0)
            self.collectionView.reloadData()
            payload.cmdType = 1001
            payload.cmdContent = ordered.songNum
        } else {
            let song = self.songs[indexPath!.row]
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
