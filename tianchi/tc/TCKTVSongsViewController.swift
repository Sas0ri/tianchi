//
//  TCKTVSongsViewController.swift
//  tc
//
//  Created by Sasori on 16/6/20.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCKTVSongsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, TCKTVSongCellDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageView: UIView!
    
    var singer:String?
    var language:TCKTVLanguage?
    var category:String?
    var ranking:Bool = false
    var cloud:Bool = false
    var download:Bool = false
    var ordered:Bool = false
    
    var page:Int = 1
    var hasMore:Bool = true
    var words:String = "1"
    var client = TCKTVSongClient()
    var songs:[TCKTVSong] = [TCKTVSong]()
    var downloads:[TCKTVDownload] = [TCKTVDownload]()
    var clouds:[TCKTVCloud] = [TCKTVCloud]()
    var ordereds:[TCKTVPoint] = [TCKTVPoint]()
    
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.ordered {
            self.bottomView.hidden = true
        }
        if self.download {
            self.pageView.hidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func loadData() {
        if self.singer != nil {
            self.client.getSongsBySinger(nil, singer: self.singer!, page: self.page, complete: { (songs, flag) in
                if flag {
                    if songs!.count == 0 {
                        self.page = self.page - 1
                        self.hasMore = false
                        return
                    }
                    self.songs = songs!
                    self.collectionView.reloadData()
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }

        if self.category != nil {
            self.client.getSongsByLanguage(nil, language: self.language!.rawValue, page: self.page, complete: { (songs, flag) in
                if flag {
                    if songs!.count == 0 {
                        self.page = self.page - 1
                        self.hasMore = false
                        return
                    }
                    self.songs = songs!
                    self.collectionView.reloadData()
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }
        
        if self.category != nil {
            self.client.getSongsByCategory(nil, type: self.category!, page: self.page, complete: { (songs, flag) in
                if flag {
                    if songs!.count == 0 {
                        self.page = self.page - 1
                        self.hasMore = false
                        return
                    }
                    self.songs = songs!
                    self.collectionView.reloadData()
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }
        if self.ranking {
            self.client.getRankingSongs(nil, page: self.page, complete: { (songs, flag) in
                if flag {
                    if songs!.count == 0 {
                        self.page = self.page - 1
                        self.hasMore = false
                        return
                    }
                    self.songs = songs!
                    self.collectionView.reloadData()
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }
        if self.download {
            self.client.getDownloadSongs({ (downloads, flag) in
                if flag {
                    self.downloads = downloads!
                    self.collectionView.reloadData()
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }
        if self.cloud {
            self.client.getCloudSongs(nil, page: self.page, complete: { (clouds, flag) in
                if flag {
                    if clouds!.count == 0 {
                        self.page = self.page - 1
                        self.hasMore = false
                        return
                    }
                    self.clouds = clouds!
                    self.collectionView.reloadData()
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
                } else {
                    self.view.showTextAndHide("加载失败")
                }
            })
        }
    }
    
    @IBAction func prePage(sender: AnyObject) {
        if self.page == 1 {
            return
        }
        self.page = self.page - 1
        self.loadData()
    }
    
    @IBAction func nextPage(sender: AnyObject) {
        if self.hasMore {
            self.page = self.page + 1
            self.loadData()
        }
    }
    
    // MARK: - CollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.cloud {
            return self.clouds.count
        }
        if self.download {
            return self.downloads.count
        }
        if self.ordered {
            return self.ordereds.count
        }
        return self.songs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("song", forIndexPath: indexPath) as! TCKTVSongCell
        if self.cloud {
            let cloud = self.clouds[indexPath.row]
            cell.singerNameLabel.text = cloud.singer
            cell.songNameLabel.text = cloud.songName
        } else if self.download {
            let download = self.downloads[indexPath.row]
            cell.singerNameLabel.text = download.singer
            cell.songNameLabel.text = download.songName
        } else if self.ordered {
            let ordered = self.ordereds[indexPath.row]
            cell.singerNameLabel.text = ordered.singer
            cell.songNameLabel.text = ordered.songName
        } else {
            let song = self.songs[indexPath.row]
            cell.singerNameLabel.text = song.singer
            cell.songNameLabel.text = song.songName
        }
        cell.delegate = self
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        let payload = TCSocketPayload()
        if self.cloud {
            let cloud = self.clouds[indexPath.row]
            payload.cmdType = "1003"
            payload.cmdContent = "\(cloud.songNum)"
        } else if self.download {
        } else if self.ordered {
        } else {
            let song = self.songs[indexPath.row]
            payload.cmdType = "1003"
            payload.cmdContent = "\(song.songNum)"
        }
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    

    // MARK: - Cell delegate
    func onFirstAction(cell: UICollectionViewCell) {
        let payload = TCSocketPayload()
        let indexPath = self.collectionView.indexPathForCell(cell)
        if self.ordered {
            let ordered = self.ordereds[indexPath!.row]
            payload.cmdType = "1002"
            payload.cmdContent = "\(ordered.songNum)"
        }
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    func onSecondAction(cell: UICollectionViewCell) {
        let payload = TCSocketPayload()
        let indexPath = self.collectionView.indexPathForCell(cell)
        if self.cloud {
            let cloud = self.clouds[indexPath!.row]
            payload.cmdType = "1004"
            payload.cmdContent = "\(cloud.songNum)"
        } else if self.download {
        } else if self.ordered {
            let ordered = self.ordereds[indexPath!.row]
            payload.cmdType = "1001"
            payload.cmdContent = "\(ordered.songNum)"
        } else {
            let song = self.songs[indexPath!.row]
            payload.cmdType = "1004"
            payload.cmdContent = "\(song.songNum)"
        }
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
