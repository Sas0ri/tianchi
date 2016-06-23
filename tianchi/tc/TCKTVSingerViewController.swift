//
//  TVKTVSingerViewController.swift
//  tc
//
//  Created by Sasori on 16/6/15.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCKTVSingerViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var page:Int = 1
    var client = TCKTVSingerClient()
    var singers:[TCKTVSinger] = [TCKTVSinger]()
    
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
        self.loadData()
    }
    
    func loadData() {
        self.client.getSingers(self.searchBar.text, type: self.segmentedControl.selectedSegmentIndex, page: self.page) { (singers, flag) in
            if flag {
                self.singers = singers!
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
        return self.singers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("song", forIndexPath: indexPath) as! TCKTVSingerCell
        let singer = self.singers[indexPath.row]
        cell.singerNameLabel.text = singer.singerName
        return cell
    }

    // MARK: - UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.page = 1
        self.loadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! TCKTVSingerCell
        let indexPath = self.collectionView.indexPathForCell(cell)
        let singer = self.singers[indexPath!.row]
        let vc = segue.destinationViewController as! TCKTVSongsViewController
        vc.singer = singer.singerName
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
