//
//  TCCinemaViewController.swift
//  tc
//
//  Created by Sasori on 16/9/5.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCCinemaViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TCCinemaFiltViewManagerDelegate, TCMovieDetailViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var movieDetailView: TCMovieDetailView!
    @IBOutlet weak var filtView: UIView!
    @IBOutlet var filtViewManager: TCCinemaFiltViewManager!

    let types = ["全部", "爱情", "喜剧", "动作", "战争", "科幻", "恐怖", "剧情", "古装", "灾难"]
    let areas = ["全部", "香港", "台湾", "美国", "英国", "大陆", "法国", "印度", "日本", "韩国"]
    let years = ["全部", "2016", "2015", "2014", "2013", "2012", "2011", "2010", "更早"]
    
    var page:Int = 1
    var client = TCCinemaClient()
    var nextPageClient = TCCinemaClient()
    
    var movies:[Int: [TCMovie]] = [Int: [TCMovie]]()
    var totalPage:String = "0"
    
    var type:String!
    var area:String!
    var year:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.type = self.types.first!
        self.area = self.areas.first!
        self.year = self.years.first!
        
        self.movieDetailView.hidden = true
        self.movieDetailView.delegate = self
        self.filtViewManager.delegate = self
        self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .None)
        self.searchBar.setImage(UIImage(named: "ktv_search_icon"), forSearchBarIcon: .Search, state: .Normal)
        if let subViews = self.searchBar.subviews.last?.subviews {
            for v in  subViews {
                if v.isKindOfClass(UITextField) {
                    let tf = v as! UITextField
                    tf.backgroundColor = UIColor.clearColor()
                }
            }
        }
        TCCinemaContext.sharedContext().connect()
        self.loadData()
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

        self.client.getMovies(nil, type: self.type, area: self.area, year: self.year, page: page, limit: limit, getTotalPage: getTotalPage) { (movies, totalPage, flag) in
            if flag {
                self.movies[page] = movies!
                self.collectionView.reloadData()
                if getTotalPage {
                    self.totalPage = totalPage
                    self.updatePage(shouldSelect: false)
                }
            } else {
                self.view.showTextAndHide("加载失败")
            }
        }

        self.nextPageClient.getMovies(nil, type: self.type, area: self.area, year: self.year, page: nextPage, limit: limit, getTotalPage: getTotalPage) { (movies, totalPage, flag) in
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
        if collectionView == self.collectionView {
            return Int(self.totalPage)!
        }
        let page = collectionView.tag + 1
        if let songs = self.movies[page] {
            return songs.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.collectionView {
            self.page = indexPath.item + 1
            if self.movies[self.page] == nil {
                self.loadData()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.tableView {
            return
        }
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movie", forIndexPath: indexPath) as! TCKTVSingerCell
        let page = collectionView.tag + 1
        let movies = self.movies[page]
        let movie = movies![indexPath.row]
        cell.singerNameLabel.text = movie.title
        cell.singerImageView.sd_setImageWithURL(self.client.movieIconURL(movie.movieId))
               
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
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
        if collectionView == self.collectionView {
            return collectionView.bounds.size
        }
        if UI_USER_INTERFACE_IDIOM() == .Phone {
            return CGSizeMake(floor((collectionView.bounds.size.width - 30)/4), floor((collectionView.bounds.size.height - 10)/2))
        }
        return CGSizeMake(floor((collectionView.bounds.size.width - 30)/4), floor((collectionView.bounds.size.width - 30)/4))
    }
    
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("movie", forIndexPath: indexPath)
        let imageView = UIImageView(image: UIImage(named: "ktv_navbar"))
        imageView.contentMode = .ScaleAspectFill
        cell.selectedBackgroundView = imageView
        cell.backgroundColor = UIColor.clearColor()
        let label = cell.contentView.viewWithTag(1) as? UILabel
        switch indexPath.row {
        case 0:
            label?.text = "全部电影"
        case 1:
            label?.text = "爱情电影"
        case 2:
            label?.text = "喜剧电影"
        case 3:
            label?.text = "动作电影"
        case 4:
            label?.text = "战争电影"
        case 5:
            label?.text = "科幻电影"
        case 6:
            label?.text = "恐怖电影"
        case 7:
            label?.text = "剧情电影"
        case 8:
            label?.text = "古装电影"
        case 9:
            label?.text = "灾难电影"
        default: break
            
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.bounds.size.height/10
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.filtView.hidden = false
        self.filtViewManager.typeView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        self.filtViewManager.areaView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: false, scrollPosition: .None)
        self.filtViewManager.yearView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: false, scrollPosition: .None)

        self.type = self.types[indexPath.row];
        self.loadData()
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        self.performSegueWithIdentifier("main2search", sender: self)
        return false
    }
    
    func updatePage(shouldSelect shouldSelect:Bool)  {
        self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
        let indexPath = NSIndexPath(forItem: self.page - 1, inSection: 0)
        if shouldSelect && self.collectionView.numberOfItemsInSection(0) > 0 {
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .None, animated: false)
        }
    }
    
    func clearData() {
        self.totalPage = "0"
        self.movies.removeAll()
        self.collectionView.reloadData()
    }

    @IBAction func hideFiltViewAction(sender: AnyObject) {
        self.filtView.hidden = true
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: DetailViewDelegate
    func onPlay() {
        self.movieDetailView.hidden = true
        let payload = TCSocketPayload()
        payload.cmdType = 2012
        payload.cmdContent = JSON(NSNumber(longLong: self.movieDetailView.movie!.movieId))
        TCCinemaContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    func onClose() {
        self.movieDetailView.hidden = true
    }
    
    // MARK: FiltManagerDelegate
    func onClearFilter() {
        self.type = self.types.first!
        self.area = self.areas.first!
        self.year = self.years.first!
        self.clearData()
        self.loadData()
    }
    
    func onSelectArea(index: Int) {
        self.area = self.areas[index]
        self.clearData()
        self.loadData()
    }
    
    func onSelectType(index: Int) {
        self.type = self.types[index]
        self.clearData()
        self.loadData()
    }
    
    func onSelectYear(index: Int) {
        self.year = self.years[index]
        self.clearData()
        self.loadData()
    }
    
    deinit {
        TCCinemaContext.sharedContext().disconnect()
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
