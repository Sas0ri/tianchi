//
//  TCCinemaFiltViewManager.swift
//  tc
//
//  Created by Sasori on 16/9/6.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

protocol TCCinemaFiltViewManagerDelegate:NSObjectProtocol {
    func onClearFilter()
    func onSelectType(index:Int)
    func onSelectArea(index:Int)
    func onSelectYear(index:Int)
}

class TCCinemaFiltViewManager: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var typeView: UICollectionView!
    @IBOutlet weak var areaView: UICollectionView!
    @IBOutlet weak var yearView: UICollectionView!
    weak var delegate:TCCinemaFiltViewManagerDelegate?
    
    let types = ["全部", "爱情", "喜剧", "动作", "战争", "科幻", "恐怖", "剧情", "古装", "灾难"]
    let areas = ["全部", "香港", "台湾", "美国", "英国", "大陆", "法国", "印度", "日本", "韩国"]
    let years = ["全部", "2016", "2015", "2014", "2013", "2012", "2011", "2010", "更早"]
    
    @IBAction func clearAction(sender: AnyObject) {
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        self.typeView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        self.areaView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        self.yearView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        self.delegate?.onClearFilter()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.yearView {
            return 9
        }
        return 10
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        let label = cell.contentView.viewWithTag(1) as? UILabel
        if collectionView == self.typeView {
            label?.text = self.types[indexPath.row]
        } else if collectionView == self.areaView {
            label?.text = self.areas[indexPath.row]
        } else if collectionView == self.yearView {
            label?.text = self.years[indexPath.row]
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.size.width/2, collectionView.bounds.size.height/5)
    }
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.typeView {
            self.delegate?.onSelectType(indexPath.item)
        } else if collectionView == self.areaView {
            self.delegate?.onSelectArea(indexPath.item)
        } else if collectionView == self.yearView {
            self.delegate?.onSelectYear(indexPath.item)
        }
    }
}
