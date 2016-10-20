//
//  TCTVPanelView.swift
//  tc
//
//  Created by Sasori on 2016/10/20.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCTVPanelView: UIView {

    enum TCMode:String {
        case apps = "2"
        case dvd = "3"
        case tv = "4"
    }
    
    var mode:TCMode = .apps
    
    @IBOutlet var outButton:UIButton!
    @IBOutlet var powerButton:UIButton!
    @IBOutlet var upButton:UIButton!
    @IBOutlet var downButton:UIButton!
    @IBOutlet var leftButton:UIButton!
    @IBOutlet var rightButton:UIButton!
    @IBOutlet var doneButton:UIButton!
    @IBOutlet var volumnUpButton:UIButton!
    @IBOutlet var volumnDownButton:UIButton!
    @IBOutlet var forwardButton:UIButton!
    @IBOutlet var backwardButton:UIButton!
    @IBOutlet var stopButton:UIButton!
    @IBOutlet var backButton:UIButton!

    override func awakeFromNib() {
        var font:UIFont = UIFont.systemFont(ofSize: 12)
        if UIScreen.main.bounds.size.width < 375 {
            font = UIFont.systemFont(ofSize: 9)
        }
        self.outButton.titleLabel?.font = font
        self.volumnUpButton.titleLabel?.font = font
        self.volumnDownButton.titleLabel?.font = font
        self.forwardButton.titleLabel?.font = font
        self.backButton.titleLabel?.font = font
        self.stopButton.titleLabel?.font = font
        self.backButton.titleLabel?.font = font
    }
    
    @IBAction func inOutAction(sender:UIButton) {
        let payload =  TCSocketPayload()
        payload.cmdType = 2214
        payload.cmdContent = JSON(self.mode.rawValue + ",进/出仓")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func powerAction(sender:UIButton) {
        let payload =  TCSocketPayload()
        payload.cmdType = 2214
        payload.cmdContent = JSON(self.mode.rawValue + ",关")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func upAction(sender:UIButton) {
        let payload =  TCSocketPayload()
        payload.cmdType = 2214
        payload.cmdContent = JSON(self.mode.rawValue + ",上")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func downAction(sender:UIButton) {
        let payload =  TCSocketPayload()
        payload.cmdType = 2214
        payload.cmdContent = JSON(self.mode.rawValue + ",下")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func leftAction(sender:UIButton) {
        let payload =  TCSocketPayload()
        payload.cmdType = 2214
        payload.cmdContent = JSON(self.mode.rawValue + ",左")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func rightAction(sender:UIButton) {
        let payload =  TCSocketPayload()
        payload.cmdType = 2214
        payload.cmdContent = JSON(self.mode.rawValue + ",右")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func doneAction(sender:UIButton) {
        let payload =  TCSocketPayload()
        payload.cmdType = 2214
        payload.cmdContent = JSON(self.mode.rawValue + ",确定")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func volumnUpAction(sender:UIButton) {
        let payload =  TCSocketPayload()
        payload.cmdType = 2214
        payload.cmdContent = JSON(self.mode.rawValue + ",音量+")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func volumnDownAction(sender:UIButton) {
        let payload =  TCSocketPayload()
        payload.cmdType = 2214
        payload.cmdContent = JSON(self.mode.rawValue + ",音量-")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func forwardAction(sender:UIButton) {
        let payload =  TCSocketPayload()
        payload.cmdType = 2214
        payload.cmdContent = JSON(self.mode.rawValue + ",快进")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func backwardAction(sender:UIButton) {
        let payload =  TCSocketPayload()
        payload.cmdType = 2214
        payload.cmdContent = JSON(self.mode.rawValue + ",快退")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func stopAction(sender:UIButton) {
        let payload =  TCSocketPayload()
        payload.cmdType = 2214
        payload.cmdContent = JSON(self.mode.rawValue + ",停止")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func backAction(sender:UIButton) {
        let payload =  TCSocketPayload()
        payload.cmdType = 2214
        payload.cmdContent = JSON(self.mode.rawValue + ",返回")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }

}
