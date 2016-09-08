//
//  TCCinemaPanel.swift
//  tc
//
//  Created by Sasori on 16/9/8.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCCinemaPanel: UIView {

    @IBAction func volumnUpAction(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2004
        TCCinemaContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func volumnDownAciton(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2005
        TCCinemaContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func pauseAciton(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2006
        TCCinemaContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func subtitleAciton(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2009
        TCCinemaContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func trackAciton(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2010
        TCCinemaContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func backwardAciton(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2008
        TCCinemaContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func forwardAciton(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2007
        TCCinemaContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func switch2d3dAciton(sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2011
        TCCinemaContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
