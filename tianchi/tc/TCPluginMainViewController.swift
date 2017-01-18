//
//  TCPluginMainViewController.swift
//  tc
//
//  Created by Sasori on 2017/1/18.
//  Copyright © 2017年 Sasori. All rights reserved.
//

import UIKit

class TCPluginMainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pluginAction(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "是否进入DVD/蓝光模式？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { (alertAction) in
            let cmdType:Int = sender.tag == 10 ? 2208 : 2209
            let payload = TCSocketPayload()
            payload.cmdType = cmdType
            TCContext.sharedContext().socketManager.sendPayload(payload)

            self.performSegue(withIdentifier: "main2plugin", sender: sender.tag == 10 ? "3" : "4")
        }))
        self.present(alert, animated: true, completion: nil)

    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is TCPluginViewController {
            let vc = segue.destination as! TCPluginViewController
            vc.mode = sender as! String
        }
    }
    

}
