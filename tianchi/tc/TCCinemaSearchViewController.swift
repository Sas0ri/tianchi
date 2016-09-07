//
//  TCCinemaViewController.swift
//  tc
//
//  Created by Sasori on 16/9/5.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCCinemaSearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    @IBOutlet weak var keyboardView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var movieDetailView: UIView!

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    
    var page:Int = 1
    var client = TCKTVSongClient()
    var songs:[Int: [TCKTVSong]] = [Int: [TCKTVSong]]()
    var totalPage:String = "0"
    let keys = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchField.inputView = UIView()
        self.deleteButton.setBackgroundImage(UIImage(color: UIColor(fromHexCode:"4f4f4f"), cornerRadius:4), forState: .Normal)
        self.doneButton.setBackgroundImage(UIImage(color: UIColor(fromHexCode:"4f4f4f"), cornerRadius:4), forState: .Normal)
        self.movieDetailView.hidden = true
        self.loadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.searchField.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.searchField.font = UIFont.systemFontOfSize(self.searchField.bounds.size.height - 1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        self.client.getSongsByName("", words: 0, page: self.page, limit:limit) { (songs, totalPage, flag) in
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
        }
        //预加载
        self.client.getSongsByName("", words: 0, page: nextPage, limit:limit) { (songs, totalPage, flag) in
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
        if collectionView == self.keyboardView {
            return self.keys.count
        }
        if collectionView == self.collectionView {
            return Int(self.totalPage)!
        }
        let page = collectionView.tag + 1
        if let songs = self.songs[page] {
            return songs.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.keyboardView {
            return
        }
        if collectionView == self.collectionView {
            self.page = indexPath.item + 1
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
        if collectionView == self.keyboardView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("key", forIndexPath: indexPath)
            let label = cell.contentView.viewWithTag(1) as? UILabel
            label?.text = self.keys[indexPath.row]
            return cell
        }
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("container", forIndexPath: indexPath) as! TCKTVContainerCell
            cell.collectionView.tag = indexPath.row
            cell.collectionView.reloadData()
            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("song", forIndexPath: indexPath) as! TCKTVSongCell
        let page = collectionView.tag + 1
        let songs = self.songs[page]
        let song = songs![indexPath.row]
        cell.singerNameLabel.text = song.singer
        cell.songNameLabel.text = song.songName
               
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        if collectionView == self.keyboardView {
            self.searchField.text = self.searchField.text! + self.keys[indexPath.row]
            self.alignSearchField()
            return
        }
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
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == self.keyboardView {
            var sep:CGFloat = 32
            if UI_USER_INTERFACE_IDIOM() == .Pad {
                sep = 80
            }
            let height = (collectionView.bounds.size.height - sep)/9
            return CGSizeMake((collectionView.bounds.size.width - 20)/4, height)
        }
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
            if collectionView == self.keyboardView {
                return 10
            }
            return 30
        }
        if collectionView == self.keyboardView {
            return 4
        }
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
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

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    @IBAction func deleteAction(sender: AnyObject) {
        if self.searchField.text?.characters.count > 0 {
            let index = self.searchField.text?.endIndex.advancedBy(-1)
            self.searchField.text = self.searchField.text?.substringToIndex(index!)
            self.alignSearchField()
        }
    }
    
    @IBAction func doneAction(sender: AnyObject) {
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.movieDetailView.hidden = true
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func alignSearchField() {
        let text = self.searchField.text! as NSString
        let size = text.sizeWithAttributes([NSFontAttributeName: self.searchField.font!])
        self.searchField.textAlignment = size.width > self.searchField.bounds.size.width ? .Right : .Left
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
