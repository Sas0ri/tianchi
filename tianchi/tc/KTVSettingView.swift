//
//  KTVSettingView.swift
//  tc
//
//  Created by Sasori on 2016/10/18.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class KTVSettingView: UIView {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doneButton.layer.cornerRadius = 4
        self.doneButton.layer.borderWidth = 1
        self.doneButton.layer.borderColor = UIColor.white.cgColor
        
        self.cancelButton.layer.cornerRadius = 4
        self.cancelButton.layer.borderWidth = 1
        self.cancelButton.layer.borderColor = UIColor.white.cgColor
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
