//
//  KTVProjectorView.swift
//  tc
//
//  Created by Sasori on 2016/10/20.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class KTVProjectorView: UIView, UIGestureRecognizerDelegate {

    @IBOutlet weak var contentView: UIView!
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
         return !self.contentView.bounds.contains(touch.location(in: self.contentView))
    }
    
    @IBAction func tapAction(_ sender: AnyObject) {
        self.isHidden = true
    }

    @IBAction func powerAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2301
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func switchAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2302
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }

    @IBAction func backAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2303
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
}
