//
//  TCSoundControlViewController.swift
//  tc
//
//  Created by Sasori on 16/8/31.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCSoundControlViewController: UIViewController {

    var hidesBackButton:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cinemaVolumnUp(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2213
        payload.cmdContent = JSON("AMPM" + ",音量+")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func cinemaVolumnDown(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2213
        payload.cmdContent = JSON("AMPM" + ",音量-")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func ktvVolumnUp(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2213
        payload.cmdContent = JSON("AMPS" + ",音量+")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func ktvVolumnDown(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2213
        payload.cmdContent = JSON("AMPS" + ",音量-")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func ktvReverbUp(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2213
        payload.cmdContent = JSON("AMPS" + ",混响+")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func ktvReverbDown(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2213
        payload.cmdContent = JSON("AMPS" + ",混响-")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func ktvPhoneUp(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2213
        payload.cmdContent = JSON("AMPS" + ",话筒+")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func ktvPhoneDown(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2213
        payload.cmdContent = JSON("AMPS" + ",话筒-")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func ktvKeyUpDown(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2213
        payload.cmdContent = JSON("AMPS" + ",升调")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func ktvKeyNormal(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2213
        payload.cmdContent = JSON("AMPS" + ",平调")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func ktvKeyDown(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2213
        payload.cmdContent = JSON("AMPS" + ",降调")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func levelAction(_ sender: UIButton) {
        let desc:String = {
            switch sender.tag {
            case 10:
                return "资深级"
            case 11:
                return "歌手级"
            case 12:
                return "专业级"
            case 13:
                return "轻松级"
            case 14:
                return "练习级"
            case 15:
                return "业余级"
                
            default:
                return ""
            }
        }()
        let payload = TCSocketPayload()
        payload.cmdType = 2213
        payload.cmdContent = JSON("AMPS," + desc)
        TCContext.sharedContext().socketManager.sendPayload(payload)
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
