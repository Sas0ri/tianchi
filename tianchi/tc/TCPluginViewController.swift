//
//  TCPluginViewController.swift
//  tc
//
//  Created by Sasori on 2016/10/18.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

class TCPluginViewController: UIViewController {

    var mode:String!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.updateTitle()
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func updateTitle() {
        switch self.mode {
        case "0":
            self.titleLabel.text = "K歌模式"
        case "1":
            self.titleLabel.text = "电影模式"
        case "2":
            self.titleLabel.text = "网络应用"
        case "3":
            self.titleLabel.text = "蓝光/DVD"
        case "4":
            self.titleLabel.text = "有线电视"
        default:
            break
        }
    }

    @IBAction func powerAdjustAction(_ sender: UIButton) {
        let vc = UIStoryboard(name: "SoundControl", bundle: nil).instantiateViewController(withIdentifier: "sound_control") as! TCSoundControlViewController
        vc.hidesBackButton = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func menuAction(_ sender: Any) {
        self.sendCmd(desc: "菜单")
    }
    
    @IBAction func subtitleAction(_ sender: Any) {
        self.sendCmd(desc: "字幕")
    }
    
    @IBAction func languageAction(_ sender: Any) {
        self.sendCmd(desc: "音轨")
    }
    
    @IBAction func muteAction(_ sender: Any) {
        self.sendCmd(desc: "静音")
    }
    
    @IBAction func preSectionAction(_ sender: Any) {
        self.sendCmd(desc: "上一节")
    }
    
    @IBAction func fastbackAction(_ sender: Any) {
        self.sendCmd(desc: "快退")
    }
    
    @IBAction func fastforwardAction(_ sender: Any) {
        self.sendCmd(desc: "快进")
    }
    
    @IBAction func nextSectionAction(_ sender: Any) {
        self.sendCmd(desc: "下一节")
    }
    
    @IBAction func pauseAction(_ sender: Any) {
        self.sendCmd(desc: "暂停")
    }
    
    @IBAction func playAction(_ sender: Any) {
        self.sendCmd(desc: "播放")
    }
    
    @IBAction func stopAction(_ sender: Any) {
        self.sendCmd(desc: "停止")
    }
    
    @IBAction func inOutAciton(_ sender: UIButton) {
        let desc = sender.isSelected ? "进仓" : "出仓"
        self.sendCmd(desc: desc)
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func returnAction(_ sender: Any) {
        self.sendCmd(desc: "返回")
    }

    @IBAction func volumnUpAction(_ sender: Any) {
        self.sendCmd(desc: "音量+")
    }
    
    @IBAction func volumnDownAction(_ sender: Any) {
        self.sendCmd(desc: "音量-")
    }
    
    @IBAction func upAction(_ sender: Any) {
        self.sendCmd(desc: "上")
    }
    
    @IBAction func leftAction(_ sender: Any) {
        self.sendCmd(desc: "左")
    }
    
    @IBAction func downAction(_ sender: Any) {
        self.sendCmd(desc: "下")
    }
    
    @IBAction func rightAction(_ sender: Any) {
        self.sendCmd(desc: "右")

    }
    
    @IBAction func okAction(_ sender: Any) {
        self.sendCmd(desc: "确定")
    }
    
    func sendCmd(desc:String) {
        let payload = TCSocketPayload()
        payload.cmdType = 2214
        payload.cmdContent = JSON(self.mode + "," + desc)
        TCContext.sharedContext().socketManager.sendPayload(payload)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
