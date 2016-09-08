//
//  TCCinemaViewController.swift
//  tc
//
//  Created by Sasori on 16/9/5.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCCinemaSearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, TCMovieDetailViewDelegate {

    @IBOutlet weak var keyboardView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var movieDetailView: TCMovieDetailView!

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var searchField: UITextField!
    
    var page:Int = 1
    var client = TCCinemaClient()
    var movies:[Int: [TCMovie]] = [Int: [TCMovie]]()
    var nextPageClient = TCCinemaClient()

    var totalPage:String = "0"
    let keys = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.movieDetailView.delegate = self

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
        let limit = 8
        let page = self.page
        let nextPage = self.page + 1
        let getTotalPage = Int(self.totalPage) == 0
        
        self.client.getMovies(self.searchField.text, type: "all_movie_content", area: "all_movie_content", year: "all_movie_content", page: page, limit: limit, getTotalPage: getTotalPage) { (movies, totalPage, flag) in
            if flag {
                self.movies[page] = movies!
                self.collectionView.reloadData()
                if getTotalPage {
                    self.totalPage = totalPage
                    self.updatePage(shouldSelect: false)
                }
            } else {
                let movie = TCMovie()
                movie.movieId = 1
                movie.title = "测试title"
                movie.info = "【IMDB：7.3  豆瓣：6.9】 故事发生在遥远的2057年，太阳的逐渐衰竭让人类即将面临有史以来最大的危机，如果失去了日照，大地将会陷入黑暗和冰封之中，永无再见天日之时。为了拯救地球，一支八人行动小组组成了，他们分别是稳重老城的机长凯恩达、植物学翘楚卡伦佐、航海高手特雷、物理学家卡帕、驾驶员卡西和她的助手马斯，指挥官哈维以及博士希瑞尔。背负着全人类的使命，八人驾驶着宇宙飞船“伊卡鲁斯二号”飞向了太阳。随着目的地的临近，问题不断涌现，他们能够顺利完成任务吗？又是否能够平安返回地球呢？"
                let movies = [movie, movie, movie, movie, movie, movie, movie, movie]
                self.movies[page] = movies
                self.totalPage = "10"
                self.updatePage(shouldSelect: false)
                self.collectionView.reloadData()
                self.view.showTextAndHide("加载失败")
            }
        }
        
        self.nextPageClient.getMovies(self.searchField.text, type: "all_movie_content", area: "all_movie_content", year: "all_movie_content", page: nextPage, limit: limit, getTotalPage: getTotalPage) { (movies, totalPage, flag) in
            if flag {
                self.movies[nextPage] = movies!
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
        if let movies = self.movies[page] {
            return movies.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.keyboardView {
            return
        }
        if collectionView == self.collectionView {
            self.page = indexPath.item + 1
            if self.movies[self.page] == nil {
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movie", forIndexPath: indexPath) as! TCKTVSingerCell
        let page = collectionView.tag + 1
        let movies = self.movies[page]
        let movie = movies![indexPath.row]
        cell.singerNameLabel.text = movie.title
        cell.singerImageView.sd_setImageWithURL(self.client.movieIconURL(movie.movieId))
               cell.backgroundColor = UIColor.yellowColor()
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
        let movies = self.movies[page]
        let movie = movies![indexPath.row]
        self.movieDetailView.hidden = false
        self.movieDetailView.movie = movie
        self.movieDetailView.titleLabel.text = movie.title
        self.movieDetailView.infoLabel.text = movie.info
        self.movieDetailView.imageView.sd_setImageWithURL(self.client.movieIconURL(movie.movieId))        
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
        
        if UI_USER_INTERFACE_IDIOM() == .Phone {
            return CGSizeMake(floor((collectionView.bounds.size.width - 30)/4), floor((collectionView.bounds.size.height - 10)/2))
        }
        return CGSizeMake(floor((collectionView.bounds.size.width - 30)/4), floor((collectionView.bounds.size.width - 30)/4))
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
        self.movies.removeAll()
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
        self.loadData()
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
    
    // MARK: DetailViewDelegate
    func onPlay() {
        self.movieDetailView.hidden = true
        let payload = TCSocketPayload()
        payload.cmdType = 2012
        payload.cmdContent = JSON(NSNumber(longLong:self.movieDetailView.movie!.movieId))
        TCCinemaContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    func onClose() {
        self.movieDetailView.hidden = true
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
