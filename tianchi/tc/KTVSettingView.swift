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
    @IBOutlet weak var ktvIPField: UITextField!
    @IBOutlet weak var centerIPField: UITextField!
    @IBOutlet weak var useV800SButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doneButton.layer.cornerRadius = 4
        self.doneButton.layer.borderWidth = 1
        self.doneButton.layer.borderColor = UIColor.white.cgColor
        
        self.cancelButton.layer.cornerRadius = 4
        self.cancelButton.layer.borderWidth = 1
        self.cancelButton.layer.borderColor = UIColor.white.cgColor
        
        self.useV800SButton.isSelected = TCContext.sharedContext().useK800S
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.isHidden = true
        if self.centerIPField.text!.characters.count > 0 {
            TCContext.sharedContext().disconnect()
            TCContext.sharedContext().serverAddress = self.centerIPField.text
            TCContext.sharedContext().socketManager.connect()
        }
        if self.ktvIPField.text!.characters.count > 0 {
            TCContext.sharedContext().ktvServerAddress = self.ktvIPField.text
        }
    }
    
    @IBAction func userV800SAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        TCContext.sharedContext().useK800S = sender.isSelected
        self.ktvIPField.isEnabled = sender.isSelected
        self.ktvIPField.backgroundColor = self.ktvIPField.isEnabled ? UIColor.white : UIColor.gray
    }
    
    @IBAction func cancelAciton(_ sender: AnyObject) {
        self.isHidden = true
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
