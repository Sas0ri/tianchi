//
//  TCMovieDetailView.swift
//  tc
//
//  Created by Sasori on 16/9/8.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

protocol TCMovieDetailViewDelegate:NSObjectProtocol {
    func onPlay()
    func onClose()
}

class TCMovieDetailView: UIView {

    @IBOutlet weak var imageView:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var infoLabel:UILabel!

    var movie:TCMovie?
    
    weak var delegate:TCMovieDetailViewDelegate?
    
    @IBAction func playAction(sender: AnyObject) {
        self.delegate?.onPlay()
    }
    
    @IBAction func closeAction(sender: AnyObject) {
        self.delegate?.onClose()
    }
}
