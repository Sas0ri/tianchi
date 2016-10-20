//
//  ViewController.swift
//  abc
//
//  Created by Sasori on 16/6/13.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCMainViewController: UIViewController {

    var projectorView:KTVProjectorView!
    var settingView:KTVSettingView!
    
    @IBOutlet weak var brightSwitch: UISwitch!
    @IBOutlet weak var softSwitch: UISwitch!
    @IBOutlet weak var activeSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.projectorView = UINib(nibName: "KTVProjectorView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! KTVProjectorView
        self.projectorView.frame = self.view.bounds
        self.view.addSubview(self.projectorView)
        self.projectorView.isHidden = true
        
        self.settingView = UINib(nibName: "KTVSettingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! KTVSettingView
        self.settingView.frame = CGRect(x: 0, y: 0, width: 600/1024*self.view.bounds.size.width, height: 325/768*self.view.bounds.size.height)
        self.settingView.center = self.view.center
        self.view.addSubview(self.settingView)
        self.settingView.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(TCMainViewController.lightStatusChange(sender:)), name: Notification.Name(rawValue:LightStatusChangedNotification), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func lightStatusChange(sender:Notification) {
        let status = sender.object as! String
        let bright = status.substring(to: status.index(status.startIndex, offsetBy: 1))
        self.brightSwitch.isOn = bright == "1"
        let soft = status.substring(with:  Range<String.Index>(uncheckedBounds: (lower: status.index(status.startIndex, offsetBy: 1), upper: status.index(status.startIndex, offsetBy: 2))))
        self.softSwitch.isOn = soft == "1"
        let active = status.substring(from: status.index(status.endIndex, offsetBy: -1))
        self.activeSwitch.isOn = active == "1"
    }
    
    @IBAction func brightValueChanged(_ sender: UISwitch) {
        let payload = TCSocketPayload()
        payload.cmdType = 2211
        payload.cmdContent = JSON(sender.isOn ? "1" : "0")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func softValueChanged(_ sender: UISwitch) {
        let payload = TCSocketPayload()
        payload.cmdType = 2219
        payload.cmdContent = JSON(sender.isOn ? "1" : "0")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func activeValueChanged(_ sender: UISwitch) {
        let payload = TCSocketPayload()
        payload.cmdType = 2220
        payload.cmdContent = JSON(sender.isOn ? "1" : "0")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    
    @IBAction func ktvAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2205
        TCContext.sharedContext().socketManager.sendPayload(payload)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ktv")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func cinemaAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2206
        TCContext.sharedContext().socketManager.sendPayload(payload)
        let vc = UIStoryboard(name: "Cinema", bundle: nil).instantiateViewController(withIdentifier: "cinema_main")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func appsAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2207
        TCContext.sharedContext().socketManager.sendPayload(payload)
        if tcVersion == .full {
            let vc = UIStoryboard(name: "Apps", bundle: nil).instantiateViewController(withIdentifier: "FullApps")
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = UIStoryboard(name: "Apps", bundle: nil).instantiateViewController(withIdentifier: "Apps")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func acAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2208
        TCContext.sharedContext().socketManager.sendPayload(payload)
        let vc = UIStoryboard(name: "AC", bundle: nil).instantiateViewController(withIdentifier: "AC")
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func soundAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2209
        TCContext.sharedContext().socketManager.sendPayload(payload)
        let vc = UIStoryboard(name: "SoundControl", bundle: nil).instantiateViewController(withIdentifier: "sound_control")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pluginAction(_ sender: AnyObject) {
        let vc = UIStoryboard(name: "Plugin", bundle: nil).instantiateViewController(withIdentifier: "plugin_mode")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func turnOffAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2210
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func settingAction(_ sender: AnyObject) {
        self.settingView.centerIPField.text = TCContext.sharedContext().serverAddress
        self.settingView.ktvIPField.text = TCContext.sharedContext().ktvServerAddress
        self.settingView.isHidden = false
    }
    
    @IBAction func projectorAction(_ sender: AnyObject) {
        self.projectorView.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

