//
//  TCContext.swift
//  tc
//
//  Created by Sasori on 16/6/20.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

let _sharedContext:TCContext = TCContext()

class TCContext: NSObject, TCSocketManagerDelegate, UIAlertViewDelegate {
    
    class func sharedContext() -> TCContext {
        return _sharedContext
    }
    
    var serverAddress:String? {
        didSet {
            if let sa = serverAddress {
                NSUserDefaults.standardUserDefaults().setObject(sa, forKey: "SA")
            }
        }
    }
    
    var socketManager = TCSocketManager()
    var verifyAlertView: UIAlertView?
    
    var downloads:[TCKTVDownload] = [TCKTVDownload]()
    var client:TCKTVSongClient?

    enum AlertTag: Int {
        case Address = 501
        case Verify = 502
        case Both = 503
        case Reconnect = 504
    }
    

    
    override init() {
        super.init()
        self.socketManager.delegate = self
        self.serverAddress = NSUserDefaults.standardUserDefaults().objectForKey("SA") as? String
        if self.serverAddress != nil {
            self.socketManager.address = self.serverAddress
            self.socketManager.port = 9596
            self.socketManager.connect()
        } else {
            self.showInputAddress()
        }
    }
    
    func didReceivePayload(payload: TCSocketPayload) {
        if payload.cmdType == 1900 {
            self.showVerify()
            return
        }
        if payload.cmdType == 1901 {
            self.verifyAlertView?.dismissWithClickedButtonIndex(0, animated: false)
            return
        }
        if payload.cmdType == 1902 {
            self.showBoth()
            return
        }
        TCKTVPayloadHandler.sharedHandler().handlePayload(payload)
    }
    
    func connectFailed() {
        let alertView = UIAlertView(title: "", message: "无法连接服务器", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "重新连接", "输入服务器地址")
        alertView.tag = AlertTag.Reconnect.rawValue
        alertView.show()
    }
    
    func didDisconnect() {
        let alertView = UIAlertView(title: "", message: "与服务器断开连接", delegate: nil, cancelButtonTitle: "取消", otherButtonTitles: "重新连接", "输入服务器地址")
        alertView.tag = AlertTag.Reconnect.rawValue
        alertView.show()
    }
    
    func getDownload() {
        if self.client == nil {
            self.client = TCKTVSongClient()
        }
        self.client!.getDownloadSongs({ (downloads, flag) in
            if flag {
                self.downloads = downloads!
                NSNotificationCenter.defaultCenter().postNotificationName(TCKTVDownloadLoadedNotification, object: self)
            }
        })
    }
    
    func didHandShake() {
        self.getDownload()
    }
    
    func showBoth() {
        let alertView = UIAlertView(title: "", message: "请选择", delegate: self, cancelButtonTitle: "重新输入服务器地址", otherButtonTitles: "重新输入验证码")
        alertView.tag = AlertTag.Both.rawValue
        alertView.show()
    }
    
    func showInputAddress() {
        let alertView = UIAlertView(title: nil, message: "输入服务器地址", delegate: self, cancelButtonTitle: "确定")
        alertView.alertViewStyle = .PlainTextInput
        alertView.tag = AlertTag.Address.rawValue
        alertView.show()
        
    }
    
    func showVerify() {
        let alertView = UIAlertView(title: "", message: "请输入验证码", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "确定")
        alertView.alertViewStyle = .PlainTextInput
        alertView.tag = AlertTag.Verify.rawValue
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == AlertTag.Address.rawValue {
            self.serverAddress = alertView.textFieldAtIndex(0)?.text
        } else if alertView.tag == AlertTag.Verify.rawValue {
            let textField = alertView.textFieldAtIndex(0)
            let payload = TCSocketPayload()
            payload.cmdType = 1900
            payload.cmdContent = textField!.text
            self.socketManager.sendPayload(payload)
            
            let alertView = UIAlertView(title: "", message: "正在验证...", delegate: nil, cancelButtonTitle: nil)
            let aiView = UIActivityIndicatorView(frame: CGRectMake(125.0, 40, 30.0, 30.0))
            aiView.activityIndicatorViewStyle = .WhiteLarge;
            aiView.startAnimating()
            aiView.color = UIColor.blackColor()
            
            alertView.setValue(aiView, forKey: "accessoryView")
            alertView.show()
            self.verifyAlertView = alertView
        } else if alertView.tag == AlertTag.Both.rawValue {
            if buttonIndex == 0 {
                self.showInputAddress()
            } else if buttonIndex == 1 {
                self.showVerify()
            }
        } else if alertView.tag == AlertTag.Reconnect.rawValue {
            if buttonIndex == 0 {
                self.socketManager.connect()
            } else if buttonIndex == 1 {
                self.showInputAddress()
            }
        }
    }
}
