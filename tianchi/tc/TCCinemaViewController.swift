//
//  TCCinemaViewController.swift
//  tc
//
//  Created by Sasori on 16/9/5.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


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
        
        self.movieDetailView.isHidden = true
        self.movieDetailView.delegate = self
        self.filtViewManager.delegate = self
        self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        self.searchBar.setImage(UIImage(named: "ktv_search_icon"), for: .search, state: UIControlState())
        if let subViews = self.searchBar.subviews.last?.subviews {
            for v in  subViews {
                if v.isKind(of: UITextField.self) {
                    let tf = v as! UITextField
                    tf.backgroundColor = UIColor.clear
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
    
    @IBAction func prePage(_ sender: AnyObject) {
        if self.page == 1 {
            return
        }
        self.page = self.page - 1
        self.updatePage(shouldSelect: true)
        self.loadData()
    }
    
    @IBAction func nextPage(_ sender: AnyObject) {
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
        
        self.client.getMovies(nil, type: self.type, area: self.area, year: self.year, page: page, limit: limit, getTotalPage: getTotalPage) {
            [weak self]
            (movies, totalPage, flag) in
            if flag {
                self?.movies[page] = movies!
                self?.collectionView.reloadData()
                if getTotalPage {
                    self?.totalPage = totalPage
                    self?.updatePage(shouldSelect: false)
                }
            } else {
                self?.view.showTextAndHide("加载失败")
            }
        }

        self.nextPageClient.getMovies(nil, type: self.type, area: self.area, year: self.year, page: nextPage, limit: limit, getTotalPage: getTotalPage) {
            [weak self]
            (movies, totalPage, flag) in
            if flag {
                self?.movies[nextPage] = movies!
            }
        }
    }
    
    // MARK: - CollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return Int(self.totalPage)!
        }
        let page = collectionView.tag + 1
        if let songs = self.movies[page] {
            return songs.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            self.page = (indexPath as NSIndexPath).item + 1
            if self.movies[self.page] == nil {
                self.loadData()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            return
        }
        self.page =  (self.collectionView.indexPathsForVisibleItems.first! as NSIndexPath).row + 1
        self.updatePage(shouldSelect: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if UI_USER_INTERFACE_IDIOM() == .pad {
            return 40
        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "container", for: indexPath) as! TCKTVContainerCell
            cell.collectionView.tag = (indexPath as NSIndexPath).row
            cell.collectionView.reloadData()
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movie", for: indexPath) as! TCKTVSingerCell
        let page = collectionView.tag + 1
        let movies = self.movies[page]
        let movie = movies![(indexPath as NSIndexPath).row]
        cell.singerNameLabel.text = movie.title
        cell.singerImageView.sd_setImage(with: self.client.movieIconURL(movie.movieId))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if collectionView == self.collectionView {
            return
        }
        let page = collectionView.tag + 1
        let movies = self.movies[page]
        let movie = movies![(indexPath as NSIndexPath).row]
        self.movieDetailView.isHidden = false
        self.movieDetailView.movie = movie
        self.movieDetailView.titleLabel.text = movie.title
        self.movieDetailView.infoLabel.text = movie.info
        self.movieDetailView.imageView.sd_setImage(with: self.client.movieIconURL(movie.movieId))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return collectionView.bounds.size
        }
        if UI_USER_INTERFACE_IDIOM() == .phone {
            return CGSize(width: floor((collectionView.bounds.size.width - 30)/4), height: floor((collectionView.bounds.size.height - 10)/2))
        }
        return CGSize(width: floor((collectionView.bounds.size.width - 30)/4), height: floor((collectionView.bounds.size.width - 30)/4))
    }
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movie", for: indexPath)
        let imageView = UIImageView(image: UIImage(named: "ktv_navbar"))
        imageView.contentMode = .scaleAspectFill
        cell.selectedBackgroundView = imageView
        cell.backgroundColor = UIColor.clear
        let label = cell.contentView.viewWithTag(1) as? UILabel
        switch (indexPath as NSIndexPath).row {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.size.height/10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.clearData()
        self.type = self.types[(indexPath as NSIndexPath).row];
        self.loadData()
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.performSegue(withIdentifier: "main2search", sender: self)
        return false
    }
    
    func updatePage(shouldSelect:Bool)  {
        self.pageLabel.text = "\(self.page == 1 && Int(self.totalPage) == 0 ? 0 : self.page)" + "/" + self.totalPage
        let indexPath = IndexPath(item: self.page - 1, section: 0)
        if shouldSelect && self.collectionView.numberOfItems(inSection: 0) > 0 {
            self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition(), animated: false)
        }
    }
    
    func clearData() {
        self.totalPage = "0"
        self.page = 1
        self.updatePage(shouldSelect: false)
        self.movies.removeAll()
        self.collectionView.reloadData()
    }

    @IBAction func filtAction(_ sender: AnyObject) {
        let indexPath = self.tableView.indexPathForSelectedRow
        self.filtView.isHidden = false
        self.filtViewManager.typeView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
        self.filtViewManager.areaView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        self.filtViewManager.yearView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
    }
    
    @IBAction func hideFiltViewAction(_ sender: AnyObject) {
        self.filtView.isHidden = true
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
       _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: DetailViewDelegate
    func onPlay() {
        self.movieDetailView.isHidden = true
        let payload = TCSocketPayload()
        payload.cmdType = 2012
        payload.cmdContent = JSON(NSNumber(value: self.movieDetailView.movie!.movieId as Int64))
        TCCinemaContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    func onClose() {
        self.movieDetailView.isHidden = true
    }
    
    // MARK: FiltManagerDelegate
    func onClearFilter() {
        self.type = self.types.first!
        self.area = self.areas.first!
        self.year = self.years.first!
        self.clearData()
        self.loadData()
    }
    
    func onSelectArea(_ index: Int) {
        self.area = self.areas[index]
        self.clearData()
        self.loadData()
    }
    
    func onSelectType(_ index: Int) {
        self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
        self.type = self.types[index]
        self.clearData()
        self.loadData()
    }
    
    func onSelectYear(_ index: Int) {
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
