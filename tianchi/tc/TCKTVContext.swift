//
//  TCKTVContext.swift
//  tc
//
//  Created by Sasori on 16/9/7.
//  Copyright © 2016年 Sasori. All rights reserved.
//

import UIKit

let _ktvContext = TCKTVContext()

class TCKTVContext: NSObject, TCSocketManagerDelegate, UIAlertViewDelegate {
    
    
    class func sharedContext() -> TCKTVContext {
        return _ktvContext
    }
    
    var serverAddress:String? {
        get {
            return TCContext.sharedContext().serverAddress
        }
    }
    
    var socketManager = TCSocketManager()
    var verifyAlertView: UIAlertView?
    
    var orderedSongsViewController:TCKTVSongsViewController?
    
    var downloads:[TCKTVDownload] = [TCKTVDownload]()
    var client:TCKTVSongClient?
    
    enum AlertTag: Int {
        case Address = 501
        case Verify = 502
        case Both = 503
        case Reconnect = 504
    }
    
    let port:UInt16 = 9596

    override init() {
        super.init()
        self.socketManager.startHeartbeatCmd = 1700
        self.socketManager.heartbeatCmd = 1400
        self.socketManager.delegate = self

        self.socketManager.port = self.port
        self.connect()
    }
    
    func didConnect() {
        UIApplication.sharedApplication().keyWindow?.rootViewController?.view.hideHud()
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
    
    func connect() {
        if self.socketManager.socket.isConnected {
            return
        }
        self.socketManager.address = self.serverAddress
        self.socketManager.connect()
    }
    
    func disconnect() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self.socketManager)
        self.socketManager.disConnect()
        UIApplication.sharedApplication().keyWindow?.rootViewController?.view.hideHud()
    }
    
    func connectFailed() {
        self.socketManager.performSelector(#selector(TCSocketManager.connect), withObject: nil, afterDelay: 2)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.view.showHudWithText("连接中...", indicator: false, userInteraction:false)
    }
    
    func didDisconnect() {
        self.socketManager.performSelector(#selector(TCSocketManager.connect), withObject: nil, afterDelay: 2)
        UIApplication.sharedApplication().keyWindow?.rootViewController?.view.showHudWithText("连接中...", indicator: false, userInteraction:false)

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
//            self.serverAddress = alertView.textFieldAtIndex(0)?.text
            self.socketManager.address = self.serverAddress
            self.socketManager.port = TCContext.port
            self.socketManager.connect()
        } else if alertView.tag == AlertTag.Verify.rawValue {
            let textField = alertView.textFieldAtIndex(0)
            let payload = TCSocketPayload()
            payload.cmdType = 1900
            payload.cmdContent = JSON(NSNumber(integer:Int(textField!.text!)!))
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
            if buttonIndex == 1 {
                self.showInputAddress()
            } else if buttonIndex == 2 {
                self.showVerify()
            }
        } else if alertView.tag == AlertTag.Reconnect.rawValue {
            if buttonIndex == 1 {
                self.socketManager.connect()
            } else if buttonIndex == 2 {
                self.showInputAddress()
            }
        }
    }
}
