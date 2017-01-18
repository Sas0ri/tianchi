//
//  TCACViewController.swift
//  tc
//
//  Created by Sasori on 16/8/31.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCACViewController: UIViewController {

    @IBOutlet weak var temperatureLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        var fontSize:CGFloat = 100
        if UI_USER_INTERFACE_IDIOM() == .phone {
            fontSize = 50
        }
        self.temperatureLabel.font = UIFont(name: "DBLCDTempBlack", size: fontSize)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        UIHelper.setNavigationBar(self.navigationController?.navigationBar, translucent: true)
    }

    @IBAction func backAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tempUp(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2217
        let temper = Int(self.temperatureLabel.text!)! + 1
        if temper > 31 {
            return
        }
        self.temperatureLabel.text = String(temper)
        payload.cmdContent = JSON(self.temperatureLabel.text!)
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func tempDown(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2217
        let temper = Int(self.temperatureLabel.text!)! - 1
        if temper < 16 {
            return
        }
        self.temperatureLabel.text = String(temper)
        payload.cmdContent = JSON(self.temperatureLabel.text!)
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func coldMode(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2216
        payload.cmdContent = JSON("制冷")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func warmMode(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2216
        payload.cmdContent = JSON("制热")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func dehumidifier(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2216
        payload.cmdContent = JSON("抽湿")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func blow(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2216
        payload.cmdContent = JSON("送风")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func auto(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2218
        payload.cmdContent = JSON("自动")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func lowWind(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2218
        payload.cmdContent = JSON("低风")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func normalWind(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2218
        payload.cmdContent = JSON("中风")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func highWind(_ sender: AnyObject) {
        let payload = TCSocketPayload()
        payload.cmdType = 2218
        payload.cmdContent = JSON("高风")
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    @IBAction func powerAction(_ sender: Any) {
        let payload = TCSocketPayload()
        payload.cmdType = 2212
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
