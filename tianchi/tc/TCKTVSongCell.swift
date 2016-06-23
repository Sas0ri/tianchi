//
//  TCKTVSongCell.swift
//  tc
//
//  Created by Sasori on 16/6/20.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

protocol TCKTVSongCellDelegate {
    func onFirstAction(cell: UICollectionViewCell)
    func onSecondAction(cell:UICollectionViewCell)
}

class TCKTVSongCell: UICollectionViewCell {
    
    var delegate:TCKTVSongCellDelegate?
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var singerNameLabel: UILabel!
    
    @IBAction func firstAction(sender: AnyObject) {
        self.delegate?.onFirstAction(self)
    }
    
    @IBAction func secondAction(sender: AnyObject) {
        self.delegate?.onSecondAction(self)
    }
}
