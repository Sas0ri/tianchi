//
//  ViewController.swift
//  abc
//
//  Created by Sasori on 16/6/13.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCMainViewController: UIViewController {

    var projectorView:KTVSettingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.projectorView = UINib(nibName: "KTVSettingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! KTVSettingView
        self.projectorView.frame = CGRect(x: 0, y: 0, width: 600/1024*self.view.bounds.size.width, height: 325/768*self.view.bounds.size.height)
        self.projectorView.center = self.view.center
        self.view.addSubview(self.projectorView)
        self.projectorView.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func ktvAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2205
        TCContext.sharedContext().socketManager.sendPayload(payload)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ktv")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func acAction(_ sender: AnyObject) {
        let vc = UIStoryboard(name: "AC", bundle: nil).instantiateViewController(withIdentifier: "AC")
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func soundAction(_ sender: AnyObject) {
        let vc = UIStoryboard(name: "SoundControl", bundle: nil).instantiateViewController(withIdentifier: "sound_control")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func appsAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2207
        TCContext.sharedContext().socketManager.sendPayload(payload)
        let vc = UIStoryboard(name: "Apps", bundle: nil).instantiateViewController(withIdentifier: "Apps")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func pluginAction(_ sender: AnyObject) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "plugin_mode")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func cinemaAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2206
        TCContext.sharedContext().socketManager.sendPayload(payload)
        let vc = UIStoryboard(name: "Cinema", bundle: nil).instantiateViewController(withIdentifier: "cinema_main")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func turnOffAction(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2210
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func showProjectorView() {
        
    }
}

