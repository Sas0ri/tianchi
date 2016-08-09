//
//  TVKTVLanguageViewController.swift
//  tc
//
//  Created by Sasori on 16/6/15.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

enum TCKTVLanguage:Int {
    case Mandarin = 2
    case Korean = 3
    case Japanese = 4
    case Taiwanese = 5
    case English = 6
    case Cantonese = 7
}

class TCKTVLanguageViewController: UIViewController, UICollectionViewDelegateFlowLayout {

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
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if UI_USER_INTERFACE_IDIOM() == .Pad {
            return CGSizeMake(216, 208)
        }
        return CGSizeMake((collectionView.bounds.size.height - 10)/2, (collectionView.bounds.size.height - 10)/2)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let button = sender as! UIButton
        let vc = segue.destinationViewController as! TCKTVSongsViewController
        vc.language = TCKTVLanguage(rawValue: button.tag)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
