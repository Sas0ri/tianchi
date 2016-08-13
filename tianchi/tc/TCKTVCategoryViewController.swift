//
//  TVKTVCategoryViewController.swift
//  tc
//
//  Created by Sasori on 16/6/15.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCKTVCategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    // MARK: - CollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("song", forIndexPath: indexPath)
        let label = cell.viewWithTag(2) as! UILabel
        let imageView = cell.viewWithTag(1) as! UIImageView
        var category = ""
        var image = ""
        switch indexPath.row {
        case 0:
            category = "流行"
            image = "popular"
        case 1:
            category = "小品"
            image = "sketch"
        case 2:
            category = "迪高"
            image = "deco"
        case 3:
            category = "合唱"
            image = "chorus"
        case 4:
            category = "戏剧"
            image = "opera"
        case 5:
            category = "舞曲"
            image = "dance"
        case 6:
            category = "革命"
            image = "revolution"
        case 7:
            category = "儿歌"
            image = "children"
        default:
            category = ""
        }
        label.text = category
        imageView.image = UIImage(named: image)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if UI_USER_INTERFACE_IDIOM() == .Pad {
            return CGSizeMake(216, 208)
        }
        return CGSizeMake((collectionView.bounds.size.width - 30)/4, (collectionView.bounds.size.height - 20)/2)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UICollectionViewCell
        let indexPath = self.collectionView.indexPathForCell(cell)
        var category = ""
        switch indexPath!.row {
        case 0:
            category = "RTP1"
        case 1:
            category = "RTP10"
        case 2:
            category = "RTP11"
        case 3:
            category = "RTP2"
        case 4:
            category = "RTP9"
        case 5:
            category = "RTP7"
        case 6:
            category = "RTP5"
        case 7:
            category = "RTP4"
        default:
            category = ""
        }

        let vc = segue.destinationViewController as! TCKTVSongsViewController
        vc.category = category

    }

}
