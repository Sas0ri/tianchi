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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
        if #available(iOS 9.0, *) {
            let item = self.searchField.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        }
        self.deleteButton.setBackgroundImage(UIImage(color: UIColor(fromHexCode:"4f4f4f"), cornerRadius:4), for: UIControlState())
        self.doneButton.setBackgroundImage(UIImage(color: UIColor(fromHexCode:"4f4f4f"), cornerRadius:4), for: UIControlState())
        self.movieDetailView.isHidden = true
        self.loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchField.font = UIFont.systemFont(ofSize: self.searchField.bounds.size.height - 1)
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
        
        self.client.getMovies(self.searchField.text, type: "全部", area: "全部", year: "全部", page: page, limit: limit, getTotalPage: getTotalPage) {
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
        
        self.nextPageClient.getMovies(self.searchField.text, type: "全部", area: "全部", year: "全部", page: nextPage, limit: limit, getTotalPage: getTotalPage) {
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.keyboardView {
            return
        }
        if collectionView == self.collectionView {
            self.page = (indexPath as NSIndexPath).item + 1
            if self.movies[self.page] == nil {
                self.loadData()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.page =  (self.collectionView.indexPathsForVisibleItems.first! as NSIndexPath).row + 1
        self.updatePage(shouldSelect: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.keyboardView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "key", for: indexPath)
            let label = cell.contentView.viewWithTag(1) as? UILabel
            label?.text = self.keys[(indexPath as NSIndexPath).row]
            return cell
        }
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
        if collectionView == self.keyboardView {
            self.searchField.text = self.searchField.text! + self.keys[(indexPath as NSIndexPath).row]
            self.alignSearchField()
            return
        }
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
        if collectionView == self.keyboardView {
            var sep:CGFloat = 32
            if UI_USER_INTERFACE_IDIOM() == .pad {
                sep = 80
            }
            let height = (collectionView.bounds.size.height - sep)/9
            return CGSize(width: (collectionView.bounds.size.width - 20)/4, height: height)
        }
        if collectionView == self.collectionView {
            return collectionView.bounds.size
        }
        
        if UI_USER_INTERFACE_IDIOM() == .phone {
            return CGSize(width: floor((collectionView.bounds.size.width - 30)/4), height: floor((collectionView.bounds.size.height - 10)/2))
        }
        return CGSize(width: floor((collectionView.bounds.size.width - 30)/4), height: floor((collectionView.bounds.size.width - 30)/4))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.collectionView {
            return 0
        }
        if UI_USER_INTERFACE_IDIOM() == .pad {
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
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    @IBAction func deleteAction(_ sender: AnyObject) {
        if self.searchField.text?.characters.count > 0 {
            let index = self.searchField.text?.characters.index((self.searchField.text?.endIndex)!, offsetBy: -1)
            self.searchField.text = self.searchField.text?.substring(to: index!)
            self.alignSearchField()
        }
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.loadData()
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        self.movieDetailView.isHidden = true
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    func alignSearchField() {
        let text = self.searchField.text! as NSString
        let size = text.size(attributes: [NSFontAttributeName: self.searchField.font!])
        self.searchField.textAlignment = size.width > self.searchField.bounds.size.width ? .right : .left
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
        
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
