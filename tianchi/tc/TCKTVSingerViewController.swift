//
//  TVKTVSingerViewController.swift
//  tc
//
//  Created by Sasori on 16/6/15.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCKTVSingerViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pageLabel: UILabel!
    
    var page:Int = 1
    var client = TCKTVSingerClient()
    var singers:[Int:[TCKTVSinger]] = [Int:[TCKTVSinger]]()
    var totalPage:String = "0"
    
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
        self.totalPage = "0"
        self.updatePage(shouldSelect: false)
        self.loadData()
    }
    
    func loadData() {
        var limit = 8
        if UI_USER_INTERFACE_IDIOM() == .Phone {
            limit = 12
        }
        
        let page = self.page
        let nextPage = self.page + 1
        self.client.getSingers(self.searchBar.text, type: self.segmentedControl.selectedSegmentIndex, page: self.page, limit: limit) { (singers, totalPage, flag) in
            if flag {
                self.totalPage = totalPage
                self.singers[page] = singers!
                self.collectionView.reloadData()
                if self.page == 1 {
                    self.updatePage(shouldSelect: false)
                }
                
            } else {
                self.view.showTextAndHide("加载失败")
            }
        }
        //预加载
        self.client.getSingers(self.searchBar.text, type: self.segmentedControl.selectedSegmentIndex, page: nextPage, limit: limit) { (singers, totalPage, flag) in
            if flag {
                self.singers[nextPage] = singers!
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
        if let singers = self.singers[self.page] {
            return singers.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.collectionView {
            self.page = indexPath.row + 1
            if self.singers[self.page] == nil {
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("song", forIndexPath: indexPath) as! TCKTVSingerCell
        let page = collectionView.tag + 1
        let singers = self.singers[page]
        let singer = singers![indexPath.row]
        cell.singerNameLabel.text = singer.singerName
        let url = self.client.singerIconURL(singer.singerId)
        cell.singerImageView.sd_setImageWithURL(url, placeholderImage: UIImage(named: "public_singer"))
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return collectionView.bounds.size
        }
        if UI_USER_INTERFACE_IDIOM() == .Phone {
            return CGSizeMake(floor((collectionView.bounds.size.width - 50)/6), floor((collectionView.bounds.size.height - 10)/2))
        }
        return CGSizeMake(180, 180)
    }

    // MARK: - UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.page = 1
        self.totalPage = "0"
        self.updatePage(shouldSelect: false)
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
    
    func updatePage(shouldSelect shouldSelect:Bool)  {
        self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
        if shouldSelect {
            self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow:self.page-1,inSection: 0), atScrollPosition: .None, animated: false)
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! TCKTVSingerCell
        let collectionView = cell.superview as! UICollectionView
        let indexPath = collectionView.indexPathForCell(cell)
        let singers = self.singers[self.page]
        let singer = singers![indexPath!.row]
        let vc = segue.destinationViewController as! TCKTVSongsViewController
        vc.singer = singer.singerName
    }

}
