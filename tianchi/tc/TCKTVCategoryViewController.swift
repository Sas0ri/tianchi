//
//  TVKTVCategoryViewController.swift
//  tc
//
//  Created by Sasori on 16/6/15.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCKTVCategoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

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
        var category = ""
        switch indexPath.row {
        case 0:
            category = "流行"
        case 1:
            category = "小品"
        case 2:
            category = "迪高"
        case 3:
            category = "合唱"
        case 4:
            category = "戏剧"
        case 5:
            category = "舞曲"
        case 6:
            category = "革命"
        case 7:
            category = "儿歌"
        default:
            category = ""
        }
        label.text = category
        return cell
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
